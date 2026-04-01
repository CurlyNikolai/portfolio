#  BASE
FROM node:20-alpine AS base

WORKDIR /app

# Disable Atro telemetry
ENV ASTRO_TELEMETRY_DISABLED=1

# Copy dependency manifests first (layer cache — only reinstalls when these change)
COPY package.json package-lock.json* ./

# Install all dependencies (including devDeps needed by Astro's build)
RUN npm install
RUN npx astro telemetry disable

#  Dev stage
#  docker build --target dev -t portfolio-dev .
#  docker run -p 4321:4321 -v $(pwd)/src:/app/src portfolio-dev
FROM base AS dev

# Copy the full project
COPY . .

EXPOSE 4321

# --host 0.0.0.0 makes the dev server reachable outside the container
CMD ["npx", "astro", "dev", "--host", "0.0.0.0", "--port", "4321"]


#  Build stage
#  Compiles the static site into /app/dist
#  Run standalone: docker build --target build -t portfolio-build .
FROM base AS build

COPY . .

RUN npm run build


#  Deploy stage
#  Minimal nginx image — only the compiled dist
#  is copied in; Node.js is not present at all.
#
#  Build:  docker build -t portfolio .
#  Run:    docker run -p 8080:80 portfolio
# ─────────────────────────────────────────────
FROM nginx:1.27-alpine AS deploy

# Remove the default nginx placeholder page
RUN rm -rf /usr/share/nginx/html/*

# Pull in the compiled static files from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Custom nginx config: SPA-friendly routing + gzip + security headers
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]