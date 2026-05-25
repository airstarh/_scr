#!/bin/bash

echo "=== Анализ сетевых изменений ==="
echo

# 1. Состояния интерфейсов (смотрим, есть ли мост и его статус)
echo "1. Список сетевых интерфейсов и их состояние:"
ip -br link show
echo

# 2. IP-адреса интерфейсов (важно: видим ли мы br0 и его IP, а также состояние enp4s0)
echo "2. Назначенные IP-адреса:"
ip -4 addr show | grep -E "inet|^[0-9]"
echo

# 3. Таблица маршрутизации (смотрим, не изменился ли шлюз по умолчанию)
echo "3. Таблица маршрутизации:"
ip route show
echo

# 4. Проверка наличия моста br0 (ключевой момент)
echo "4. Информация о мосте br0 (если существует):"
if ip link show br0 &> /dev/null; then
    echo "  Мост br0 существует. Детали:"
    brctl show br0
    echo "  Участники моста:"
    bridge link show dev br0
else
    echo "  Мост br0 не найден (вероятно, система в исходном состоянии)."
fi
echo

# 5. Проверка конфигурационных файлов QEMU (если они есть)
echo "5. Проверка файла bridge.conf (для QEMU):"
if [ -f "/etc/qemu/bridge.conf" ]; then
    echo "  Файл /etc/qemu/bridge.conf найден. Его содержимое:"
    cat /etc/qemu/bridge.conf
else
    echo "  Файл /etc/qemu/bridge.conf отсутствует (это стандартное состояние)."
fi
echo

# 6. Вывод для пользователя: как откатиться
echo "=== Рекомендации по откату ==="
if ip link show br0 &> /dev/null; then
    echo "⚠️  Обнаружен мост br0. Если вы хотите вернуться к исходному состоянию:"
    echo "   1. Отключите мост: sudo ip link set br0 down"
    echo "   2. Удалите мост: sudo ip link delete br0"
    echo "   3. Поднимите ваш основной интерфейс: sudo ip link set enp4s0 up"
    echo "   4. Запросите IP для основного интерфейса: sudo dhclient enp4s0"
else
    echo "✅  Никаких следов моста не обнаружено. Система, вероятно, в исходном состоянии."
fi

echo
echo "Анализ завершен."
