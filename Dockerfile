# ---- Dependencies stage ----
FROM node:20-alpine AS deps
WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer toutes les dépendances (dev + prod)
RUN npm ci

# ---- Build stage (si nécessaire pour compilation) ----
FROM node:20-alpine AS builder
WORKDIR /app

# Copier les node_modules depuis deps
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Si vous avez un build step, décommentez :
# RUN npm run build

# ---- Production stage ----
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Copier uniquement les fichiers nécessaires
COPY package*.json ./

# Installer UNIQUEMENT les dépendances de production
RUN npm ci --omit=dev --ignore-scripts

# Copier le code source
COPY . .

# Copier les node_modules de production si nécessaire
# (ou utiliser ceux installés juste au-dessus)

# Nettoyage du cache npm
RUN npm cache clean --force

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -S app && adduser -S app -G app && \
    chown -R app:app /app

USER app

EXPOSE 3000

CMD ["node", "./bin/www"]