#! /bin/bash

sudo apt update
sudo apt install libnss3-tools

# Download the latest release for Linux (64-bit)
wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64

# Make the file executable
chmod +x mkcert-v1.4.4-linux-amd64

# Move it to a directory in your PATH (e.g., /usr/local/bin)
sudo mv mkcert-v1.4.4-linux-amd64 /usr/local/bin/mkcert