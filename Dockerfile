FROM php:fpm-alpine

COPY docker-entrypoint.sh php.ini default.conf /
RUN apk add --no-cache \
        git \
        bash \
        nginx \
        tzdata \
        openssh && \
    mkdir -p /run/nginx && \
    mv /nginx-custom.template.conf /etc/nginx/conf.d && \
    mv /php.ini /usr/local/etc/php && \
    chmod +x /docker-entrypoint.sh && \
    git clone https://github.com/SomeBottle/OdIndex.git /var/www/html && \
    ssh-keygen -A

# Persistent config file
VOLUME [ "/var/www/html/config"]
ENTRYPOINT [ "/docker-entrypoint.sh" ]