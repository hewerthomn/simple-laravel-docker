FROM ubuntu:20.04
LABEL maintainer="Éverton Inocêncio <https://github.com/hewerthomn/simple-laravel-docker>"
LABEL description="Laravel Docker"

ENV DEBIAN_FRONTEND noninteractive
ENV COMPOSER_CACHE_DIR '/var/cache'
ENV PATH "$PATH:/root/.composer/vendor/bin"

# Setup Ondrej PHP repository
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ondrej/php

RUN apt-get update && \
    apt-get -qy install \
    build-essential \
    curl \
    git \
    nginx \
    supervisor \
    unzip \
    php7.4 \
    php7.4-fpm \
    php7.4-cli \
    php7.4-mbstring \
    php7.4-mysql \
    php7.4-redis \
    php7.4-xdebug \
    php7.4-xml\
    php7.4-zip \
    php7.4-ctype \
    --no-install-recommends \
    && apt-get clean all \
    && rm -r /var/lib/apt/lists/*

# setup dir php
RUN mkdir -p /var/run/php && \
    mkdir -p /var/log/php-fpm

WORKDIR /

# Setup Composer
RUN curl -ksS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer

RUN composer --version

# Setup nginx
ADD files/site.conf /etc/nginx/sites-enabled/site.conf
ADD files/nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default


# Xdebug setup
RUN phpenmod -v 7.4 -s fpm xdebug && \
     phpdismod -v 7.4 -s cli xdebug && \
     echo 'xdebug.idekey=PHPSTORM' >> /etc/php/7.4/fpm/conf.d/20-xdebug.ini && \
     echo 'xdebug.remote_enable=1' >> /etc/php/7.4/fpm/conf.d/20-xdebug.ini && \
     echo 'xdebug.remote_connect_back=1' >> /etc/php/7.4/fpm/conf.d/20-xdebug.ini && \
     echo 'xdebug.remote_port=9001' >> /etc/php/7.4/fpm/conf.d/20-xdebug.ini

# Setup upload size
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1000M/' /etc/php/7.4/fpm/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 1000M/' /etc/php/7.4/fpm/php.ini && \
    sed -i 's/memory_limit = 128M/memory_limit = 2048M/' /etc/php/7.4/fpm/php.ini


# Setup php-fpm optimizations
RUN sed -i 's/pm.max_children = 5/pm.max_children = 100/' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/pm.start_servers = 2/pm.start_servers = 20/' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 20/' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 35/' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/;pm.max_requests = 500/pm.max_requests = 500/' /etc/php/7.4/fpm/pool.d/www.conf


# Setup node
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs
# Setup npm
RUN npm config set cache-folder /var/cache


# Setup Supervisor
RUN mkdir -p /var/log/supervisor
COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN apt remove -y \
    build-essential \
    && apt autoremove -y

USER root
WORKDIR /var/www/html

EXPOSE 80

COPY --chown=www-data files/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
