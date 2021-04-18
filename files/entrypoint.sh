#!/bin/bash

if [ "$APP_ENV" == "production" ] || [ "$APP_ENV" == "dev" ]; then
    php /var/www/html/artisan config:cache;
fi

/usr/bin/supervisord
