# ---- deps (dev deps for tests/build if needed) ----
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm install

# ---- prod-deps (only prod deps, with build tooling if native modules) ----
FROM node:20-alpine AS prod-deps
WORKDIR /app
COPY package*.json ./

# Outils nécessaires si des dépendances ont des modules natifs
RUN apk add --no-cache python3 make g++ \
  && npm install --omit=dev \
  && npm cache clean --force \
  && apk del python3 make g++

# ---- runner ----
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Copie uniquement les deps prod déjà installées
COPY --from=prod-deps /app/node_modules ./node_modules
COPY . .

# Sécurité: user non-root
RUN addgroup -S app && adduser -S app -G app
USER app

EXPOSE 3000
CMD ["npm","start"]
