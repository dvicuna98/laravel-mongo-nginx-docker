FROM php:8.2-fpm-alpine3.17

RUN apk add --no-cache linux-headers gcc g++ autoconf make pkgconfig git openssl \
    libpng-dev libzip libzip-dev \
    libressl curl-dev zip unzip supervisor nginx bash \
    && docker-php-ext-install pdo pdo_mysql \
    && docker-php-ext-install sockets

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN docker-php-ext-install gd
RUN docker-php-ext-install zip

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

COPY ./etc/docker/nginx/default.conf /etc/nginx/http.d/default.conf
COPY ./etc/docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./etc/docker/supervisord.conf /etc/supervisord.conf

WORKDIR /app

COPY . .

RUN composer install --ignore-platform-reqs --no-scripts

RUN mkdir -p /run/nginx \
    && chown -R www-data:www-data /run/nginx \
    && mkdir -p /run/supervisord/log \
    && chown -R www-data:www-data /run/supervisord

EXPOSE 8080

CMD ["supervisord"]
