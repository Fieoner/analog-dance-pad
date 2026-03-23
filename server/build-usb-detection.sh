#!/bin/bash

INCDIR="/run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/Steam/ubuntu12_32/steam-runtime.old/usr/include"
LIBDIR="/run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/Steam/ubuntu12_32/steam-runtime.old/lib/x86_64-linux-gnu"

# Verify paths exist
if [ ! -f "$INCDIR/libudev.h" ]; then
  echo "ERROR: Header file not found at $INCDIR/libudev.h"
  exit 1
fi

if [ ! -f "$LIBDIR/libudev.so.1.5.0" ]; then
  echo "ERROR: Library file not found at $LIBDIR/libudev.so.1.5.0"
  exit 1
fi

cd "$(dirname "$0")/node_modules/usb-detection" || exit 1

# Remove old build
rm -rf build

# Use npm rebuild with properly set environment variables
# According to node-gyp docs, these are the correct variable names
export npm_config_nodedir="$HOME/.nvm/versions/node/v20.20.1"
export npm_config_cppflags="-I$INCDIR"
export npm_config_ldflags="-L$LIBDIR -Wl,-rpath,$LIBDIR"

# Try to build
npm rebuild --build-from-source 2>&1

# Check if the build succeeded
if [ -f "build/Release/detection.node" ]; then
  echo "SUCCESS: detection.node built successfully"
  exit 0
else
  echo "FAILED: detection.node not created"
  exit 1
fi
