FROM nginx:1.27-alpine

# Drop the stock default site
RUN rm /etc/nginx/conf.d/default.conf

# Our config + the actual content
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html
COPY robots.txt /usr/share/nginx/html/robots.txt
COPY assets    /usr/share/nginx/html/assets

EXPOSE 80

# Lightweight healthcheck Dokploy can use
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O- http://127.0.0.1/ > /dev/null || exit 1

# Default CMD from nginx:alpine — `nginx -g 'daemon off;'`
