#! /bin/bash

# DeepSeek
# https://chat.deepseek.com/a/chat/s/6ae6f1f1-5f69-41a0-9283-09ff11479af0

# Sendmail and dependencies
sudo apt install sendmail -y
sudo apt install sendmail-cf -y
sudo apt install m4 -y

# SASL authentication support
sudo apt install sasl2-bin -y

# CA certificates for TLS
sudo apt install ca-certificates -y

# Mail utilities (optional, for testing)
sudo apt install mailutils -y
sudo apt install bsd-mailx -y
