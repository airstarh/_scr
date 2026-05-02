#!/bin/bash

# NVM Installation Script for Kubuntu
# Exit on error, undefined variable, and pipe failure
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== NVM Installation Script for Kubuntu ===${NC}"

# Step 1: Update system and install prerequisites
echo -e "${YELLOW}Step 1: Installing prerequisites...${NC}"
sudo apt update
sudo apt install -y curl git build-essential

# Step 2: Download and install NVM
echo -e "${YELLOW}Step 2: Installing NVM...${NC}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Step 3: Load NVM into current shell
echo -e "${YELLOW}Step 3: Loading NVM...${NC}"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Step 4: Verify NVM installation
echo -e "${YELLOW}Step 4: Verifying NVM installation...${NC}"
if command -v nvm &> /dev/null; then
    echo -e "${GREEN}✓ NVM installed successfully: $(nvm --version)${NC}"
else
    echo -e "${RED}✗ NVM installation failed${NC}"
    exit 1
fi

# Step 5: Install Node.js version 16.19.1
echo -e "${YELLOW}Step 5: Installing Node.js version 16.19.1...${NC}"
nvm install 16.19.1

# Step 6: Set Node.js 16.19.1 as default
echo -e "${YELLOW}Step 6: Setting Node.js 16.19.1 as default version...${NC}"
nvm alias default 16.19.1

# Step 7: Use Node.js 16.19.1 in current shell
echo -e "${YELLOW}Step 7: Switching to Node.js 16.19.1...${NC}"
nvm use 16.19.1

# Step 8: Verify Node.js and npm
echo -e "${YELLOW}Step 8: Verifying Node.js and npm...${NC}"
echo -e "${GREEN}Node.js version: $(node --version)${NC}"
echo -e "${GREEN}npm version: $(npm --version)${NC}"

# Step 9: Add NVM to bashrc if not already present
echo -e "${YELLOW}Step 9: Ensuring NVM persists in new shells...${NC}"
if ! grep -q 'NVM_DIR' ~/.bashrc; then
    echo '' >> ~/.bashrc
    echo '# NVM Configuration' >> ~/.bashrc
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc
    echo -e "${GREEN}✓ Added NVM to ~/.bashrc${NC}"
else
    echo -e "${GREEN}✓ NVM already configured in ~/.bashrc${NC}"
fi

echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo -e "${GREEN}✓ Node.js 16.19.1 is installed and set as default${NC}"
echo -e "${YELLOW}Note: For new terminals, Node.js 16.19.1 will load automatically.${NC}"
echo -e "${YELLOW}To use NVM in this terminal, run: source ~/.bashrc${NC}"