# Emergency revert (run from console if you get locked out)
sudo systemctl stop zoneminder mysql docker
sudo rm /home /srv /var/lib/docker
sudo mv /home.old /home
sudo mv /srv.old /srv
sudo mv /var/lib/docker.old /var/lib/docker
sudo systemctl start mysql docker zoneminder