#!/bin/bash

echo "=== Комплексная оптимизация и диагностика HDD для Kubuntu ==="
echo "Дата и время: $(date)"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "Ошибка: запустите скрипт с sudo"
    exit 1
fi

# Устанавливаем необходимые утилиты, если их нет
echo "Проверка и установка необходимых утилит..."
apt-get update 2>/dev/null
apt-get install -y smartmontools sysstat iotop 2>/dev/null || echo "Не удалось установить утилиты (возможно, уже установлены)"

echo "--- Информация о системе ---"
echo "Версия ОС: $(lsb_release -is) $(lsb_release -rs)"
echo "Ядро: $(uname -r)"
echo ""

echo "--- Список дисков и разделов ---"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS,FSTYPE
echo ""

# Автоматически определяем корневой диск
ROOT_PART=$(df / | tail -1 | awk '{print $1}')
ROOT_DISK=$(echo "$ROOT_PART" | sed -E 's/[0-9]+$//' | sed 's|/dev/||')
DATA_DISK="sda"  # Диск с данными (/home, /var/log и т. д.)

if [ -z "$ROOT_DISK" ]; then
    echo "Не удалось определить корневой диск"
    exit 1
fi

echo "Корневой диск: /dev/$ROOT_DISK (раздел $ROOT_PART)"
echo "Диск с данными: /dev/$DATA_DISK"
echo ""

echo "--- Применение оптимизационных настроек ---"

# 1. Увеличиваем буферизацию записи в RAM (агрессивные значения)
echo "Настройка параметров виртуальной памяти..."
{
    echo 'vm.dirty_ratio = 90'
    echo 'vm.dirty_background_ratio = 75'
} > /tmp/tmp_sysctl.conf

# Добавляем новые настройки в sysctl.conf, избегая дублирования
if ! grep -q "vm.dirty_ratio" /etc/sysctl.conf; then
    cat /tmp/tmp_sysctl.conf | sudo tee -a /etc/sysctl.conf > /dev/null
else
    # Заменяем существующие значения
    sudo sed -i '/vm\.dirty_ratio/d' /etc/sysctl.conf
    sudo sed -i '/vm\.dirty_background_ratio/d' /etc/sysctl.conf
    cat /tmp/tmp_sysctl.conf | sudo tee -a /etc/sysctl.conf > /dev/null
fi

sudo sysctl -p
echo "Параметры vm.dirty_* обновлены"
echo ""

# 2. Применяем hdparm только для SATA/IDE дисков
echo "Настройка hdparm для дисков..."
for disk in sda sdb; do
    if [[ "$disk" != nvme* ]]; then
        echo "  Настройка /dev/$disk..."
        sudo hdparm -W1 /dev/$disk 2>/dev/null && echo "    Write cache: включён" || echo "    hdparm не применим (возможно, NVMe или нет прав)"
        sudo hdparm -q -c1 /dev/$disk 2>/dev/null
        sudo hdparm -q -d1 /dev/$disk 2>/dev/null
    fi
done
echo ""

# 3. Меняем I/O scheduler на noop или mq-deadline
echo "Изменение I/O scheduler..."
for disk in $(ls /sys/block/ | grep -E '^(sd|nvme)'); do
    sched_file="/sys/block/$disk/queue/scheduler"
    if [ -f "$sched_file" ]; then
        current_sched=$(cat "$sched_file" | sed 's/.*\[\(.*\)\].*/\1/')
        if grep -q noop "$sched_file"; then
            echo "  $disk: устанавливаем noop"
            echo noop | sudo tee "$sched_file" > /dev/null
        elif grep -q mq-deadline "$sched_file"; then
            echo "  $disk: устанавливаем mq-deadline"
            echo mq-deadline | sudo tee "$sched_file" > /dev/null
        else
            echo "  $disk: подходящий scheduler не найден (текущий: $current_sched)"
        fi
    fi
done
echo ""

