#!/bin/bash
# Multi-PHP Installation Script for Kubuntu 26.04 with Nginx
# PHP versions: 7.4, 8.0, 8.3, 8.4, 8.5

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Multi-PHP Installation Script${NC}"
echo -e "${GREEN}Versions: 7.4, 8.0, 8.3, 8.4, 8.5${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root (use sudo)${NC}"
   exit 1
fi

# Update system
echo -e "${YELLOW}Step 1: Updating system packages...${NC}"
apt update && apt upgrade -y

# Install Nginx if not present
if ! command -v nginx &> /dev/null; then
    echo -e "${YELLOW}Installing Nginx...${NC}"
    apt install nginx -y
    systemctl enable nginx
    systemctl start nginx
fi

# Add Ondřej Surý PPA for multiple PHP versions
echo -e "${YELLOW}Step 2: Adding PHP repository...${NC}"
apt install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt update

# PHP versions to install
PHP_VERSIONS="7.4 8.0 8.3 8.4 8.5"

# Common extensions to install with each version
EXTENSIONS="fpm mysql curl mbstring xml zip gd bcmath intl soap"

echo -e "${YELLOW}Step 3: Installing PHP versions...${NC}"

for version in $PHP_VERSIONS; do
    echo -e "${GREEN}Installing PHP $version...${NC}"

    # Build package list for this version
    PACKAGES="php$version"
    for ext in $EXTENSIONS; do
        # Skip fpm for extension list (it's already included as php$version-fpm)
        if [ "$ext" != "fpm" ]; then
            PACKAGES="$PACKAGES php$version-$ext"
        fi
    done
    # Add fpm separately
    PACKAGES="$PACKAGES php$version-fpm"

    apt install -y $PACKAGES

    # Enable and start FPM service
    systemctl enable php$version-fpm
    systemctl start php$version-fpm

    # Verify it's running
    if systemctl is-active --quiet php$version-fpm; then
        echo -e "${GREEN}✓ PHP $version-fpm is running${NC}"
    else
        echo -e "${RED}✗ PHP $version-fpm failed to start${NC}"
    fi
done

# Create directory structure for test sites
echo -e "${YELLOW}Step 4: Setting up Nginx sites for each PHP version...${NC}"

# Remove default Nginx site if exists
rm -f /etc/nginx/sites-enabled/default

for version in $PHP_VERSIONS; do
    SITE_ROOT="/var/www/php$version-demo"
    mkdir -p $SITE_ROOT

    # Create test info.php file (REMOVE IN PRODUCTION)
    cat > $SITE_ROOT/info.php <<EOF
