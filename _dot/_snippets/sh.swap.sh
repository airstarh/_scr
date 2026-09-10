sudo swapoff /osa/swapfile 2>/dev/null || true
sudo install -m 600 /dev/null /osa/swapfile
sudo fallocate -l 16G /osa/swapfile
sudo chmod 600 /osa/swapfile
sudo mkswap /osa/swapfile
sudo swapon -p 10 /osa/swapfile

sudo cp -a /etc/fstab /etc/fstab.backup-before-swap
sudo sed -i '\|/osa/swapfile|d; \|/mnt/d1001/swapfile|d' /etc/fstab
echo '/osa/swapfile none swap sw,pri=10 0 0' | sudo tee -a /etc/fstab

swapon --show
free -h
sudo findmnt --verify
