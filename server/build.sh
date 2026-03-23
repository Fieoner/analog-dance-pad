#!/bin/bash

# Build script for Analog Dance Pad Server
# This script sets up the necessary environment to build native modules
# on systems where libudev headers are in container overlays

LIBDIR="/run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/containers/storage/overlay/41ca6a334926aad5f4b6c11d6675f6d7330013a1baef38c9912e5d30db84281f/diff/usr/lib64"
INCDIR="/run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/containers/storage/overlay/50379d06a168b6918fb8c424792dadea577e176118e19431d572efaf7264258f/diff/usr/include"

echo "Building native modules with container headers..."

# Build with necessary flags
export CPPFLAGS="-I$INCDIR"
export LDFLAGS="-L$LIBDIR"
export LD_LIBRARY_PATH="$LIBDIR:$LD_LIBRARY_PATH"

# Clean and rebuild
rm -rf node_modules/.bin/node-gyp* node_modules/*/build

# Install without scripts first
npm install --ignore-scripts

# Rebuild native modules with CPPFLAGS and LDFLAGS
echo "Attempting to build native modules..."
cd node_modules/usb-detection/build 2>/dev/null && CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" make BUILDTYPE=Release 2>&1 | tail -5
cd - >/dev/null 2>&1

echo "Build complete. To start the server, use:"
echo "  export LD_LIBRARY_PATH=$LIBDIR:\$LD_LIBRARY_PATH"
echo "  npm start"
