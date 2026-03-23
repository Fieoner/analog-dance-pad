#!/bin/bash
# Analog Dance Pad - Environment Setup
# Source this file in your terminal to set up all required environment variables

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Setting up Analog Dance Pad environment...${NC}\n"

# 1. Ensure Node.js v20.20.1 is active (from NVM)
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo "  ✓ Loading NVM..."
    source "$HOME/.nvm/nvm.sh"
    nvm use 20.20.1 2>/dev/null || echo "    Warning: Could not switch to Node 20.20.1"
else
    echo "  ✗ NVM not found at ~/.nvm/nvm.sh"
    echo "    Install NVM from: https://github.com/nvm-sh/nvm"
fi

# 2. Verify Node version
NODE_VERSION=$(node --version 2>/dev/null || echo "not found")
NPM_VERSION=$(npm --version 2>/dev/null || echo "not found")
echo "  Node version: $NODE_VERSION"
echo "  NPM version: $NPM_VERSION"

# 3. Set up libudev paths for USB detection
STEAM_LIB_PATH="/run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/Steam/ubuntu12_32/steam-runtime.old/lib/x86_64-linux-gnu"
UDEV_HELPER_PATH="/tmp/udev_libs"

echo ""
echo "  Setting libudev library paths..."

if [ -f "$STEAM_LIB_PATH/libudev.so.1.5.0" ]; then
    echo "    ✓ Steam libudev library found"
else
    echo "    ✗ Steam libudev library NOT found at:"
    echo "      $STEAM_LIB_PATH/libudev.so.1.5.0"
fi

# Create helper symlink if it doesn't exist
if [ ! -L "$UDEV_HELPER_PATH/libudev.so" ]; then
    mkdir -p "$UDEV_HELPER_PATH"
    ln -sf "$STEAM_LIB_PATH/libudev.so.1" "$UDEV_HELPER_PATH/libudev.so" 2>/dev/null
    echo "    ✓ Created helper symlink at $UDEV_HELPER_PATH/libudev.so"
elif [ -L "$UDEV_HELPER_PATH/libudev.so" ]; then
    echo "    ✓ Helper symlink already exists"
fi

# 4. Export required environment variables
echo ""
echo "  Exporting environment variables..."

export LD_LIBRARY_PATH="$STEAM_LIB_PATH:$UDEV_HELPER_PATH:${LD_LIBRARY_PATH}"
export NODE_ENV="${NODE_ENV:-development}"

echo "    ✓ LD_LIBRARY_PATH set"
echo "    ✓ NODE_ENV=$NODE_ENV"

# 5. Verify detection.node module
echo ""
echo "  Checking native modules..."

DETECTION_NODE="/var/home/fieoner/projects/analog-dance-pad/server/node_modules/usb-detection/build/Release/detection.node"
if [ -f "$DETECTION_NODE" ]; then
    echo "    ✓ detection.node found"
else
    echo "    ✗ detection.node NOT found"
    echo "      Expected at: $DETECTION_NODE"
fi

# 6. Summary
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Environment setup complete!${NC}\n"
echo "You can now run:"
echo "  • Server: cd /var/home/fieoner/projects/analog-dance-pad/server && npm start"
echo "  • Client: cd /var/home/fieoner/projects/analog-dance-pad/client && npm start"
echo ""

# Show current environment
echo "Current environment:"
echo "  Node: $(node --version)"
echo "  NPM: $(npm --version)"
echo "  LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo ""
