# know interface:
ip addr
# flush
sudo dhclient -r enp4s0 && sudo dhclient enp4s0
# test
resolvectl status enp4s0
