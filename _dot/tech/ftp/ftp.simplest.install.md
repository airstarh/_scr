sudo apt update && sudo apt install vsftpd -y

# Create user (no system login)
### sudo useradd -m -s /usr/sbin/nologin qqq
### echo "qqq:1234" | sudo chpasswd

sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
sudo tee /etc/vsftpd.conf > /dev/null <<'EOF'
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
EOF

sudo systemctl restart vsftpd
sudo ufw allow 21/tcp 2>/dev/null || true
