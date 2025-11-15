# Stage 1: Production runtime
FROM node:18-alpine

WORKDIR /app

# Install serve to run React app
RUN npm install -g serve

# Copy pre-built dist folder
COPY dist ./dist

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/ || exit 1

# Start app
CMD ["serve", "-s", "dist", "-l", "3000"]
