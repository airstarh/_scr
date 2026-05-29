# Kill everything and restart
sudo systemctl stop input-remapper-daemon
sudo pkill -f input-remapper
sudo systemctl restart bluetooth
sleep 3
# Reconnect your mouse via Bluetooth GUI
sudo systemctl start input-remapper-daemon