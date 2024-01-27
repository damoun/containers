FROM composer:2.6.6@sha256:6d19e1002b091908fc4654725d4055125f181c1b6d7610206b0ee31b8419a5fc as composer

ARG PIXELFED_VERSION=0.11.9

RUN apk add -y --no-cache git
RUN git clone -b v${PIXELFED_VERSION} https://github.com/pixelfed/pixelfed.git /app
RUN rm -rf /app/.git* /app/.ddev /app/.circleci /app/tests

RUN composer install --no-ansi --no-interaction --optimize-autoloader --no-dev --no-progress --ignore-platform-reqs

FROM php:8.3.0-apache-bookworm@sha256:14acfecd6a6e414677bf8330ded6696a23b5b064e78fbbe7709098815ba46c51

LABEL org.opencontainers.image.description="Pixelfed is a free and ethical photo sharing platform, powered by ActivityPub federation."
LABEL org.opencontainers.image.licenses=AGPL-3.0-only

WORKDIR /var/www/

COPY --from=composer /app /var/www/

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
## Standard
      locales \
      locales-all \
      gosu \
      zip \
      unzip \
      libzip-dev \
      libcurl4-openssl-dev \
## Image Optimization
      optipng \
      pngquant \
      jpegoptim \
      gifsicle \
## Image Processing
      libjpeg62-turbo-dev \
      libpng-dev \
      libmagickwand-dev \
# Required for GD
      libxpm4 \
      libxpm-dev \
      libwebp7 \
      libwebp-dev \
## Video Processing
      ffmpeg \
## Database
      libpq-dev \
      libsqlite3-dev \
      mariadb-client

RUN sed -i '/en_US/s/^#//g' /etc/locale.gen && \
    locale-gen && \
    update-locale

RUN docker-php-source extract
RUN pecl install imagick redis && \
    docker-php-ext-enable imagick redis
RUN docker-php-ext-configure gd \
      --with-freetype \
      --with-jpeg \
      --with-webp \
      --with-xpm
RUN docker-php-ext-configure intl
RUN docker-php-ext-install -j$(nproc) gd pdo_mysql pdo_pgsql \
      pdo_sqlite intl bcmath zip pcntl exif curl

RUN a2enmod rewrite remoteip && \
    {\
      echo RemoteIPHeader X-Real-IP ;\
      echo RemoteIPTrustedProxy 10.0.0.0/8 ;\
      echo RemoteIPTrustedProxy 172.16.0.0/12 ;\
      echo RemoteIPTrustedProxy 192.168.0.0/16 ;\
      echo SetEnvIf X-Forwarded-Proto "https" HTTPS=on ;\
    } > /etc/apache2/conf-available/remoteip.conf && \
    a2enconf remoteip

RUN cp -r storage storage.skel
RUN cp contrib/docker/php.production.ini "${PHP_INI_DIR}/php.ini"

RUN php artisan horizon:publish

RUN docker-php-source delete && \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    rm -rf /var/cache/apt /var/lib/apt/lists/ /var/www/html/

RUN sed -i 's/\/var\/www\/html/\/var\/www\/public/g' /etc/apache2/sites-enabled/000-default.conf

RUN chown -R www-data:www-data /var/www/

CMD ["/var/www/contrib/docker/start.apache.sh"]
