FROM nginx:alpine

LABEL maintainer="anderm@netcompany.com"

# Install curl
RUN apk add --update curl \
    && rm -rf /var/cache/apk/*

COPY certs/server.crt /etc/nginx/server.crt
COPY certs/server.key /etc/nginx/server.key
COPY nginx.conf /etc/nginx/nginx.conf

HEALTHCHECK --interval=10s --timeout=5s --retries=30 CMD curl -f --insecure https://localhost/login || exit 1

CMD ["nginx"]

