FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY tsconfig.json next.config.ts postcss.config.mjs ./
COPY public/ ./public/
COPY app/ ./app/
COPY components/ ./components/
RUN npm run build

FROM node:22-alpine AS development
WORKDIR /app
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 --ingroup nodejs nextjs && \
    chown -R nextjs:nodejs /app
COPY --from=build --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --chown=nextjs:nodejs tsconfig.json next.config.ts postcss.config.mjs ./
COPY --chown=nextjs:nodejs public/ ./public/
COPY --chown=nextjs:nodejs app/ ./app/
COPY --chown=nextjs:nodejs components/ ./components/
COPY --chown=nextjs:nodejs package.json ./
USER nextjs
EXPOSE 3000
ENV NODE_ENV=development
CMD ["npm", "run", "dev"]

FROM node:22-alpine AS production
WORKDIR /app
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 --ingroup nodejs nextjs
COPY --from=deps --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=build --chown=nextjs:nodejs /app/.next ./.next
COPY --from=build --chown=nextjs:nodejs /app/public ./public
COPY --from=build --chown=nextjs:nodejs /app/package.json ./
COPY --from=build --chown=nextjs:nodejs /app/next.config.ts ./
USER nextjs
EXPOSE 3000
ENV NODE_ENV=production
CMD ["node_modules/.bin/next", "start"]
