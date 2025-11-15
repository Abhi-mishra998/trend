# Stage 1: Build React app
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build React app
RUN npm run build

# Stage 2: Production runtime
FROM node:18-alpine

WORKDIR /app

# Install serve to run React app
RUN npm install -g serve

# Copy built dist folder from builder stage
COPY --from=builder /app/dist ./dist

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/ || exit 1

# Start app
CMD ["serve", "-s", "dist", "-l", "3000"]

# dockerfile
# # Stage 1: Build
# FROM node:18-alpine AS builder
# WORKDIR /app
# COPY package*.json ./
# RUN npm ci
# COPY . .
# RUN npm run build

# # Stage 2: Runtime
# FROM node:18-alpine
# RUN npm install -g serve
# COPY --from=builder /app/dist /app/dist
# EXPOSE 3000
# HEALTHCHECK CMD wget --quiet --tries=1 --spider http://localhost:3000 || exit 1
# CMD ["serve", "-s", "dist", "-l", "3000"]

