#!/usr/bin/env bash
port=53

# The -w flag matches the exact port word, and we look specifically for :53
if sudo ss -tuln | grep -w ":${port}" > /dev/null; then
  echo "Port ${port} is in use."
else
  echo "Port ${port} is not in use."
fi
