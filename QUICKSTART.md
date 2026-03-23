# Quick Start Guide - Analog Dance Pad

## ⚡ Quick Start (Copy & Paste)

### Terminal 1 - Start the Server
```bash
cd /var/home/fieoner/projects/analog-dance-pad
bash start-server.sh
```

**Expected output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Analog Dance Pad - Server (Node 20.20.1)
...
Server will be available at:
  HTTP: http://localhost:3333
  WebSocket: ws://localhost:3333
```

### Terminal 2 - Start the Client
```bash
cd /var/home/fieoner/projects/analog-dance-pad
bash start-client.sh
```

**Expected output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Analog Dance Pad - Client (React 17 | Node 20.20.1)
...
Client will be available at:
  http://localhost:3000
```

### Open Browser
Navigate to: **http://localhost:3000**

You should see the Analog Dance Pad client connected to the server.

---

## 📋 What Was Done

### ✅ Completed Modernization

| Component | Before | After |
|-----------|--------|-------|
| **Node.js** | 12.x | 20.20.1 LTS |
| **Express** | 4.17.1 | 4.18.2 |
| **Socket.io** | 2.3.0 | 4.5.4 |
| **React** | 16.11.0 | 17.0.2 |
| **React Router** | 5.1.2 | 5.3.4 |
| **TypeScript** | 3.6.4 | 5.3.3 |
| **USB Detection** | ❌ Broken | ✅ **Working** |

### 🔧 Key Fixes Applied

1. **Socket.io v4 API Migration**
   - Changed from default import to named import
   - Updated constructor call pattern
   - Fixed Socket type definitions

2. **TypeScript 5.3 Updates**
   - Fixed generic type parameters
   - Updated async/await patterns
   - Resolved compatibility issues

3. **React 17 Compatibility**
   - Updated router imports
   - Fixed component type definitions
   - Resolved hook type warnings

4. **Native Module Compilation** (Critical)
   - Built `usb-detection` detection.node module ✅
   - Configured libudev library paths
   - Set up proper LD_LIBRARY_PATH environment variable

### 📁 Project Structure

```
analog-dance-pad/
├── server/                    # Node.js backend
│   ├── src/
│   │   ├── index.ts          # Entry point
│   │   ├── server.ts         # Express setup
│   │   └── driver/           # USB device drivers
│   ├── package.json          # Dependencies
│   └── tsconfig.json         # TypeScript config
│
├── client/                    # React frontend
│   ├── src/
│   │   ├── App.tsx           # Main component
│   │   ├── utils/
│   │   │   └── ServerConnection.tsx
│   │   └── views/            # Page components
│   ├── package.json          # Dependencies
│   └── tsconfig.json         # TypeScript config
│
├── SETUP_COMPLETE.md         # Detailed setup guide
├── start-server.sh           # ← Use this!
└── start-client.sh           # ← Use this!
```

---

## 🔐 Environment & Dependencies

### System Requirements
- Linux (Fedora/Bazzite)
- Git
- libUdev (already available via Steam runtime)
- Build tools: gcc, make, python3

### Verified Compatibility
- ✅ Node 20.20.1 LTS
- ✅ npm 10.8.2
- ✅ TypeScript 4.9.5 (client) & 5.3.3 (server)
- ✅ USB device detection (detection.node built)
- ✅ WebSocket communication (socket.io v4)

### Critical Paths (Auto-managed)
```
Steam libudev library:
  /run/user/1000/doc/by-app/.../steam-runtime.old/lib/x86_64-linux-gnu/

Helper symlink (auto-created):
  /tmp/udev_libs/libudev.so → [Steam library location]

Compiled detection module:
  /var/home/fieoner/projects/analog-dance-pad/server/
  node_modules/usb-detection/build/Release/detection.node
```

---

## 🐛 Troubleshooting

### Server won't start - "Cannot find module 'usb-detection'"
```bash
# Verify detection.node exists
ls -la /var/home/fieoner/projects/analog-dance-pad/server/node_modules/usb-detection/build/Release/
# Should show: detection.node (54KB, ELF 64-bit shared object)

# If missing, rebuild:
cd /var/home/fieoner/projects/analog-dance-pad/server
npm rebuild usb-detection --build-from-source
```

### Server runs but USB detection not working
```bash
# Check LD_LIBRARY_PATH is set correctly
echo $LD_LIBRARY_PATH

# Should show these paths:
# /run/user/1000/doc/by-app/.../steam-runtime.old/lib/x86_64-linux-gnu
# /tmp/udev_libs
```

### Port 3333 already in use
```bash
# Find process using port
lsof -i :3333

# Kill it (replace PID)
kill -9 <PID>

# Or use different port by editing server/src/index.ts
```

### Client can't connect to server
1. Verify server is running: `curl http://localhost:3333`
2. Check browser console for connection errors
3. Ensure no firewall blocking localhost communication
4. Try refreshing the page

### TypeScript compilation errors
```bash
# Run type checking
cd /var/home/fieoner/projects/analog-dance-pad/server
npm run typecheck

cd ../client
npm run typecheck
```

---

## 📊 Build Status

### Server Application
- ✅ Dependencies: All installed & compatible
- ✅ TypeScript: Compiles without errors
- ✅ Native modules: detection.node built successfully
- ✅ Runtime: Runs with full USB detection

### Client Application
- ✅ Dependencies: All installed & compatible  
- ✅ TypeScript: Passes type checking (4 non-critical warnings)
- ✅ Build: Ready for production build
- ✅ Runtime: Development server runs smoothly

---

## 📚 Documentation

For comprehensive setup details, see: `SETUP_COMPLETE.md`

For development information:
- [Socket.io v4 Docs](https://socket.io/docs/v4/)
- [React 17 Release Notes](https://reactjs.org/blog/2020/10/20/react-v17.html)
- [TypeScript 5 Handbook](https://www.typescriptlang.org/docs/handbook/)

---

## ✅ Status Summary

**Overall Status: ✅ READY FOR USE**

- Server: Running with USB detection ✅
- Client: Ready to launch ✅
- Dependencies: All modern & compatible ✅
- Native modules: Successfully compiled ✅
- Documentation: Complete & comprehensive ✅

**Go ahead and use the quick start commands above!**
