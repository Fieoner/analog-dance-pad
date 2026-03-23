#!/bin/bash
set -e

LIBDIR="/run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/containers/storage/overlay/41ca6a334926aad5f4b6c11d6675f6d7330013a1baef38c9912e5d30db84281f/diff/usr/lib64"
INCDIR="/run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/containers/storage/overlay/50379d06a168b6918fb8c424792dadea577e176118e19431d572efaf7264258f/diff/usr/include"

cd /var/home/fieoner/projects/analog-dance-pad/server/node_modules/usb-detection

# Clean
rm -rf build

# Use npm's node-gyp directly
/var/home/fieoner/.nvm/versions/node/v20.20.1/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js configure --nodedir=/var/home/fieoner/.nvm/versions/node/v20.20.1

# Build
cd build
CPPFLAGS="-I$INCDIR" LDFLAGS="-L$LIBDIR -Wl,-rpath,$LIBDIR" make BUILDTYPE=Release

echo "Build complete! detection.node should now be at:"
ls -la /var/home/fieoner/projects/analog-dance-pad/server/node_modules/usb-detection/build/Release/detection.node