<?php
phpinfo();
?>
EOF

    # Create a simple index.php
    cat > $SITE_ROOT/index.php <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>PHP $version Test</title>
    <style>
        body { font-family: monospace; margin: 40px; }
        .version { color: #4CAF50; font-weight: bold; }
    </style>
</head>
<body>
    <h1>PHP Version Test</h1>
    <p class="version"><?php echo "Running on PHP " . phpversion(); ?></p>
    <hr>
    <p><a href="info.php">View phpinfo()</a></p>
</body>
</html>
EOF

    # Set proper permissions
    chown -R www-data:www-data $SITE_ROOT
    chmod -R 755 $SITE_ROOT

    # Create Nginx config
    cat > /etc/nginx/sites-available/php$version-demo <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name php$version.local;
    root $SITE_ROOT;
    index index.php index.html;

    access_log /var/log/nginx/php$version-access.log;
    error_log /var/log/nginx/php$version-error.log;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php$version-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    # Enable the site
    ln -sf /etc/nginx/sites-available/php$version-demo /etc/nginx/sites-enabled/

    echo -e "${GREEN}✓ Site configured for PHP $version${NC}"
done

# Test Nginx configuration
echo -e "${YELLOW}Testing Nginx configuration...${NC}"
if nginx -t; then
    echo -e "${GREEN}✓ Nginx configuration is valid${NC}"
    systemctl reload nginx
else
    echo -e "${RED}✗ Nginx configuration has errors${NC}"
    exit 1
fi

# Add local hosts entries
echo -e "${YELLOW}Step 5: Adding local host entries...${NC}"

for version in $PHP_VERSIONS; do
    if ! grep -q "php$version.local" /etc/hosts; then
        echo "127.0.0.1 php$version.local" >> /etc/hosts
        echo -e "${GREEN}✓ Added php$version.local to /etc/hosts${NC}"
    fi
done

# Create utility script for managing PHP versions
echo -e "${YELLOW}Step 6: Creating management utility script...${NC}"

cat > /usr/local/bin/php-switch-version <<'EOF'
#!/bin/bash
# Utility to show which PHP version is being used for a given directory

if [ -z "$1" ]; then
    echo "Usage: php-switch-version /path/to/your/project"
    exit 1
fi

PROJECT_PATH="$1"

if [ ! -d "$PROJECT_PATH" ]; then
    echo "Error: Directory $PROJECT_PATH does not exist"
    exit 1
fi

echo "========================================="
echo "PHP Version Configuration Helper"
echo "========================================="
echo "For project: $PROJECT_PATH"
echo ""
echo "To use a specific PHP version for this project,"
echo "create an Nginx server block with:"
echo ""
echo "    fastcgi_pass unix:/run/php/phpVERSION-fpm.sock;"
echo ""
echo "Available PHP versions and their sockets:"
echo "----------------------------------------"

for v in 7.4 8.0 8.3 8.4 8.5; do
    if systemctl is-active --quiet php$v-fpm; then
        echo "  PHP $v: unix:/run/php/php$v-fpm.sock ✓ (active)"
    else
        echo "  PHP $v: unix:/run/php/php$v-fpm.sock ✗ (inactive)"
    fi
done

echo ""
echo "To test PHP from command line with specific version:"
echo "  /usr/bin/php7.4 your-script.php"
echo "  /usr/bin/php8.5 your-script.php"
EOF

chmod +x /usr/local/bin/php-switch-version

# Create CLI aliases script
echo -e "${YELLOW}Step 7: Creating shell aliases...${NC}"

cat > /etc/profile.d/php-aliases.sh <<'EOF'
# PHP version aliases
alias php74='/usr/bin/php7.4'
alias php80='/usr/bin/php8.0'
alias php83='/usr/bin/php8.3'
alias php84='/usr/bin/php8.4'
alias php85='/usr/bin/php8.5'

# Function to check which PHP version a script will use
php-check() {
    if [ -f "$1" ]; then
        head -1 "$1" | grep -q "^#!" && echo "Shebang: $(head -1 "$1")" || echo "No shebang line"
        echo "To run with specific version: php74 $1 or php85 $1"
    else
        echo "File not found: $1"
    fi
}
EOF

chmod +x /etc/profile.d/php-aliases.sh

# Display status and summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${BLUE}PHP-FPM Services Status:${NC}"
systemctl list-units --type=service | grep php.*fpm | grep running || echo "No services found"

echo -e "\n${BLUE}Installed PHP Versions:${NC}"
for version in $PHP_VERSIONS; do
    if command -v php$version &> /dev/null; then
        PHP_VER=$(php$version -v | head -1)
        echo "  ✓ $PHP_VER"
    fi
done

echo -e "\n${BLUE}Test URLs (add to /etc/hosts if remote):${NC}"
for version in $PHP_VERSIONS; do
    echo "  http://php$version.local/info.php"
done

echo -e "\n${BLUE}Useful Commands:${NC}"
echo "  # Restart a specific PHP version:"
echo "  sudo systemctl restart php8.5-fpm"
echo ""
echo "  # Check status of all PHP versions:"
echo "  sudo systemctl status 'php*-fpm'"
echo ""
echo "  # Run CLI scripts with specific version:"
echo "  /usr/bin/php8.3 /path/to/script.php"
echo "  php85 /path/to/script.php  # (after reloading shell)"
echo ""
echo "  # View management utility:"
echo "  php-switch-version /path/to/your/project"

echo -e "\n${YELLOW}⚠️  Security Reminder:${NC}"
echo "  Remove test info.php files from production:"
echo "  find /var/www -name 'info.php' -delete"

echo -e "\n${GREEN}To apply shell aliases, run: source /etc/profile.d/php-aliases.sh${NC}"