#!/usr/bin/env bash
set -euo pipefail

LOG=net-diag-$(date +%F_%H-%M-%S).log
{
  echo "=== Host Info ==="
  uname -a
  cat /etc/os-release | grep -E "^(NAME|VERSION|ID)="
  echo

  echo "=== DNS ==="
  host getcomposer.org || echo "[host failed]"
  nslookup getcomposer.org || echo "[nslookup failed]"
  dig +short getcomposer.org || echo "[dig failed]"
  echo

  echo "=== TCP Connectivity ==="
  echo "nc test:"
  command -v nc >/dev/null && nc -vz getcomposer.org 443 || echo "nc not installed or failed"
  echo
  echo "curl TCP test (no TLS):"
  curl -v --max-time 30 http://getcomposer.org:80/ 2>&1 || echo "[curl HTTP failed]"
  echo
  echo "curl TLS test:"
  curl -v --max-time 30 https://getcomposer.org/ 2>&1 || echo "[curl HTTPS failed]"
  echo

  echo "=== Proxies ==="
  env | grep -iE 'proxy|http|https' || true
  echo

  echo "=== Routing ==="
  ip route get 104.21.12.147  # IP getcomposer.org (может отличаться — см. DNS выше)
  echo

  echo "=== Firewall (basic check) ==="
  sudo ufw status 2>/dev/null || echo "ufw not installed"
  echo

  echo "=== End ==="
} > "$LOG"

echo "Saved to: $LOG"
cat "$LOG"
