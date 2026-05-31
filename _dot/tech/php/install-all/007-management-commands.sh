# Check status of all PHP-FPM services
sudo systemctl status 'php*-fpm'

# Restart a specific version
sudo systemctl restart php8.5-fpm

# Stop a specific version
sudo systemctl stop php7.4-fpm

# Start a specific version
sudo systemctl start php7.4-fpm

# Check which PHP version a project should use
php-switch-version /var/www/my-project

# View PHP-FPM logs
sudo tail -f /var/log/php8.5-fpm.log