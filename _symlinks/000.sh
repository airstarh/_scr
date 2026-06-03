#!/bin/bash
echo "=== CONTAINER STATUS ==="
docker ps -a --filter "name=alina"

echo -e "\n=== NGINX LOGS ==="
docker logs alina_nginx --tail 50

echo -e "\n=== PHP LOGS ==="
docker logs alina_php --tail 50

echo -e "\n=== NGINX ERROR LOG ==="
docker exec alina_nginx cat /var/log/nginx/error.log 2>/dev/null || echo "Cannot read error log (read-only fs)"

echo -e "\n=== PHP-FPM STATUS ==="
docker exec alina_php ps aux | grep php-fpm