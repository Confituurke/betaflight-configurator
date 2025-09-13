# Use Node.js 20.19.4 as specified in .nvmrc
FROM node:20.19.4-alpine

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    && rm -rf /var/cache/apk/*

# Yarn is already included in the Node.js Alpine image, so we don't need to install it

# Copy package files
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy source code
COPY . .

# Configure Git to trust the repository (needed for Vite config)
RUN git config --global --add safe.directory /app

# Expose the development server port
EXPOSE 8000

# Expose the preview server port
EXPOSE 8080

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Change ownership of the app directory to the nodejs user
RUN chown -R nextjs:nodejs /app

# Configure Git for the nextjs user as well
USER nextjs
RUN git config --global --add safe.directory /app

# Default command for development
CMD ["yarn", "dev", "--host", "0.0.0.0"]
