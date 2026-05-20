# 1. Check that /home is now on HDD
ls -la / | grep home
# Should show: home -> /osa/home

# 2. Check that /srv is on HDD
ls -la / | grep srv
# Should show: srv -> /osa/srv

# 3. Verify Docker is using HDD
docker info | grep "Docker Root Dir"
# Should show: /osa/var/lib/docker

# 4. Check all services are running
sudo systemctl status mysql zoneminder docker --no-pager | grep "Active:"

# 5. Test ZoneMinder web UI
curl -I http://localhost/zm 2>/dev/null | head -1

# 6. Check disk usage on SSD (should have more free space)
df -h / | tail -1

# 7. Verify your files are still accessible
ls ~/Documents 2>/dev/null || ls ~/ 2>/dev/null | head -5