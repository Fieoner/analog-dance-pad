#!/bin/bash
# Analog Dance Pad - Server Startup Script
# This script sets up the environment and starts the server

set -e

PROJECT_DIR="/var/home/fieoner/projects/analog-dance-pad"
SERVER_DIR="$PROJECT_DIR/server"

# Library paths for USB detection
STEAM_LIB_PATH="/run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/Steam/ubuntu12_32/steam-runtime.old/lib/x86_64-linux-gnu"
UDEV_HELPER_PATH="/tmp/udev_libs"

# Verify server directory exists
if [ ! -d "$SERVER_DIR" ]; then
    echo "ERROR: Server directory not found: $SERVER_DIR"
    exit 1
fi

# Verify library paths exist
if [ ! -f "$STEAM_LIB_PATH/libudev.so.1.5.0" ]; then
    echo "ERROR: Steam libudev library not found at: $STEAM_LIB_PATH/libudev.so.1.5.0"
    exit 1
fi

# Ensure helper symlink exists
if [ ! -L "$UDEV_HELPER_PATH/libudev.so" ]; then
    echo "Setting up libudev symlink..."
    mkdir -p "$UDEV_HELPER_PATH"
    ln -sf "$STEAM_LIB_PATH/libudev.so.1" "$UDEV_HELPER_PATH/libudev.so"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Analog Dance Pad - Server (Node 20.20.1)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Starting server with USB detection support..."
echo ""
echo "Server will be available at:"
echo "  HTTP: http://localhost:3333"
echo "  WebSocket: ws://localhost:3333"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Set environment variables and start the server
cd "$SERVER_DIR"
export LD_LIBRARY_PATH="$STEAM_LIB_PATH:$UDEV_HELPER_PATH:${LD_LIBRARY_PATH}"
npm start
