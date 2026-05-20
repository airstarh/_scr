# Create mount point
sudo mkdir -p /osa

# Unmount from current auto-mount location
sudo umount /run/media/qqq/nix_tb

# Add to fstab for permanent mounting (using your actual UUID)
echo 'UUID=dcd6103c-415f-4818-8953-bba4a9578b5f /osa ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab

# Mount it now
sudo mount /osa

# Verify
df -h /osa