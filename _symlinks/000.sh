#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Ошибка: запустите скрипт с sudo"
    exit 1
fi

echo "=== Запуск диагностики HDD: тесты на реальном диске ==="

# Проверяем, где находится /tmp
echo "Проверка точки монтирования /tmp:"
df -h /tmp
echo ""

# Установка fio, если нет
if ! command -v fio &> /dev/null; then
    echo "Устанавливаем fio..."
    apt-get update -qq > /dev/null 2>&1
    apt-get install -y -qq fio > /dev/null 2>&1
fi

# Ищем подходящий раздел HDD для тестов
echo "Поиск подходящего раздела для тестов..."
TEST_DIR=""
while IFS= read -r line; do
    part=$(echo "$line" | awk '{print $1}')
    mountpoint=$(echo "$line" | awk '{print $4}')
    # Пропускаем tmpfs и системные разделы, ищем раздел с точкой монтирования
    if [[ "$mountpoint" != "none" && "$mountpoint" != "/" && "$mountpoint" != "" ]]; then
        TEST_DIR="$mountpoint"
        echo "Для тестов выбран раздел: $part ($TEST_DIR)"
        break
    fi
done < <(lsblk -l -o NAME,TYPE,MOUNTPOINT,SIZE | grep "part")

# Если не нашли подходящий раздел — используем / (но это крайний случай)
if [ -z "$TEST_DIR" ]; then
    TEST_DIR="/"
    echo "Не найден отдельный раздел для тестов, используем корневой $TEST_DIR"
fi

TEST_FILE="$TEST_DIR/fio_hdd_test"

# Очистка кэша перед тестами
echo "Очищаем кэш..."
echo 3 | tee /proc/sys/vm/drop_caches > /dev/null

# Создаём тестовый файл 1 ГБ на выбранном разделе
echo "Создаём тестовый файл $TEST_FILE (1 ГБ)..."
dd if=/dev/zero of="$TEST_FILE" bs=1M count=1024 status=none 2>/dev/null || {
    echo "Ошибка: не удалось создать тестовый файл на $TEST_DIR. Проверяем альтернативный путь..."
    # Альтернатива: пробуем /var/tmp, если есть
    if [ -d "/var/tmp" ]; then
        TEST_FILE="/var/tmp/fio_hdd_test"
        echo "Пробуем создать файл в /var/tmp..."
        dd if=/dev/zero of="$TEST_FILE" bs=1M count=1024 status=none 2>/dev/null || {
            echo "Ошибка: не удалось создать тестовый файл ни на одном из разделов. Проверьте свободное место и права."
            exit 1
        }
    else
        echo "Ошибка: нет доступных разделов для теста. Убедитесь, что диск подключён и смонтирован."
        exit 1
    fi
}

# Тест fio: последовательная запись
echo "Тест fio: последовательная запись (500 МБ)..."
fio --name=seq_write --rw=write --bs=1M --size=500M --filename="$TEST_FILE" --direct=1 --numjobs=1 --runtime=30 --time_based --group_reporting --output=/tmp/fio_seq_write.log --output-format=normal 2>/dev/null || echo "Тест seq_write завершился с ошибкой"

# Тест fio: последовательное чтение
echo "Тест fio: последовательное чтение (500 МБ)..."
fio --name=seq_read --rw=read --bs=1M --size=500M --filename="$TEST_FILE" --direct=1 --numjobs=1 --runtime=30 --time_based --group_reporting --output=/tmp/fio_seq_read.log --output-format=normal 2>/dev/null || echo "Тест seq_read завершился с ошибкой"

# Тест fio: случайная запись (4K)
echo "Тест fio: случайная запись (4K, 500 МБ)..."
fio --name=rand_write --rw=randwrite --bs=4k --size=500M --filename="$TEST_FILE" --direct=1 --numjobs=1 --runtime=30 --time_based --group_reporting --output=/tmp/fio_rand_write.log --output-format=normal 2>/dev/null || echo "Тест rand_write завершился с ошибкой"

# Тест fio: случайное чтение (4K)
echo "Тест fio: случайное чтение (4K, 500 МБ)..."
fio --name=rand_read --rw=randread --bs=4k --size=500M --filename="$TEST_FILE" --direct=1 --numjobs=1 --runtime=30 --time_based --group_reporting --output=/tmp/fio_rand_read.log --output-format=normal 2>/dev/null || echo "Тест rand_read завершился с ошибкой"

# Вывод ключевых метрик из логов fio
echo "--- Результаты fio ---"
for log in /tmp/fio_*.log; do
    if [ -f "$log" ]; then
        echo "Результаты из $log:"
        # Выводим строки с bw= (пропускная способность) и IOPS
        grep -E "(bw=|IOPS=)" "$log" | tail -6
        echo ""
    fi
done

# Удаляем тестовый файл
echo "Удаляем тестовый файл..."
rm -f "$TEST_FILE"

# Очистка временных логов
rm -f /tmp/fio_*.log

echo "=== Тестирование завершено ==="
