# Test each PHP version from CLI
php74 -v
php80 -v
php83 -v
php84 -v
php85 -v

# Test via web browser
curl http://php7.4.local/info.php | grep "PHP Version"
curl http://php8.5.local/info.php | grep "PHP Version"