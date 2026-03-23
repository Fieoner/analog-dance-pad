#!/bin/bash
# Analog Dance Pad - System Validation Script
# Run this on any new system to check if setup is complete

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Analog Dance Pad - System Validation                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

FAILED=0
WARNING=0

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    FAILED=$((FAILED + 1))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    WARNING=$((WARNING + 1))
}

check_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. System Dependencies"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check Node
if command -v node &> /dev/null; then
    NODE_VER=$(node --version)
    check_pass "Node.js installed: $NODE_VER"
else
    check_fail "Node.js not found"
fi

# Check npm
if command -v npm &> /dev/null; then
    NPM_VER=$(npm --version)
    check_pass "npm installed: $NPM_VER"
else
    check_fail "npm not found"
fi

# Check git
if command -v git &> /dev/null; then
    check_pass "git installed"
else
    check_warn "git not found (needed only if cloning from repo)"
fi

# Check build tools
if command -v gcc &> /dev/null; then
    check_pass "gcc installed"
else
    check_fail "gcc not found (required for compilation)"
fi

if command -v make &> /dev/null; then
    check_pass "make installed"
else
    check_fail "make not found (required for compilation)"
fi

if command -v python3 &> /dev/null; then
    check_pass "python3 installed"
else
    check_fail "python3 not found (required for node-gyp)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. Project Structure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PROJECT_ROOT="${1:-.}"

if [ -d "$PROJECT_ROOT/server" ]; then
    check_pass "server directory exists"
else
    check_fail "server directory not found at $PROJECT_ROOT/server"
fi

if [ -d "$PROJECT_ROOT/client" ]; then
    check_pass "client directory exists"
else
    check_fail "client directory not found at $PROJECT_ROOT/client"
fi

if [ -f "$PROJECT_ROOT/server/package.json" ]; then
    check_pass "server/package.json found"
else
    check_fail "server/package.json not found"
fi

if [ -f "$PROJECT_ROOT/client/package.json" ]; then
    check_pass "client/package.json found"
else
    check_fail "server/package.json not found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. Node Modules"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -d "$PROJECT_ROOT/server/node_modules" ]; then
    check_pass "server/node_modules installed"
else
    check_info "server/node_modules not installed - run: cd server && npm install"
fi

if [ -d "$PROJECT_ROOT/client/node_modules" ]; then
    check_pass "client/node_modules installed"
else
    check_info "client/node_modules not installed - run: cd client && npm install"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. Native Modules"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

DETECTION_NODE="$PROJECT_ROOT/server/node_modules/usb-detection/build/Release/detection.node"
if [ -f "$DETECTION_NODE" ]; then
    check_pass "detection.node built successfully"
else
    check_warn "detection.node not found at $DETECTION_NODE"
    check_info "This will be built when you run: cd server && npm install"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. LibUDev (USB Detection)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Find libudev
LIBUDEV_PATHS=$(find /usr -name "libudev.so*" 2>/dev/null || find ~/.local -name "libudev.so*" 2>/dev/null || true)

if [ -n "$LIBUDEV_PATHS" ]; then
    check_pass "libudev found:"
    echo "$LIBUDEV_PATHS" | while read -r path; do
        echo "          $path"
    done
else
    check_fail "libudev not found on system"
    check_info "Install with:"
    check_info "  Fedora:  sudo dnf install libudev-devel"
    check_info "  Ubuntu:  sudo apt-get install libudev-dev"
    check_info "  Arch:    sudo pacman -S systemd"
fi

# Check LD_LIBRARY_PATH
if [ -n "$LD_LIBRARY_PATH" ]; then
    check_pass "LD_LIBRARY_PATH is set"
    check_info "Value: $LD_LIBRARY_PATH"
else
    check_warn "LD_LIBRARY_PATH not set"
    check_info "Set it with: export LD_LIBRARY_PATH=/path/to/libudev/lib:\$LD_LIBRARY_PATH"
fi

# Check if detection.node can find libudev
if [ -f "$DETECTION_NODE" ]; then
    if ldd "$DETECTION_NODE" 2>/dev/null | grep -q "libudev"; then
        if ldd "$DETECTION_NODE" | grep "libudev" | grep -q "=>";
            then check_pass "detection.node can find libudev at runtime"
        else
            check_warn "detection.node found libudev but with warnings"
            ldd "$DETECTION_NODE" | grep "libudev" || true
        fi
    else
        check_warn "ldd output for detection.node:"
        ldd "$DETECTION_NODE" 2>&1 || true
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. USB Access"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if command -v lsusb &> /dev/null; then
    USB_COUNT=$(lsusb | wc -l)
    check_pass "lsusb available: Found $USB_COUNT USB devices"
else
    check_warn "lsusb not found"
fi

# Check if user is in usb group
if groups $USER | grep -q "usb"; then
    check_pass "User is in 'usb' group"
else
    check_warn "User not in 'usb' group - may need to add with: sudo usermod -a -G usb $USER"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7. Environment Variables"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

check_info "Current environment:"
check_info "  NODE_ENV: ${NODE_ENV:-not set}"
check_info "  LD_LIBRARY_PATH: ${LD_LIBRARY_PATH:-not set}"
check_info "  PATH includes node: $(echo $PATH | grep -q "node" && echo "yes" || echo "no (check NVM)")"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $FAILED -eq 0 ] && [ $WARNING -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! System is ready.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Ensure npm run build succeeds in both directories"
    echo "  2. Start server: cd server && npm start"
    echo "  3. Start client: cd client && npm start"
    exit 0
elif [ $FAILED -eq 0 ]; then
    echo -e "${YELLOW}⚠ System mostly ready with $WARNING warning(s)${NC}"
    echo ""
    echo "Check the warnings above before proceeding."
    exit 1
else
    echo -e "${RED}✗ System has $FAILED critical issue(s)${NC}"
    echo ""
    echo "Please fix the issues above before proceeding."
    exit 1
fi
