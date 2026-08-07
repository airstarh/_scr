#!/bin/bash
# docker-network-diag.sh
# Docker network diagnostics for Kubuntu 26

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Output file
LOG_FILE="docker-network-diag-$(date +%Y%m%d-%H%M%S).log"

# Function to print colored output
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}✗ $1${NC}" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}" | tee -a "$LOG_FILE"
}

print_info() {
    echo -e "  $1" | tee -a "$LOG_FILE"
}

# Start logging
echo "Docker Network Diagnostic Report" > "$LOG_FILE"
echo "Generated: $(date)" >> "$LOG_FILE"
echo "==========================================" >> "$LOG_FILE"

print_header "System Information"
print_info "Kernel: $(uname -a)"
print_info "OS: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
print_info "Wayland: $XDG_SESSION_TYPE"
print_info "Plasma: $(plasmashell --version 2>/dev/null | head -1 || echo 'Not found')"

print_header "Docker Information"
if command -v docker &> /dev/null; then
    print_info "Docker version: $(docker --version)"
    print_info "Docker compose: $(docker compose version 2>/dev/null || echo 'Not installed')"
    print_info "Docker daemon status:"
    systemctl status docker --no-pager | head -3 | tee -a "$LOG_FILE"
else
    print_error "Docker not found!"
    exit 1
fi

print_header "Docker Network Configuration"
docker network ls | tee -a "$LOG_FILE"
echo "" >> "$LOG_FILE"

print_info "Default bridge network details:"
docker network inspect bridge 2>/dev/null | grep -A 5 -E "Subnet|Gateway|IPAM" | tee -a "$LOG_FILE" || print_error "Cannot inspect bridge network"

print_header "Docker Daemon Configuration"
if [ -f /etc/docker/daemon.json ]; then
    print_info "Contents of /etc/docker/daemon.json:"
    cat /etc/docker/daemon.json | tee -a "$LOG_FILE"
else
    print_warning "No daemon.json found (using defaults)"
fi

print_header "Docker Build Test (without network=host)"
print_info "Creating test Dockerfile..."
cat > /tmp/test-dockerfile << 'EOF'
FROM alpine:latest
RUN apk add --no-cache curl
CMD ["curl", "-s", "https://google.com"]
EOF

print_info "Testing build with default network..."
if docker build -t test-build -f /tmp/test-dockerfile /tmp 2>&1 | tee -a "$LOG_FILE"; then
    print_success "Build succeeded with default network"
    print_info "Cleaning up test image..."
    docker rmi test-build 2>/dev/null || true
else
    print_error "Build failed with default network"
fi

print_header "Network Interface Configuration"
ip addr show | tee -a "$LOG_FILE"
echo "" >> "$LOG_FILE"
ip route show | tee -a "$LOG_FILE"

print_header "Firewall Status - UFW"
if command -v ufw &> /dev/null; then
    ufw status verbose | tee -a "$LOG_FILE" || print_error "Cannot get UFW status"
else
    print_warning "UFW not installed"
fi

print_header "Firewall Status - iptables"
print_info "Current iptables rules (filter table):"
sudo iptables -L -n -v --line-numbers | tee -a "$LOG_FILE" || print_error "Cannot read iptables (need sudo)"

print_info "NAT table rules:"
sudo iptables -t nat -L -n -v | tee -a "$LOG_FILE" || print_error "Cannot read NAT table"

print_info "Mangle table rules:"
sudo iptables -t mangle -L -n -v | head -20 | tee -a "$LOG_FILE" || print_error "Cannot read mangle table"

print_header "Firewall Status - nftables"
if command -v nft &> /dev/null; then
    sudo nft list ruleset 2>/dev/null | head -100 | tee -a "$LOG_FILE" || print_warning "nftables rules not accessible"
else
    print_warning "nftables not installed"
fi

print_header "Firewall Status - firewalld"
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --state 2>/dev/null | tee -a "$LOG_FILE" || print_warning "firewalld not running"
    firewall-cmd --list-all 2>/dev/null | tee -a "$LOG_FILE" || true
else
    print_warning "firewalld not installed"
fi

print_header "Docker iptables Rules"
print_info "DOCKER chain rules:"
sudo iptables -L DOCKER -n -v 2>/dev/null | tee -a "$LOG_FILE" || print_warning "No DOCKER chain found"

print_info "DOCKER-USER chain rules:"
sudo iptables -L DOCKER-USER -n -v 2>/dev/null | tee -a "$LOG_FILE" || print_warning "No DOCKER-USER chain found"

print_info "DOCKER-USER custom rules (filter):"
sudo iptables -L DOCKER-USER -n -v --line-numbers 2>/dev/null | tee -a "$LOG_FILE" || true

