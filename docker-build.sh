#!/bin/bash
# Analog Dance Pad - Docker Build and Deploy Helper

set -e

REGISTRY="${1:-}"
VERSION="${2:-latest}"

if [ -z "$REGISTRY" ]; then
    echo "Docker Build Helper for Analog Dance Pad"
    echo ""
    echo "Usage: ./docker-build.sh [REGISTRY] [VERSION]"
    echo ""
    echo "Examples:"
    echo "  ./docker-build.sh                          # Build locally"
    echo "  ./docker-build.sh myregistry.com 1.0       # Build and push"
    echo "  ./docker-build.sh docker.io/myuser latest  # Push to Docker Hub"
    echo ""
    exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building Docker Images"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Determine if using podman or docker
DOCKER_CMD=${DOCKER_CMD:-docker}
if ! command -v $DOCKER_CMD &> /dev/null; then
    if command -v podman &> /dev/null; then
        DOCKER_CMD=podman
    else
        echo "ERROR: Neither docker nor podman found"
        exit 1
    fi
fi

echo "Using: $DOCKER_CMD"
echo ""

# Build server
echo "Building server image..."
$DOCKER_CMD build \
    -f Dockerfile.server \
    -t analog-dance-pad:server-$VERSION \
    .

if [ -n "$REGISTRY" ]; then
    $DOCKER_CMD tag analog-dance-pad:server-$VERSION $REGISTRY/analog-dance-pad:server-$VERSION
    $DOCKER_CMD tag analog-dance-pad:server-$VERSION $REGISTRY/analog-dance-pad:server-latest
fi

echo "✓ Server built"
echo ""

# Build client
echo "Building client image..."
$DOCKER_CMD build \
    -f Dockerfile.client \
    -t analog-dance-pad:client-$VERSION \
    .

if [ -n "$REGISTRY" ]; then
    $DOCKER_CMD tag analog-dance-pad:client-$VERSION $REGISTRY/analog-dance-pad:client-$VERSION
    $DOCKER_CMD tag analog-dance-pad:client-$VERSION $REGISTRY/analog-dance-pad:client-latest
fi

echo "✓ Client built"
echo ""

# Push if registry provided
if [ -n "$REGISTRY" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Pushing to Registry: $REGISTRY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    echo "Pushing server..."
    $DOCKER_CMD push $REGISTRY/analog-dance-pad:server-$VERSION
    $DOCKER_CMD push $REGISTRY/analog-dance-pad:server-latest
    echo "✓ Server pushed"
    echo ""
    
    echo "Pushing client..."
    $DOCKER_CMD push $REGISTRY/analog-dance-pad:client-$VERSION
    $DOCKER_CMD push $REGISTRY/analog-dance-pad:client-latest
    echo "✓ Client pushed"
    echo ""
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✓ Build and push complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Images available at:"
    echo "  $REGISTRY/analog-dance-pad:server-$VERSION"
    echo "  $REGISTRY/analog-dance-pad:client-$VERSION"
else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✓ Build complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Images built locally:"
    echo "  analog-dance-pad:server-$VERSION"
    echo "  analog-dance-pad:client-$VERSION"
    echo ""
    echo "Run with: docker-compose up"
fi
