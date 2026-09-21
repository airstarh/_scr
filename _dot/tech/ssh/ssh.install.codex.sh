SSH access is enabled and verified.

  Connect from another device on the same LAN:

  ssh qqq@192.168.1.86

  Use the password you provided. SSH listens on port 22; the service is enabled at boot and active. A real password login test succeeded.

  Commands executed, in order:

  1. Inspected the initial state:

  whoami
  hostname
  command -v sshd
  systemctl is-enabled ssh.service
  systemctl is-active ssh.service
  ss -lnt
  ip -brief address show scope global

  2. Refreshed packages and installed OpenSSH Server:

  sudo apt-get update
  sudo apt-get install -y openssh-server

  3. Enabled SSH at boot and started it:

  sudo systemctl enable --now ssh.service

  4. Checked service state:

  systemctl is-enabled ssh.service
  systemctl is-active ssh.service

  5. Validated the SSH configuration:

  sudo sshd -t
  sudo sshd -T

  6. Confirmed port 22 is listening:

  ss -lntp

  7. Tested an actual password-based login:

  ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no qqq@127.0.0.1 'id -un; hostname'

  The test returned qqq and hostname aaa. No UFW or firewalld firewall was installed, so no firewall rule was necessary. Internet access from outside your LAN would additionally require port forwarding on your
  router.

  Worked for 4m 40s · done 2:10 AM
