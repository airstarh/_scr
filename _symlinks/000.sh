### STOP SERVICES
sudo systemctl stop docker
sudo systemctl stop containerd

### CREATE TARGET DIRECTORY ON HDD AND MOVE DATA
sudo mkdir -p /osa/var/lib/containerd
sudo rsync -av /var/lib/containerd/ /osa/var/lib/containerd/
sudo rm -rf /var/lib/containerd
sudo mkdir /var/lib/containerd

### ADD BIND MOUNT TO FSTAB
### Edit /etc/fstab and add this line:
### /osa/var/lib/containerd  /var/lib/containerd  none  bind  0  0
### Use: sudo nano /etc/fstab
### ### MANUAL STEP: Edit /etc/fstab and add the bind mount line above

### MOUNT AND VERIFY
sudo systemctl daemon-reload
sudo mount -a
mount | grep containerd
df -h /var/lib/containerd

### START SERVICES
sudo systemctl start containerd
sudo systemctl start docker

### VERIFY EVERYTHING
df -h /var/lib/containerd
sudo du -sh /var/lib/containerd
docker info | grep "Docker Root Dir"
df -h /dev/sdb2
sudo du -sh /var/lib/containerd 2>/dev/null

### OPTIONAL: CLEAN UP UNUSED DOCKER VOLUMES (8.1GB on HDD)
docker volume prune -f

### CHECK FINAL SSD USAGE
df -h /dev/sdb2