# 4. Добавляем noatime,nodiratime в /etc/fstab для основных разделов
echo "Обновление опций монтирования в /etc/fstab..."
FSTAB_BACKUP="/etc/fstab.backup_$(date +%Y%m%d_%H%M%S)"
sudo cp /etc/fstab "$FSTAB_BACKUP"
echo "Создана резервная копия: $FSTAB_BACKUP"

# Обрабатываем корневой раздел
ROOT_LINE=$(grep "$ROOT_PART" /etc/fstab | grep -v "^#")
if [ -n "$ROOT_LINE" ]; then
    NEW_ROOT_LINE=$(echo "$ROOT_LINE" | awk 'BEGIN{FS=OFS="\t"}{split($4, a, ","); seen["noatime"]=seen["nodiratime"]=0; for(i in a) {if(a[i]=="noatime") seen["noatime"]=1; if(a[i]=="nodiratime") seen["nodiratime"]=1} if(!seen["noatime"]) a[length(a)+1]="noatime"; if(!seen["nodiratime"]) a[length(a)+1]="nodiratime"; $4=a[1]; for(i=2;i<=length(a);i++) $4=$4","a[i]; print}')
    sudo sed -i "s|$ROOT_LINE|$NEW_ROOT_LINE|" /etc/fstab
    echo "  Обновлены опции для $ROOT_PART"
fi

# Обрабатываем диск с данными (sda1)
DATA_PART="/dev/sda1"
DATA_LINE=$(grep "$DATA_PART" /etc/fstab | grep -v "^#")
if [ -n "$DATA_LINE" ]; then
    NEW_DATA_LINE=$(echo "$DATA_LINE" | awk 'BEGIN{FS=OFS="\t"}{split($4, a, ","); seen["noatime"]=seen["nodiratime"]=0; for(i in a) {if(a[i]=="noatime") seen["noatime"]=1; if(a[i]=="nodiratime") seen["nodiratime"]=1} if(!seen["noatime"]) a[length(a)+1]="noatime"; if(!seen["nodiratime"]) a[length(a)+1]="nodiratime"; $4=a[1]; for(i=2;i<=length(a);i++) $4=$4","a[i]; print}')
    sudo sed -i "s|$DATA_LINE|$NEW_DATA_LINE|" /etc/fstab
    echo "  Обновлены опции для $DATA_PART"
fi

# Перемонтируем разделы с новыми опциями
echo "Перемонтирование разделов..."
sudo mount -o remount,noatime,nodiratime "$ROOT_PART" 2>/dev/null || echo "  Не удалось перемонтировать $ROOT_PART (возможно, уже применено)"
sudo mount -o remount,noatime,nodiratime /dev/sda1 2>/dev/null || echo "  Не удалось перемонтировать /dev/sda1 (возможно, уже применено)"
echo ""

# 5. Проверка S.M.A.R.T. статуса дисков
echo "--- S.M.A.R.T. статус дисков ---"
for disk in sda sdb; do
    device="/dev/$disk"
    echo "Проверка $device:"
    if sudo smartctl -H "$device" 2>/dev/null; then
        sudo smartctl -H "$device" | grep "test result" || true
        # Дополнительно выводим температуру
        sudo smartctl -A "$device" | grep -i temperature || true
    else
        echo "  smartctl недоступен или нет прав"
    fi
    echo ""a
done

# 6. Быстрый тест скорости чтения/записи
echo "--- Быстрый тест скорости (dd) ---"
TEST_FILE="/tmp/dd_test_$$"
echo "Тестируем корневой раздел $ROOT_PART..."

###
# Тест записи
echo "  Тест записи (100 МБ)..."
dd if=/dev/zero of="$TEST_FILE" bs=1M count=100 oflag=dsync 2>&1 | grep -i bytes

# Тест чтения
echo "  Тест чтения (100 МБ)..."
dd if="$TEST_FILE" of=/dev/null bs=1M count=100 2>&1 | grep -i bytes

# Убираем тестовый файл
rm -f "$TEST_FILE"
