FROM php:8.0-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        default-mysql-client \
        libpng-dev \
        libzip-dev \
        unzip \
        zip \
        ssh-client \
        nodejs \
        sudo \
    && docker-php-ext-install \
        gd \
        pdo_mysql \
        zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "memory_limit=2G" > "$PHP_INI_DIR/conf.d/memory-limit.ini"

ARG user_uid

RUN if [ "$user_uid" = "" ]; then echo "no user_uid" ; else usermod -u $user_uid www-data; fi

# install composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer

# launch PHP FPM
CMD ["php-fpm"]
