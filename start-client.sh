#!/bin/bash
# Analog Dance Pad - Client Startup Script
# This script starts the React development server

set -e

PROJECT_DIR="/var/home/fieoner/projects/analog-dance-pad"
CLIENT_DIR="$PROJECT_DIR/client"

# Verify client directory exists
if [ ! -d "$CLIENT_DIR" ]; then
    echo "ERROR: Client directory not found: $CLIENT_DIR"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Analog Dance Pad - Client (React 17 | Node 20.20.1)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Starting React development server..."
echo ""
echo "Client will be available at:"
echo "  http://localhost:3000"
echo ""
echo "Connected to server at:"
echo "  http://localhost:3333"
echo ""
echo "Note: Make sure the server is running before opening the client!"
echo "  Run: bash start-server.sh (in another terminal)"
echo ""
echo "Press Ctrl+C to stop the client"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Start the client
cd "$CLIENT_DIR"
npm start
