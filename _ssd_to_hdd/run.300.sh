# Moving Additional Directories in the Future
# Example: Move /opt to HDD while preserving path
sudo rsync -avxP /opt/ /osa/opt/
sudo mv /opt /opt.old
sudo ln -s /osa/opt /opt

# Example: Move /usr/local
sudo rsync -avxP /usr/local/ /osa/usr/local/
sudo mv /usr/local /usr/local.old
sudo ln -s /osa/usr/local /usr/local