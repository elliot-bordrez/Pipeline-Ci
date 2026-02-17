# ---- Dependencies stage ----
FROM node:20-alpine AS deps
WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer UNIQUEMENT les dépendances de production
# Cela exclut cross-spawn, glob, tar qui sont dans devDependencies
RUN npm ci --omit=dev --ignore-scripts && \
    npm cache clean --force

# ---- Production stage ----
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Copier les node_modules de production depuis le stage deps
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/package*.json ./

# Copier le code source
COPY . .

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -S app && adduser -S app -G app && \
    chown -R app:app /app

USER app

EXPOSE 3000

# Utiliser node directement au lieu de npm start
CMD ["node", "./bin/www"]
