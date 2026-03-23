# Docker Quick Reference

## TL;DR - Just Start It

```bash
docker-compose up
# or
podman-compose up
```

Then open: **http://localhost:3000**

---

## Common Tasks

### Start in background
```bash
docker-compose up -d
```

### Stop everything
```bash
docker-compose down
```

### View logs
```bash
docker-compose logs -f
```

### View server logs only
```bash
docker-compose logs -f server
```

### Rebuild images
```bash
docker-compose build
```

### Fresh start (remove everything)
```bash
docker-compose down -v && docker-compose up --build
```

### Run command in container
```bash
docker-compose exec server npm run build
docker-compose exec client npm run typecheck
```

### Shell into container
```bash
docker-compose exec server /bin/bash
docker-compose exec client /bin/bash
```

---

## Development Mode (Hot Reload)

```bash
docker-compose -f docker-compose.dev.yml up
```

Then edit files in `server/src/` or `client/src/` and changes will auto-reload.

---

## Troubleshooting

### Port already in use?
Edit `docker-compose.yml`:
```yaml
services:
  server:
    ports:
      - "3333:3333"  # Change first number
  client:
    ports:
      - "3000:3000"  # Change first number
```

### Container won't start?
```bash
docker-compose logs server
```

### Clean everything
```bash
docker system prune -a --volumes
```

---

## Docker vs Podman

They're identical in usage. Just replace `docker-compose` with `podman-compose`:

```bash
podman-compose up
podman-compose down
podman-compose logs -f
```

---

For detailed info, see: `DOCKER.md`
