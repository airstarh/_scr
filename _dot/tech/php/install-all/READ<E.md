# Multi-PHP Installation for Kubuntu 26.04 with Nginx (PHP 7.4, 8.0, 8.3, 8.4, 8.5)

Here's a clean solution without PHP 5.3. All versions are available directly from the Ondřej Surý PPA.

## Complete Bash Installation Script

Save this as `install-multi-php.sh`:

```bash
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
```

## Run the Installation

```bash
chmod +x install-multi-php.sh
sudo ./install-multi-php.sh
```

After installation, reload your shell to use the aliases:
```bash
source /etc/profile.d/php-aliases.sh
```

## Configure Nginx for Your Actual Sites

For your real projects, create Nginx server blocks like this:

### Example 1: Legacy app needing PHP 7.4
```nginx
# /etc/nginx/sites-available/legacy-app
server {
    listen 80;
    server_name legacy.yourdomain.com;
    root /var/www/legacy-app/public;
    index index.php;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    }
}
```

### Example 2: Modern app needing PHP 8.5
```nginx
# /etc/nginx/sites-available/modern-app
server {
    listen 80;
    server_name app.yourdomain.com;
    root /var/www/modern-app/public;
    index index.php;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.5-fpm.sock;
    }
}
```

### Example 3: Different PHP version per subdirectory
```nginx
server {
    listen 80;
    server_name mixed.yourdomain.com;
    root /var/www/mixed-site;

    # API uses PHP 8.3
    location /api/ {
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        }
    }

    # Admin area uses PHP 7.4 (legacy code)
    location /admin/ {
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        }
    }

    # Everything else uses PHP 8.5
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.5-fpm.sock;
    }
}
```

## Running CLI Scripts with Specific Versions

```bash
# Method 1: Direct binary call
/usr/bin/php7.4 /path/to/legacy-script.php
/usr/bin/php8.5 /path/to/modern-script.php

# Method 2: Using aliases (after sourcing the aliases file)
php74 /path/to/legacy-script.php
php85 /path/to/modern-script.php

# Method 3: Shebang line in your PHP script
#!/usr/bin/php7.4
<?php
// Your legacy code here
```

## Management Commands

```bash
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
```

## Verify Installation

```bash
# Test each PHP version from CLI
php74 -v
php80 -v
php83 -v
php84 -v
php85 -v

# Test via web browser
curl http://php7.4.local/info.php | grep "PHP Version"
curl http://php8.5.local/info.php | grep "PHP Version"
```

## Socket Locations

| PHP Version | FPM Socket Path |
|-------------|-----------------|
| 7.4 | `/run/php/php7.4-fpm.sock` |
| 8.0 | `/run/php/php8.0-fpm.sock` |
| 8.3 | `/run/php/php8.3-fpm.sock` |
| 8.4 | `/run/php/php8.4-fpm.sock` |
| 8.5 | `/run/php/php8.5-fpm.sock` |

All versions coexist peacefully, each with its own:
- Configuration files: `/etc/php/{version}/`
- FPM pool config: `/etc/php/{version}/fpm/pool.d/www.conf`
- Log files: `/var/log/php{version}-fpm.log`

This setup gives you complete flexibility to run different PHP versions for different domains, subdirectories, or even individual scripts.

I'll provide a clear, step-by-step guide for installing Composer for each of your PHP versions (7.4, 8.0, 8.3, 8.4, 8.5) on Kubuntu 26.04.

## The Simple Answer: You Only Install Composer Once

**You don't actually need to install separate Composer binaries.** Composer is just a PHP script - the same script works with any PHP version. You control which PHP version Composer uses by specifying it when you run the command.

However, for convenience, you can create separate wrapper scripts or aliases. Here are three approaches, from simplest to most complete:

## Approach 1: Shell Aliases (Quickest & Most Common)

Add these lines to your `~/.bashrc` or `~/.zshrc` file:

```bash
# PHP-specific Composer aliases
alias composer74='/usr/bin/php7.4 /usr/local/bin/composer'
alias composer80='/usr/bin/php8.0 /usr/local/bin/composer'
alias composer83='/usr/bin/php8.3 /usr/local/bin/composer'
alias composer84='/usr/bin/php8.4 /usr/local/bin/composer'
alias composer85='/usr/bin/php8.5 /usr/local/bin/composer'
```

Then reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

**Usage:**
```bash
cd /var/www/legacy-app
composer74 install

cd /var/www/modern-app
composer85 require laravel/framework
```

## Approach 2: Separate Composer Binaries (More Robust)

This creates actual executable files for each PHP version:

