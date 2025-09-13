# Docker Development Setup

This document explains how to run the Betaflight Configurator in a Docker container for development purposes.

## Prerequisites

- Docker (version 20.10 or later)
- Docker Compose (version 2.0 or later)

## Quick Start

### 1. Development Server

To run the development server with hot reloading:

```bash
# Build and start the development container
docker-compose up --build

# Or run in detached mode
docker-compose up -d --build
```

The application will be available at:
- **Development server**: http://localhost:8000
- **Preview server**: http://localhost:8080

### 2. Stop the Container

```bash
# Stop the container
docker-compose down

# Stop and remove volumes (if needed)
docker-compose down -v
```

## Available Services

### Development Service (`betaflight-dev`)
- **Purpose**: Main development server with hot reloading
- **Ports**: 8000 (dev), 8080 (preview)
- **Command**: `yarn dev --host 0.0.0.0`
- **Features**: 
  - Source code mounted for live editing
  - Hot module replacement (HMR)
  - Accessible from host machine

### Test Service (`betaflight-test`)
- **Purpose**: Run tests in containerized environment
- **Command**: `yarn test`
- **Usage**: `docker-compose --profile test up betaflight-test`

### Build Service (`betaflight-build`)
- **Purpose**: Build production version
- **Command**: `yarn build`
- **Usage**: `docker-compose --profile build up betaflight-build`

## Development Workflow

### 1. First Time Setup

```bash
# Clone the repository (if not already done)
git clone https://github.com/betaflight/betaflight-configurator.git
cd betaflight-configurator

# Start the development environment
docker-compose up --build
```

### 2. Daily Development

```bash
# Start the development server
docker-compose up

# Make changes to your code - they will be reflected immediately
# The server supports hot reloading for most changes
```

### 3. Running Tests

```bash
# Run tests in Docker
docker-compose --profile test up betaflight-test

# Or run tests interactively
docker-compose run --rm betaflight-dev yarn test
```

### 4. Building for Production

```bash
# Build production version
docker-compose --profile build up betaflight-build

# Or build interactively
docker-compose run --rm betaflight-dev yarn build
```

## Advanced Usage

### Interactive Development

To get a shell inside the container for debugging or running additional commands:

```bash
# Get a shell in the running container
docker-compose exec betaflight-dev sh

# Or run a new container with shell
docker-compose run --rm betaflight-dev sh
```

### Custom Commands

You can run any yarn command in the container:

```bash
# Run linting
docker-compose run --rm betaflight-dev yarn lint

# Run linting with auto-fix
docker-compose run --rm betaflight-dev yarn lint:fix

# Install new dependencies
docker-compose run --rm betaflight-dev yarn add <package-name>

# Format code
docker-compose run --rm betaflight-dev yarn format
```

### Environment Variables

You can set environment variables in the `docker-compose.yml` file or use a `.env` file:

```bash
# Create .env file
echo "NODE_ENV=development" > .env
echo "DEBUG=true" >> .env
```

### Volume Mounts

The development setup mounts the entire project directory to `/app` in the container, excluding `node_modules` to avoid conflicts. This means:

- ✅ Code changes are reflected immediately
- ✅ Hot reloading works
- ✅ No need to rebuild for code changes
- ⚠️ `node_modules` is managed by the container

## Troubleshooting

### Port Already in Use

If ports 8000 or 8080 are already in use, modify the port mapping in `docker-compose.yml`:

```yaml
ports:
  - "3000:8000"  # Use port 3000 instead of 8000
  - "3001:8080"  # Use port 3001 instead of 8080
```

### Permission Issues

If you encounter permission issues with file creation:

```bash
# Fix ownership of files created by Docker
sudo chown -R $USER:$USER .
```

### Container Won't Start

1. Check if the container is already running:
   ```bash
   docker-compose ps
   ```

2. Check container logs:
   ```bash
   docker-compose logs betaflight-dev
   ```

3. Rebuild the container:
   ```bash
   docker-compose down
   docker-compose up --build --force-recreate
   ```

### Node Modules Issues

If you encounter issues with dependencies:

```bash
# Remove node_modules and rebuild
docker-compose down
docker-compose run --rm betaflight-dev rm -rf node_modules
docker-compose up --build
```

## Performance Tips

1. **Use .dockerignore**: The included `.dockerignore` file excludes unnecessary files from the build context, making builds faster.

2. **Volume Mounts**: The setup uses volume mounts for source code, so you don't need to rebuild for code changes.

3. **Layer Caching**: Dependencies are installed in a separate layer, so they're cached between builds.

## Security Notes

- The container runs as a non-root user (`nextjs`) for security
- Only necessary ports are exposed
- Source code is mounted read-write for development convenience

## Production Considerations

This Docker setup is designed for development. For production deployment, consider:

- Using multi-stage builds to reduce image size
- Running as read-only containers
- Using proper secrets management
- Implementing health checks
- Using production-optimized base images

## Contributing

When contributing to the project, please ensure that:

1. The Docker setup works with your changes
2. Tests pass in the containerized environment
3. The development server starts without errors
4. Hot reloading continues to work properly
