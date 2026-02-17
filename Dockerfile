# ---- deps ----
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# RUN npm run build

# ---- production ----
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# uniquement les deps prod
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# copie du code (ou du build si TypeScript)
COPY --from=build /app ./

# Sécurité: user non-root (optionnel mais recommandé)
RUN addgroup -S app && adduser -S app -G app
USER app

# adapte le port si ton app utilise autre chose
EXPOSE 3000
CMD ["npm","start"]
