#! /bin/bash

# know interface:
ip addr
# flush dns dhcp network settings
sudo dhclient -r enp4s0 && sudo dhclient enp4s0

# test
resolvectl status enp4s0


sudo dhclient -r enp3s0 && sudo dhclient enp3s0
resolvectl status enp3s0
