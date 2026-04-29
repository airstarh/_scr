# Останавливаем сервис если запущен
sudo systemctl stop zoneminder

# Пересоздаем базу данных
sudo mysql -u root -e "DROP DATABASE IF EXISTS zm;"
sudo mysql -u root -e "CREATE DATABASE zm;"
sudo mysql -u root -e "CREATE USER IF NOT EXISTS 'zmuser'@'localhost' IDENTIFIED BY 'zmpass';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON zm.* TO 'zmuser'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

# Импортируем схему (если файл существует)
if [ -f /usr/share/zoneminder/db/zm_create.sql ]; then
    sudo mysql -u root zm < /usr/share/zoneminder/db/zm_create.sql
    echo "Database schema imported"
else
    echo "ERROR: zm_create.sql not found!"
    find / -name "zm_create.sql" 2>/dev/null
fi

# Запускаем
sudo systemctl start zoneminder
sudo systemctl status zoneminder