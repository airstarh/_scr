# Stop and disable
sudo systemctl stop iptables 2>/dev/null
sudo systemctl disable iptables 2>/dev/null

# Also for netfilter-persistent
sudo systemctl stop netfilter-persistent 2>/dev/null
sudo systemctl disable netfilter-persistent 2>/dev/null

# Flush all rules
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

# Make it persistent (so it stays after reboot)
sudo apt remove -y iptables-persistent netfilter-persistent 2>/dev/null

# verify
sudo iptables -L -n
