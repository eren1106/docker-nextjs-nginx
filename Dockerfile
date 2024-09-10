# Stage 1: Build stage
# Using a lightweight Node.js image (Alpine-based) for the build process
FROM node:18.17.0-alpine AS builder

# Set the working directory inside the container to /app
WORKDIR /app

# Copy package.json and package-lock.json files to the container
# This allows npm install to cache dependencies and avoid redundant downloads
COPY package*.json ./

# Install project dependencies specified in package.json
RUN npm install

# Copy all the source code from the host machine to the container
COPY . .

# Build the Next.js application for production (output will be in .next directory)
RUN npm run build

# Stage 2: Production stage
# Starting a new, clean Node.js Alpine-based image for running the app in production
FROM node:18.17.0-alpine

# Set the working directory to /app in the production image
WORKDIR /app

# Copy the necessary files from the build stage into this production image
# This includes Next.js build output (.next), public assets, node_modules, and configuration
COPY --from=builder /app/next.config.mjs ./next.config.mjs
# COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Command to run the Next.js application in production mode
CMD ["npm", "start"]
