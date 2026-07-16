#!/usr/bin/env bash
set -euo pipefail

cat <<EOF
=== HOST INFO ===
Hostname: $(hostname)
IP addr (enp4s0): $(ip -4 addr show dev enp4s0 up scope global | awk '/inet / {print $2}')
Kernel: $(uname -r)
Distro: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)

=== INTERFACE & MACVLAN ===
# Список интерфейсов
ip -br link

# ARP/neigh для enp4s0 — критично для macvlan
echo "--- ARP table for enp4s0 ---"
ip neigh show dev enp4s0

# Есть ли macvlan‑интерфейс явно?
ip -d link show type macvlan

=== DOCKER MACVLAN NETWORK ===
docker network inspect alina_be_local_network 2>/dev/null | grep -E '"Name"|"Parent"|"Subnet"' || echo "Network alina_be_local_network not found"

=== CONTAINER IP ===
docker inspect pihole --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null || echo "Container pihole not found"

=== ROUTING ===
ip route

=== DNS PROCESSES LISTENING ===
ss -tlnp | grep -E ':53|:5353|dnsmasq|unbound|systemd-resolved'

=== RESOLVER CONFIG ===
cat /etc/systemd/resolved.conf 2>/dev/null || echo "(no /etc/systemd/resolved.conf)"
resolvectl status

=== NFTABLES/IPTABLES SNIPPET FOR DNS ===
sudo nft list ruleset | grep -iE '53|dns|dnsmasq' || echo "nft rules not shown (no sudo output in script)"

# Покажем только ключевые цепочки
sudo iptables -t nat -L -n -v | grep 53 || echo "iptables nat not shown"
sudo iptables -t filter -L -n -v | grep 53 || echo "iptables filter not shown"

=== TEST PING (LOCAL VIEW) ===
ping -c 3 192.168.1.200 || echo "Ping failed"

=== TEST DNS (EXPLICIT SERVER) ===
dig @192.168.1.200 default.org +short || echo "dig failed"
dig @127.0.0.1 default.org +short || echo "dig to localhost failed"

=== SYSTEMD-RESOLVED QUERY ===
resolvectl query default.org || echo "resolvectl failed"
EOF
