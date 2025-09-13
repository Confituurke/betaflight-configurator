# Docker Deployment Guide

Simple deployment guide for the Betaflight Configurator using Docker.

## 🚀 Quick Start

### For Coolify

1. **Copy the content** from `docker-compose.yml`
2. **In Coolify**:
   - Go to your project
   - Add a new service
   - Choose "Docker Compose"
   - Paste the YAML content
   - Deploy

### For Manual Deployment

1. **Build and run**:
   ```bash
   docker-compose up --build
   ```

2. **Access the application** at `http://your-server:8080`

## 📋 What's Included

- **Dockerfile**: Multi-stage build for production
- **docker-compose.yml**: Simple deployment configuration
- **Health checks**: Built-in monitoring
- **Security**: Non-root user execution

## 🔧 Configuration

### Environment Variables

- `NODE_ENV=production`
- `PORT=8080`

### Ports

- **Internal**: 8080
- **External**: 8080 (configurable)

## 🚨 Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure port 8080 is available
2. **Build failures**: Check Docker build logs
3. **Health check failures**: Verify `/health` endpoint

### Debug Commands

```bash
# Check container status
docker ps

# View logs
docker logs betaflight-configurator

# Test health endpoint
curl http://localhost:8080/health
```

## 🔄 Updates

Push new code to your repository and trigger rebuild in your deployment platform.

## 📝 Notes

- Optimized for Coolify deployment
- No SSL configuration needed (handled by platform)
- Single container architecture
- Built-in health monitoring