print_header "Network Bridge Configuration"
brctl show 2>/dev/null | tee -a "$LOG_FILE" || print_warning "bridge-utils not installed"

print_header "Docker Container Network Namespaces"
for container in $(docker ps -q 2>/dev/null); do
    name=$(docker inspect -f '{{.Name}}' $container | sed 's/\///')
    print_info "Container: $name (ID: $container)"
    docker inspect $container | grep -A 10 "NetworkSettings" | head -15 | tee -a "$LOG_FILE"
done

print_header "DNS Resolution"
print_info "System resolv.conf:"
cat /etc/resolv.conf | tee -a "$LOG_FILE"

print_info "Docker DNS settings:"
docker info | grep -i dns | tee -a "$LOG_FILE" || print_warning "No DNS settings found"

print_header "Port Conflicts"
print_info "Listening ports on host:"
sudo ss -tulpn | grep LISTEN | head -20 | tee -a "$LOG_FILE"

print_info "Docker ports in use:"
docker ps --format "table {{.Names}}\t{{.Ports}}" | tee -a "$LOG_FILE"

print_header "Kernel Settings"
print_info "IP forwarding status:"
sysctl net.ipv4.ip_forward | tee -a "$LOG_FILE"
sysctl net.ipv6.conf.all.forwarding | tee -a "$LOG_FILE"

print_info "Bridge kernel module:"
lsmod | grep bridge | tee -a "$LOG_FILE" || print_warning "Bridge module not loaded"

print_header "Docker Logs (last 50 lines)"
sudo journalctl -u docker -n 50 --no-pager | tee -a "$LOG_FILE" || print_error "Cannot read docker logs"

print_header "Docker Build Logs (last 100 lines)"
if [ -f /var/log/docker.log ]; then
    tail -100 /var/log/docker.log | tee -a "$LOG_FILE"
fi

print_header "Network Connectivity Tests"
print_info "Pinging gateway:"
ip route | grep default | awk '{print $3}' | head -1 | xargs -I {} ping -c 2 {} 2>&1 | tee -a "$LOG_FILE" || print_error "Cannot ping gateway"

print_info "DNS resolution test:"
nslookup google.com 2>&1 | tee -a "$LOG_FILE" || dig google.com 2>&1 | tee -a "$LOG_FILE"

print_header "Common Issues Check"
# Check for common Kubuntu/Plasma specific issues
if systemctl is-active --quiet systemd-resolved; then
    print_warning "systemd-resolved is active - may interfere with Docker DNS"
fi

if [ -f /etc/NetworkManager/NetworkManager.conf ] && grep -q "dns=dnsmasq" /etc/NetworkManager/NetworkManager.conf; then
    print_warning "NetworkManager dnsmasq plugin is active - may interfere with Docker"
fi

# Check for Docker overlay issues
if docker info 2>/dev/null | grep -q "overlay2"; then
    print_info "Using overlay2 storage driver"
else
    print_warning "Not using overlay2 storage driver"
fi

# Check disk space
df -h /var/lib/docker | tee -a "$LOG_FILE"

print_header "Recommended Fixes"
echo "Based on common issues, try these fixes:" | tee -a "$LOG_FILE"
echo "1. Restart Docker: sudo systemctl restart docker" | tee -a "$LOG_FILE"
echo "2. Reset iptables: sudo iptables -F && sudo iptables -t nat -F" | tee -a "$LOG_FILE"
echo "3. Disable systemd-resolved if interfering: sudo systemctl stop systemd-resolved" | tee -a "$LOG_FILE"
echo "4. Add to /etc/docker/daemon.json:" | tee -a "$LOG_FILE"
cat << 'EOF' | tee -a "$LOG_FILE"
{
  "iptables": true,
  "ip-forward": true,
  "ip-masq": true,
  "userland-proxy": false,
  "dns": ["8.8.8.8", "1.1.1.1"]
}
EOF
echo "5. Then restart: sudo systemctl restart docker" | tee -a "$LOG_FILE"

print_header "Quick Fix Script"
cat << 'EOF' | tee -a "$LOG_FILE"
#!/bin/bash
# Quick fix - run with sudo
echo "Resetting Docker network configuration..."
sudo systemctl stop docker
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo systemctl start docker
echo "Testing build..."
docker build -f /tmp/test-dockerfile /tmp
EOF

print_header "Diagnostic Complete"
print_success "Report saved to: $LOG_FILE"
print_info "To share the log: cat $LOG_FILE | pastebinit  (if pastebinit installed)"

# Make the script executable for quick fix
chmod +x "$LOG_FILE.quickfix.sh" 2>/dev/null || true

echo ""
print_info "To run quick fix: sudo bash $LOG_FILE.quickfix.sh"
