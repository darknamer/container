#!/bin/sh
set -e

NGINX_WORKER_PROCESSES=${NGINX_WORKER_PROCESSES:-auto}
NGINX_LISTEN_PORT=${NGINX_LISTEN_PORT:-80}

PHP_FPM_MAX_CHILDREN=${PHP_FPM_MAX_CHILDREN:-16}

LARAVEL_HORIZON_ENABLE=${LARAVEL_HORIZON_ENABLE:-no}
LARAVEL_SCHEDULE_ENABLE=${LARAVEL_SCHEDULE_ENABLE:-no}

sed -i -r "s/worker_processes\s+(auto|\d+)/worker_processes $NGINX_WORKER_PROCESSES/g" /etc/nginx/nginx.conf
sed -i -r "s/listen\s+(\[::\]:)?(\d+)\s+default_server/listen \1$NGINX_LISTEN_PORT default_server/g" /etc/nginx/conf.d/default.conf

sed -i -r "s/pm.max_children\s=\s(\d+)/pm.max_children = $PHP_FPM_MAX_CHILDREN/g" /usr/local/etc/php-fpm.d/zzz-docker.conf

if [ "$LARAVEL_HORIZON_ENABLE" = "yes" ]; then
    cp -f /etc/supervisor.d/horizon.stub /etc/supervisor.d/horizon.ini
fi

if [ "$LARAVEL_SCHEDULE_ENABLE" = "yes" ]; then
    count=`crontab -l | grep "php artisan schedule:run" | wc -l`

    if [ "$count" -le 0 ]; then
        (crontab -l; echo "* * * * * cd /var/www/html && php artisan schedule:run >> /dev/null 2>&1") | crontab -
    fi

    crond -L /dev/stdout
fi

exec "$@"
