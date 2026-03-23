# Setting Up Analog Dance Pad on a New System

This guide walks through setting up the project from scratch on a new machine.

---

## System Requirements

### Operating System
- **Linux** (tested on Fedora/Bazzite)
- Wayland or X11 display server
- User with sudo access

### Required System Packages

```bash
# For Fedora/RHEL
sudo dnf install -y \
  git \
  gcc \
  g++ \
  make \
  python3 \
  python3-devel \
  libusb-devel \
  libudev-devel \
  nodejs \
  npm

# For Ubuntu/Debian
sudo apt-get install -y \
  git \
  build-essential \
  python3 \
  python3-dev \
  libusb-dev \
  libudev-dev \
  nodejs \
  npm

# For Arch
sudo pacman -S \
  git \
  base-devel \
  python \
  libusb \
  systemd \
  nodejs \
  npm
```

### Optional: NVM (Node Version Manager)
If you want to manage multiple Node versions:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc  # or ~/.zshrc
nvm install 20.20.1
nvm use 20.20.1
```

---

## Installation Steps

### 1. Clone/Copy the Project

```bash
# Option A: Clone from git repository
git clone <repository-url> analog-dance-pad
cd analog-dance-pad

# Option B: Copy from existing system
rsync -av /path/to/analog-dance-pad ./
cd analog-dance-pad
```

### 2. Install Server Dependencies

```bash
cd server
npm install
```

**What this does:**
- Downloads all npm packages listed in `package.json`
- Installs Node.js native modules (including `usb-detection` and `node-hid`)
- May take 2-5 minutes depending on internet speed

**Expected output:**
```
added XXX packages, and audited XXX packages in XXs
```

**If native modules fail to build:**
- libudev development headers are missing
- See "Troubleshooting" section below

### 3. Install Client Dependencies

```bash
cd ../client
npm install
```

### 4. Verify Installation

```bash
# Check server builds
cd ../server
npm run build
npm run typecheck

# Check client typechecks
cd ../client
npm run typecheck
```

**Expected output:**
```
✓ Compiled successfully
```

---

## Finding libudev on Your System

The USB detection feature requires `libudev`. On different systems, it's in different locations:

### Fedora/RHEL
```bash
# Find libudev library
find /usr -name "libudev.so*" 2>/dev/null

# Typical paths:
# /usr/lib64/libudev.so.1
# /usr/lib64/libudev.so
```

### Ubuntu/Debian
```bash
# Find libudev library
find /usr -name "libudev.so*" 2>/dev/null

# Typical paths:
# /usr/lib/x86_64-linux-gnu/libudev.so.1
# /usr/lib/x86_64-linux-gnu/libudev.so
```

### Arch
```bash
# Find libudev library
find /usr -name "libudev.so*" 2>/dev/null

# Typical path:
# /usr/lib/libudev.so.1
```

### Steam Runtime / Container
```bash
# If using Steam Proton or containers
find ~/.local/share/Steam -name "libudev.so*" 2>/dev/null
find ~/.var/app -name "libudev.so*" 2>/dev/null
```

---

## Setting Up Environment Variables

Once you know where `libudev` is located on your system, set it up:

### Option A: Temporary (for current terminal session only)

```bash
# Find your libudev location (from above)
LIBUDEV_PATH="/path/to/libudev/lib/directory"

# Export it
export LD_LIBRARY_PATH="$LIBUDEV_PATH:${LD_LIBRARY_PATH}"

# Test it
ldd ./server/node_modules/usb-detection/build/Release/detection.node | grep libudev
```

### Option B: Permanent (add to shell config)

Edit `~/.bashrc` or `~/.zshrc`:

```bash
# Add this section to the file
# ========== Analog Dance Pad ==========
if [ -d "/path/to/analog-dance-pad" ]; then
    export LD_LIBRARY_PATH="/path/to/libudev/lib:${LD_LIBRARY_PATH}"
fi
# ========================================
```

Then reload:
```bash
source ~/.bashrc  # or ~/.zshrc
```

### Option C: Automated Setup Script

Create `setup-env-local.sh` in your project directory:

```bash
#!/bin/bash

# Find libudev automatically
LIBUDEV_LIB=$(find /usr -name "libudev.so.1" 2>/dev/null | head -1 | xargs dirname)

if [ -z "$LIBUDEV_LIB" ]; then
    echo "ERROR: libudev not found on this system"
    echo "Install it with: sudo apt-get install libudev-dev  (Ubuntu)"
    echo "              OR: sudo dnf install libudev-devel   (Fedora)"
    exit 1
fi

export LD_LIBRARY_PATH="$LIBUDEV_LIB:${LD_LIBRARY_PATH}"
export NODE_ENV=development

echo "✓ Environment configured for: $LIBUDEV_LIB"
```

Then use it:
```bash
source ./setup-env-local.sh
```

---

## Running on New System

### Terminal 1 - Server

```bash
cd analog-dance-pad/server

# If using permanent env setup:
npm start

# If using temporary env setup:
export LD_LIBRARY_PATH="/path/to/libudev/lib:${LD_LIBRARY_PATH}"
npm start
```

### Terminal 2 - Client

```bash
cd analog-dance-pad/client
npm start
```

### Open Browser

Navigate to: **http://localhost:3000**

---

## Troubleshooting on New System

### Issue: "npm ERR! gyp ERR! build error" during `npm install`

**Cause:** Native modules couldn't compile
**Solution:**
```bash
# Install required development packages
# Fedora:
sudo dnf install gcc gcc-c++ make python3-devel

