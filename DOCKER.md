# Docker Setup for Analog Dance Pad

This guide covers running the Analog Dance Pad application using Docker/Podman containers.

---

## Why Use Docker?

✅ **No environment setup needed** - Everything is pre-configured
✅ **Works identically on any system** - Docker, Podman, Mac, Linux, Windows
✅ **Resolves libudev automatically** - USB detection just works
✅ **Easy deployment** - Single command to start everything
✅ **Isolated environment** - Doesn't affect your system

---

## Quick Start

### Prerequisites

Choose one:
- **Docker** (recommended for most systems)
  ```bash
  # Install from: https://docs.docker.com/get-docker/
  docker --version
  docker-compose --version
  ```

- **Podman** (recommended for Fedora/RHEL)
  ```bash
  podman --version
  podman-compose --version
  ```

### Run with Docker Compose

**Production mode (optimized):**
```bash
docker-compose up
```

**Development mode (hot-reload):**
```bash
docker-compose -f docker-compose.dev.yml up
```

Then open: **http://localhost:3000**

Server will be available at: **http://localhost:3333**

---

## With Podman

Podman commands are identical to Docker:

```bash
# Start services
podman-compose up

# In development
podman-compose -f docker-compose.dev.yml up

# Stop services
podman-compose down

# View logs
podman-compose logs -f server
podman-compose logs -f client
```

---

## Individual Container Management

### Build Images Manually

```bash
# Build server
docker build -f Dockerfile.server -t analog-dance-pad:server .

# Build client
docker build -f Dockerfile.client -t analog-dance-pad:client .

# Build client (dev)
docker build -f Dockerfile.client.dev -t analog-dance-pad:client-dev .
```

### Run Containers Individually

```bash
# Run server
docker run -d \
  --name adp-server \
  -p 3333:3333 \
  -e NODE_ENV=production \
  analog-dance-pad:server

# Run client
docker run -d \
  --name adp-client \
  -p 3000:3000 \
  --link adp-server:server \
  analog-dance-pad:client
```

---

## USB Device Access

For USB device detection to work in Docker, the container needs access to USB devices.

### USB Access in Production

```yaml
# Add to docker-compose.yml under 'server' service:
services:
  server:
    devices:
      - /dev/bus/usb:/dev/bus/usb
    privileged: true
```

Or via command line:
```bash
docker run --device /dev/bus/usb:/dev/bus/usb --privileged analog-dance-pad:server
```

### Alternative: Use Host Network

```bash
docker run --network host analog-dance-pad:server
```

---

## Development Workflow

### With Hot-Reload

```bash
# Start development environment
docker-compose -f docker-compose.dev.yml up

# In another terminal, edit files in:
# - server/src/* - changes hot-reload in server container
# - client/src/* - changes hot-reload in client container

# View logs
docker-compose -f docker-compose.dev.yml logs -f server
docker-compose -f docker-compose.dev.yml logs -f client
```

### Rebuilding After Changes

If you install new packages:

```bash
# Rebuild images
docker-compose -f docker-compose.dev.yml up --build

# Or specific service
docker-compose -f docker-compose.dev.yml up --build client
```

---

## Common Commands

### Start Services
```bash
# Production
docker-compose up

# Development
docker-compose -f docker-compose.dev.yml up

# Detached (background)
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f server
docker-compose logs -f client

# Last 50 lines
docker-compose logs --tail 50
```

### Execute Commands in Container
```bash
# Run command in server container
docker-compose exec server npm run build

# Run command in client container
docker-compose exec client npm run typecheck

# Interactive shell in server
docker-compose exec server /bin/bash
```

### Rebuild Images
```bash
# Rebuild all
docker-compose build

# Rebuild specific service
docker-compose build server
docker-compose build client

# Fresh build (no cache)
docker-compose build --no-cache
```

### Clean Up
```bash
# Stop and remove containers
docker-compose down

# Remove images
docker image rm analog-dance-pad:server analog-dance-pad:client

# Remove all unused Docker resources
docker system prune -a --volumes
```

