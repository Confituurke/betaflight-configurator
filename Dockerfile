# Multi-stage build for production deployment
FROM node:20.19.4-alpine AS builder

# Set working directory
WORKDIR /app

# Install system dependencies for building
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    && rm -rf /var/cache/apk/*

# Copy package files
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile --production=false

# Copy source code
COPY . .

# Initialize git repository to satisfy Vite config requirements
RUN git init && \
    git config user.email "build@docker.local" && \
    git config user.name "Docker Build" && \
    git add . && \
    git commit -m "Initial commit for build"

# Build the application
RUN yarn build

# Production stage - use a simple HTTP server
FROM node:20.19.4-alpine AS production

# Install curl for health checks
RUN apk add --no-cache curl

# Install serve globally to serve static files
RUN npm install -g serve

# Copy built application from builder stage
COPY --from=builder /app/src/dist /app/dist

# Create a simple health check endpoint
RUN echo '<!DOCTYPE html><html><head><title>Health Check</title></head><body><h1>OK</h1></body></html>' > /app/dist/health

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Set proper permissions
RUN chown -R nextjs:nodejs /app

# Switch to non-root user
USER nextjs

# Expose port 8080 (Coolify standard)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start the application using serve
CMD ["serve", "-s", "/app/dist", "-l", "8080"]