```bash
#!/bin/bash
# Run as sudo

# First, install the global Composer if not already present
if [ ! -f /usr/local/bin/composer ]; then
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm composer-setup.php
fi

# Now create version-specific wrappers
for version in 7.4 8.0 8.3 8.4 8.5; do
    cat > /usr/local/bin/composer${version} <<EOF
#!/bin/bash
/usr/bin/php${version} /usr/local/bin/composer "\$@"
EOF
    chmod +x /usr/local/bin/composer${version}
    echo "Created: composer${version}"
done
```

After running this script, you can use:
```bash
composer74 install
composer85 update
composer83 require guzzlehttp/guzzle
```

## Approach 3: Complete Multi-Composer Installer Script

Here's a complete script that validates PHP installations, downloads Composer properly, and sets up all version-specific wrappers:

```bash
#!/bin/bash
# multi-composer-setup.sh
# Run with: sudo ./multi-composer-setup.sh

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Multi-PHP Composer Installer${NC}"
echo -e "${GREEN}========================================${NC}"

# Check running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root (use sudo)${NC}"
   exit 1
fi

PHP_VERSIONS="7.4 8.0 8.3 8.4 8.5"

# Verify each PHP version is installed
echo -e "${YELLOW}Step 1: Verifying PHP installations...${NC}"
for version in $PHP_VERSIONS; do
    if command -v php${version} &> /dev/null; then
        echo -e "${GREEN}✓ PHP $version found${NC}"
    else
        echo -e "${RED}✗ PHP $version not found. Please install it first.${NC}"
        exit 1
    fi
done

# Download and install global Composer using default PHP
echo -e "${YELLOW}Step 2: Installing global Composer...${NC}"

# Clean up any previous failed installations
rm -f composer-setup.php

# Download with default PHP
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

# Verify installer signature
SIGNATURE_EXPECTED="$(curl -s https://composer.github.io/installer.sig)"
php -r "if (hash_file('sha384', 'composer-setup.php') === '$SIGNATURE_EXPECTED') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); exit(1); }" || exit 1

# Install globally
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php

echo -e "${GREEN}✓ Global Composer installed${NC}"

# Create version-specific wrappers
echo -e "${YELLOW}Step 3: Creating PHP-specific Composer wrappers...${NC}"

for version in $PHP_VERSIONS; do
    WRAPPER="/usr/local/bin/composer${version}"

    cat > $WRAPPER <<EOF
#!/bin/bash
# Composer wrapper for PHP $version
/usr/bin/php${version} /usr/local/bin/composer "\$@"
EOF

    chmod +x $WRAPPER
    echo -e "${GREEN}✓ Created: composer${version}${NC}"
done

# Verify all wrappers work
echo -e "${YELLOW}Step 4: Testing installation...${NC}"
for version in $PHP_VERSIONS; do
    if composer${version} --version > /dev/null 2>&1; then
        echo -e "${GREEN}✓ composer${version} works${NC}"
    else
        echo -e "${RED}✗ composer${version} failed${NC}"
    fi
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\nAvailable commands:"
for version in $PHP_VERSIONS; do
    echo "  composer${version} [command]"
done
echo -e "\nExamples:"
echo "  composer74 install"
echo "  composer85 require laravel/framework"
echo "  composer83 update"
```

**To run it:**
```bash
chmod +x multi-composer-setup.sh
sudo ./multi-composer-setup.sh
```

## Project-Level Configuration (Recommended)

For each project, lock the PHP version in `composer.json` to ensure compatibility:

```bash
cd /var/www/your-project
composer83 config platform.php 8.3.0
```

This adds to your `composer.json`:
```json
{
    "config": {
        "platform": {
            "php": "8.3.0"
        }
    }
}
```

## Which Approach Should You Use?

| Approach | Pros | Cons | Best For |
|----------|------|------|----------|
| **Aliases (Approach 1)** | Quick, no extra files | Aliases don't work in cron/CI scripts | Interactive terminal use |
| **Separate binaries (Approach 2)** | Works everywhere, explicit | Requires setup script | Most production scenarios |
| **Complete installer (Approach 3)** | Validates everything, production-ready | Slightly overkill for simple setups | Teams, CI/CD, multiple servers |

## Verification Commands

After setup, verify each version works:

```bash
# Check which PHP version each Composer command uses
composer74 --version   # Should show PHP 7.4.x
composer85 --version   # Should show PHP 8.5.x

# Test actual functionality
cd /tmp
composer83 create-project laravel/laravel test-project --prefer-dist
rm -rf test-project
```

## Important Notes

1. **Don't rely on the system `composer` command alone** - it uses whatever PHP is in your `$PATH`, which may not be what you expect

2. **Always use the wrapper commands explicitly** in scripts and cron jobs for consistency

3. **The global Composer binary works for all PHP versions** - you're just changing which PHP interpreter runs it

4. **Update Composer once** (via `sudo composer self-update`) and all version wrappers automatically use the updated version