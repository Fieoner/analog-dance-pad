# Environment Variables Reference

## Quick Setup for Fresh Terminal

Copy and paste this into a fresh terminal:

```bash
# 1. Load NVM and activate Node 20.20.1
source ~/.nvm/nvm.sh
nvm use 20.20.1

# 2. Set up libudev paths for USB detection
export LD_LIBRARY_PATH="/run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/Steam/ubuntu12_32/steam-runtime.old/lib/x86_64-linux-gnu:/tmp/udev_libs:${LD_LIBRARY_PATH}"

# 3. Create helper symlink (if needed)
mkdir -p /tmp/udev_libs
ln -sf /run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/Steam/ubuntu12_32/steam-runtime.old/lib/x86_64-linux-gnu/libudev.so.1 /tmp/udev_libs/libudev.so 2>/dev/null

# 4. Now start the server
cd /var/home/fieoner/projects/analog-dance-pad/server
npm start
```

---

## OR Use the Setup Script

```bash
source /var/home/fieoner/projects/analog-dance-pad/setup-env.sh
```

This will:
- ✅ Load NVM
- ✅ Activate Node 20.20.1
- ✅ Set LD_LIBRARY_PATH for libudev
- ✅ Create helper symlink
- ✅ Verify all dependencies are available

---

## Environment Variables Explained

### 1. **NVM (Node Version Manager)**
```bash
source ~/.nvm/nvm.sh
nvm use 20.20.1
```
**Why:** On a fresh terminal, NVM is not loaded, so Node/npm aren't in PATH.
**Expected result:** `node --version` should show `v20.20.1`

---

### 2. **LD_LIBRARY_PATH**
```bash
export LD_LIBRARY_PATH="/run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/Steam/ubuntu12_32/steam-runtime.old/lib/x86_64-linux-gnu:/tmp/udev_libs:${LD_LIBRARY_PATH}"
```
**Why:** The USB detection module needs to find the `libudev.so` library at runtime.
- **Steam path:** Where the actual libudev library lives (from Steam Proton runtime)
- **/tmp/udev_libs:** Our helper symlink pointing to the Steam library
- **Preserve existing:** `${LD_LIBRARY_PATH}` appends any existing paths

**Expected result:** `ldd /var/home/fieoner/projects/analog-dance-pad/server/node_modules/usb-detection/build/Release/detection.node` should show libudev can be found

---

### 3. **NODE_ENV** (Optional)
```bash
export NODE_ENV=development
```
**Why:** Some packages behave differently in development vs production.
**Values:** `development`, `production`, `test`

---

## Verification Checklist

After setting environment variables, run these checks:

```bash
# 1. Verify Node.js
node --version        # Should be v20.20.1
npm --version         # Should be a recent version

# 2. Verify LibUDev
echo $LD_LIBRARY_PATH  # Should include the Steam path and /tmp/udev_libs

# 3. Verify detection.node exists
ls -lh /var/home/fieoner/projects/analog-dance-pad/server/node_modules/usb-detection/build/Release/detection.node

# 4. Test server can load the module
cd /var/home/fieoner/projects/analog-dance-pad/server
npm start              # Should start without "cannot find usb-detection" error
```

---

## Common Issues & Fixes

### Issue: "command not found: node"
**Solution:** NVM not loaded
```bash
source ~/.nvm/nvm.sh
nvm use 20.20.1
```

### Issue: "Cannot find libudev"
**Solution:** LD_LIBRARY_PATH not set
```bash
export LD_LIBRARY_PATH="/run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/Steam/ubuntu12_32/steam-runtime.old/lib/x86_64-linux-gnu:/tmp/udev_libs"
```

### Issue: "detection.node not found"
**Solution:** Native module wasn't compiled
```bash
cd /var/home/fieoner/projects/analog-dance-pad/server
npm rebuild usb-detection --build-from-source
```

### Issue: Port 3333/3000 already in use
**Solution:** Kill existing process
```bash
lsof -i :3333  # or :3000
kill -9 <PID>
```

---

## Persistent Setup (Optional)

To make this permanent, add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Analog Dance Pad Setup
if [ -f ~/.nvm/nvm.sh ]; then
    source ~/.nvm/nvm.sh
fi

# Auto-activate Node 20 for this project
if [ "$PWD" == "/var/home/fieoner/projects/analog-dance-pad" ]; then
    nvm use 20.20.1 2>/dev/null
    export LD_LIBRARY_PATH="/run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/Steam/ubuntu12_32/steam-runtime.old/lib/x86_64-linux-gnu:/tmp/udev_libs:${LD_LIBRARY_PATH}"
fi
```

Then reload:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

---

## Complete Fresh Terminal Setup

One-liner to copy-paste into a **completely fresh terminal**:

```bash
source ~/.nvm/nvm.sh && nvm use 20.20.1 && mkdir -p /tmp/udev_libs && ln -sf /run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/Steam/ubuntu12_32/steam-runtime.old/lib/x86_64-linux-gnu/libudev.so.1 /tmp/udev_libs/libudev.so 2>/dev/null && export LD_LIBRARY_PATH="/run/user/1000/doc/by-app/eu.ithz.umftpd/1ea4a438/fieoner/.local/share/Steam/ubuntu12_32/steam-runtime.old/lib/x86_64-linux-gnu:/tmp/udev_libs:${LD_LIBRARY_PATH}" && echo "✓ Environment ready!" && node --version && npm --version
```

After that, you can run:
```bash
cd /var/home/fieoner/projects/analog-dance-pad/server && npm start
# or
cd /var/home/fieoner/projects/analog-dance-pad/client && npm start
```
