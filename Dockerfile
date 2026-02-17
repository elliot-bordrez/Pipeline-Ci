# ---- Dependencies stage ----
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm install

# ---- Production stage ----
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

RUN node -v && which npm && npm -v

# Installer uniquement les deps prod
COPY package*.json ./
RUN npm install --omit=dev

# Copier le reste du code
COPY . .

# Nettoyage
RUN npm cache clean --force

# Sécurité : user non-root
RUN addgroup -S app && adduser -S app -G app
USER app

EXPOSE 3000

CMD ["npm", "start"]
