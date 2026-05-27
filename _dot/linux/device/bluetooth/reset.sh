#! /bin/bash
sudo su
cd /var/lib/bluetooth/

############################################################

# HELPS
### sudo systemctl restart bluetooth

############################################################
# MAC без двоеточий
# узнать командой
# qqq@aaa:~$ hciconfig
# hci0:   Type: Primary  Bus: USB
#         BD Address: 00:E0:4C:23:99:87  ACL MTU: 1021:6  SCO MTU: 255:12
#         --> BD Address: 00E04C239987  ACL MTU: 1021:6  SCO MTU: 255:12
#         UP RUNNING PSCAN INQUIRY
#         RX bytes:903530 acl:14343 sco:0 events:3443 errors:0
#         TX bytes:48193 acl:427 sco:0 commands:353 errors:0
#
# qqq@aaa:~$
############################################################
rm -rf 00E04C239987

rm -rf ~/.config/kde-connect/
rm -rf /home/qqq/.config/kde-connect/
rm -f ~/.config/bluedevil*
rm -f /home/qqq/.config/bluedevil*
reboot