---

## Environment Variables

### Server Container

```yaml
# docker-compose.yml
services:
  server:
    environment:
      NODE_ENV: production
      DEBUG: analog-dance-pad:*
      PORT: 3333
```

### Client Container

```yaml
services:
  client:
    environment:
      REACT_APP_API_URL: http://server:3333
```

---

## Networking

### Container-to-Container Communication

By default, services can communicate using their service names as hostnames:

```javascript
// In server code, accessible to client at:
// http://server:3333

// In client code, proxy to server:
// http://localhost:3000/api/* → http://server:3333/*
```

### External Access

- **Client:** http://localhost:3000
- **Server API:** http://localhost:3333
- **Server WebSocket:** ws://localhost:3333

### Multi-Host Setup

If running on different machines:

```bash
# Edit docker-compose.yml
# Change 'server' container name to IP/hostname
# Or use docker network create for overlay networks
```

---

## Troubleshooting

### Container won't start
```bash
# View detailed logs
docker-compose logs server

# Rebuild image
docker-compose build --no-cache server

# Try debugging
docker-compose run server /bin/bash
```

### "Cannot find module" errors
```bash
# Rebuild without cache
docker-compose build --no-cache

# Verify node_modules mounted correctly
docker-compose exec server ls -la /app/node_modules
```

### USB devices not visible
```bash
# Check if device flag is set in docker-compose.yml
# Run container with elevated privileges:
docker run --privileged --device /dev/bus/usb analog-dance-pad:server
```

### Port already in use
```bash
# Check what's using the port
lsof -i :3000
lsof -i :3333

# Kill the process
kill -9 <PID>

# Or use different ports in docker-compose.yml
ports:
  - "8000:3000"  # Client at localhost:8000
  - "8333:3333"  # Server at localhost:8333
```

### Hot-reload not working in development
```bash
# In docker-compose.dev.yml, ensure volumes are mounted
volumes:
  - ./server/src:/app/src
  - /app/node_modules  # Preserve container node_modules

# Restart container
docker-compose -f docker-compose.dev.yml restart server
```

### Out of space
```bash
# Clean up Docker
docker system prune -a --volumes

# Check disk usage
docker system df
```

---

## Performance Tips

### Reduce Image Size
- Multi-stage builds (already implemented for client)
- Alpine base images for smaller footprint

### Improve Build Speed
```bash
# Use build cache
docker-compose build

# Avoid rebuilding dependencies
# (only rebuild if package.json changes)
```

### Optimize Runtime
```bash
# Use production Node environment
NODE_ENV=production

# Disable source maps in production
NEXT_PUBLIC_DISABLE_DEBUG=true
```

---

## Advanced: Custom Networks

```yaml
# docker-compose.yml
networks:
  adp-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

services:
  server:
    networks:
      - adp-network
  client:
    networks:
      - adp-network
```

---

## Deployment

### Single Container

```bash
# Pull/build image
docker pull myregistry/analog-dance-pad:server

# Run
docker run -d \
  --name adp-server \
  -p 3333:3333 \
  --restart always \
  --device /dev/bus/usb \
  myregistry/analog-dance-pad:server
```

### Docker Swarm

```bash
docker stack deploy -c docker-compose.yml adp
```

### Kubernetes

```bash
kubectl apply -f k8s-deployment.yml
```

---

## Native vs Docker Performance

| Aspect | Native | Docker |
|--------|--------|--------|
| Setup time | 30+ minutes | 5 minutes |
| Startup time | ~5 seconds | ~2 seconds |
| Memory overhead | None | ~50MB |
| USB access | Direct | Via device mapping |
| Portability | OS-specific | Universal |

**Verdict:** Docker is generally better for consistency, especially across different systems.

---

## Further Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Podman Documentation](https://podman.io/docs/)
- [Node.js Docker Best Practices](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
