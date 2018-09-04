FROM nginx:alpine

LABEL maintainer="anderm@netcompany.com"

ADD certs/server.crt /etc/nginx/server.crt
ADD certs/server.key /etc/nginx/server.key

COPY nginx.conf /etc/nginx/nginx.conf

# Install curl
RUN apk add --update curl

HEALTHCHECK --interval=10s --timeout=5s --retries=30 CMD curl -f --insecure https://localhost/login || exit 1

CMD ["nginx"]