# Ubuntu:
sudo apt-get install build-essential python3-dev

# Then retry
cd server
rm -rf node_modules
npm install
```

### Issue: "cannot find -ludev" during npm install

**Cause:** libudev development headers not installed
**Solution:**
```bash
# Fedora:
sudo dnf install libudev-devel

# Ubuntu:
sudo apt-get install libudev-dev

# Arch:
sudo pacman -S systemd

# Then retry
cd server
npm rebuild usb-detection --build-from-source
```

### Issue: "node: command not found"

**Cause:** Node.js not installed or PATH not set
**Solution:**
```bash
# Check if installed
which node

# If not installed, install Node.js
# Using system package manager:
sudo apt-get install nodejs npm  # Ubuntu
sudo dnf install nodejs npm      # Fedora

# Or using NVM:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 20.20.1
nvm use 20.20.1
```

### Issue: "Port 3333 already in use"

**Cause:** Another process is using the port
**Solution:**
```bash
# Find what's using port 3333
lsof -i :3333

# Kill the process (replace PID)
kill -9 <PID>

# Or use a different port by editing server/src/index.ts
```

### Issue: Client can't connect to server

**Cause:** Server not running or firewall blocking
**Solution:**
```bash
# Check server is running
lsof -i :3333

# Test server responds
curl http://localhost:3333

# Check client logs in browser console (F12)
```

---

## System-Specific Notes

### Fedora / RHEL
- ✅ Full system packages available via `dnf`
- ✅ Excellent development tools support
- ℹ️ May need to enable RPM Fusion repo for some packages
- ⚠️ SELinux might restrict USB access (see USB Access section)

### Ubuntu / Debian
- ✅ Stable, well-tested setup
- ✅ Largest community for troubleshooting
- ℹ️ May be slightly older package versions
- ℹ️ `libudev-dev` required, not automatic with `libudev`

### Arch Linux
- ✅ Latest software versions
- ✅ Minimal, clean installation
- ⚠️ Requires more manual configuration
- ⚠️ Breaking changes more frequent

### macOS (NOT SUPPORTED)
- ❌ USB detection uses Linux-specific APIs
- ❌ Would require different native modules
- ⚠️ Client might work but server won't detect USB devices

### Windows (NOT OFFICIALLY SUPPORTED)
- ❌ WSL2 might work with loopback device
- ❌ Native Windows would require completely different USB libraries
- ⚠️ Not tested

---

## USB Device Access

For the server to detect USB devices, it needs proper permissions.

### Grant USB Access (Ubuntu/Debian)

```bash
# Add current user to usb group
sudo usermod -a -G usb $USER

# Add udev rule for dance pad devices (if needed)
echo 'SUBSYSTEM=="usb", MODE="0666"' | sudo tee /etc/udev/rules.d/99-usb.rules

# Reload udev rules
sudo udevadm control --reload-rules

# Log out and back in for group changes to take effect
```

### Grant USB Access (Fedora/RHEL)

```bash
# Add current user to usb group
sudo usermod -a -G usb $USER

# Add udev rule
echo 'SUBSYSTEM=="usb", MODE="0666"' | sudo tee /etc/udev/rules.d/99-usb.rules

# Reload udev rules
sudo udevadm control --reload-rules

# Log out and back in
```

### Verify USB Access

```bash
# List USB devices
lsusb

# Should show your dance pad / Teensy device

# If permission denied, check group membership
groups $USER  # should include 'usb' group
```

---

## Network Setup

For accessing the client/server on the network:

### From Same Machine (default)
- Server: `http://localhost:3333`
- Client: `http://localhost:3000`
- ✅ Works immediately

### From Same Network

Edit `server/src/index.ts`:
```typescript
// Change this line:
httpServer.listen(3333, 'localhost');

// To this:
httpServer.listen(3333, '0.0.0.0');  // Listen on all interfaces
```

Then access from another machine:
```
http://<your-machine-ip>:3000
```

Find your machine IP:
```bash
hostname -I
# or
ip addr show | grep "inet "
```

### Behind Firewall / Router

You may need to:
1. Configure port forwarding on your router
2. Open firewall ports:
   ```bash
   # Fedora
   sudo firewall-cmd --permanent --add-port=3000/tcp
   sudo firewall-cmd --permanent --add-port=3333/tcp
   sudo firewall-cmd --reload
   ```

---

## Quick Start on New System (Checklist)

- [ ] Install system dependencies (gcc, python3, libudev-dev, nodejs)
- [ ] Clone/copy project
- [ ] Run `npm install` in server directory
- [ ] Run `npm install` in client directory
- [ ] Find libudev on your system: `find /usr -name "libudev.so*"`
- [ ] Set `LD_LIBRARY_PATH` environment variable
- [ ] Test: `npm run typecheck` in both directories
- [ ] Start server: `npm start` in server directory
- [ ] Start client: `npm start` in client directory
- [ ] Open browser to `http://localhost:3000`
- [ ] Connect USB device and verify detection

---

## Getting Help

If you run into issues on a new system:

1. **Check system has all dependencies:**
   ```bash
   which gcc g++ make python3 npm node
   ```

2. **Verify libudev is installed:**
   ```bash
   pkg-config --modversion libudev
   ```

3. **Test native module:**
   ```bash
   ldd server/node_modules/usb-detection/build/Release/detection.node | grep libudev
   ```

4. **Check environment variables:**
   ```bash
   echo $LD_LIBRARY_PATH
   echo $NODE_ENV
   ```

5. **See detailed errors:**
   ```bash
   cd server
   npm start 2>&1 | tail -50
   ```
