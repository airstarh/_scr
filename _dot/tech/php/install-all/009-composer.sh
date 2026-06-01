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