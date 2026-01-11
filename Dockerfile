# 1. Use Node 20 as the base (Hyperbook needs a modern Node version)
FROM node:20-alpine AS builder
WORKDIR /app

# 2. Install dependencies (This replaces the "yarn" or "npm install" step)
COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile

# 3. Copy the rest of the code
COPY . .

# 4. Build the app (This prepares it for production)
RUN yarn build

# 5. Production Runner
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Copy only the necessary files from the builder
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

# 6. Start the server (This replaces "yarn dev" with the faster "yarn start")
CMD ["yarn", "start"]
