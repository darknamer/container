FROM php:8.0-fpm-alpine3.15

LABEL maintainer="darknamer@gmail.com"

# FROM https://github.com/nginxinc/docker-nginx
ENV NGINX_VERSION 1.20.2
ENV NJS_VERSION   0.7.3
ENV PKG_RELEASE   1

RUN set -x \
# create nginx user/group first, to be consistent throughout docker variants
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apkArch="$(cat /etc/apk/arch)" \
    && nginxPackages=" \
        nginx=${NGINX_VERSION}-r${PKG_RELEASE} \
        nginx-module-xslt=${NGINX_VERSION}-r${PKG_RELEASE} \
        nginx-module-geoip=${NGINX_VERSION}-r${PKG_RELEASE} \
        nginx-module-image-filter=${NGINX_VERSION}-r${PKG_RELEASE} \
        nginx-module-njs=${NGINX_VERSION}.${NJS_VERSION}-r${PKG_RELEASE} \
    " \
    && case "$apkArch" in \
        x86_64) \
# arches officially built by upstream
            set -x \
            && KEY_SHA512="e7fa8303923d9b95db37a77ad46c68fd4755ff935d0a534d26eba83de193c76166c68bfe7f65471bf8881004ef4aa6df3e34689c305662750c0172fca5d8552a *stdin" \
            && apk add --no-cache --virtual .cert-deps \
                openssl \
            && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
            && if [ "$(openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout | openssl sha512 -r)" = "$KEY_SHA512" ]; then \
                echo "key verification succeeded!"; \
                mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
            else \
                echo "key verification failed!"; \
                exit 1; \
            fi \
            && apk del .cert-deps \
            && apk add -X "https://nginx.org/packages/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache $nginxPackages \
            ;; \
        *) \
# we're on an architecture upstream doesn't officially build for
# let's build binaries from the published packaging sources
            set -x \
            && tempDir="$(mktemp -d)" \
            && chown nobody:nobody $tempDir \
            && apk add --no-cache --virtual .build-deps \
                gcc \
                libc-dev \
                make \
                openssl-dev \
                pcre-dev \
                zlib-dev \
                linux-headers \
                libxslt-dev \
                gd-dev \
                geoip-dev \
                perl-dev \
                libedit-dev \
                mercurial \
                bash \
                alpine-sdk \
                findutils \
            && su nobody -s /bin/sh -c " \
                export HOME=${tempDir} \
                && cd ${tempDir} \
                && hg clone https://hg.nginx.org/pkg-oss \
                && cd pkg-oss \
                && hg up -r 494 \
                && cd alpine \
                && make all \
                && apk index -o ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz ${tempDir}/packages/alpine/${apkArch}/*.apk \
                && abuild-sign -k ${tempDir}/.abuild/abuild-key.rsa ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz \
                " \
            && cp ${tempDir}/.abuild/abuild-key.rsa.pub /etc/apk/keys/ \
            && apk del .build-deps \
            && apk add -X ${tempDir}/packages/alpine/ --no-cache $nginxPackages \
            ;; \
    esac \
# if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
    && if [ -n "$tempDir" ]; then rm -rf "$tempDir"; fi \
    && if [ -n "/etc/apk/keys/abuild-key.rsa.pub" ]; then rm -f /etc/apk/keys/abuild-key.rsa.pub; fi \
    && if [ -n "/etc/apk/keys/nginx_signing.rsa.pub" ]; then rm -f /etc/apk/keys/nginx_signing.rsa.pub; fi \
# Bring in gettext so we can get `envsubst`, then throw
# the rest away. To do this, we need to install `gettext`
# then move `envsubst` out of the way so `gettext` can
# be deleted completely, then move `envsubst` back.
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    \
    && runDeps="$( \
        scanelf --needed --nobanner /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache $runDeps \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/ \
# Bring in tzdata so users could set the timezones through the environment
# variables
    && apk add --no-cache tzdata \
# Bring in curl and ca-certificates to make registering on DNS SD easier
    && apk add --no-cache curl ca-certificates \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/conf.d/ /etc/nginx/conf.d/

# FIX https://github.com/docker-library/php/issues/240
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Install PHP extensions
RUN set -eux \
    && apk add --no-cache \
        # intl
        icu-libs \
        libintl \
        # zip
        libzip \
        # imagick
        imagemagick \
        imagemagick-libs \
        # PostgreSQL
        libpq \
        postgresql-libs \
        postgresql-dev \
        # xsl
        libxslt

RUN set -eux \
    && apk add --no-cache --virtual .build-php-deps \
        $PHPIZE_DEPS \
        # gd
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        # gettext
        gettext-dev \
        # intl
        icu-dev \
        # xml
        libxml2-dev \
        ldb-dev \
        # zip
        libzip-dev \
        # apcu
        pcre-dev \
        # imagick
        imagemagick-dev \
        # pdo_mysql
        mysql-client \
        # xsl \
        libxslt-dev \
        libgcrypt-dev \
    && docker-php-ext-configure bcmath --enable-bcmath \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure gettext \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure soap \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure mysqli \
    && docker-php-ext-configure pdo_mysql \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-configure pdo_pgsql \
    && pecl install apcu \
    && pecl install imagick \
    && pecl install redis \
    && docker-php-ext-install -j$(nproc) bcmath \
        gd \
        gettext \
        intl \
        # iconv \
        opcache \
        pcntl \
        soap \
        zip \
        exif \
        mysqli \
        pgsql \
        pdo_mysql \
        pdo_pgsql \
        xsl \
    && docker-php-ext-enable apcu \
        imagick \
        redis \
    && apk del .build-php-deps \
    && php -m

# sed -r -i='' 's/post_max_size = 8M/post_max_size = 1G/g' /usr/local/etc/php/php.ini
# sed -r -i='' 's/upload_max_filesize = 2M/upload_max_filesize = 1G/g' /usr/local/etc/php/php.ini
# sed -r -i='' 's/max_file_uploads = 20/max_file_uploads = 100/g' /usr/local/etc/php/php.ini

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY config/php/conf.d/ /usr/local/etc/php/conf.d/
COPY config/php-fpm.d/ /usr/local/etc/php-fpm.d/
COPY config/php/cacert.pem "$PHP_INI_DIR/cacert.pem"

RUN echo $'opcache.enable=1\n\
opcache.enable_cli=1\n\
opcache.revalidate_freq=0\n\
opcache.validate_timestamps=0\n\
opcache.max_accelerated_files=10000\n\
opcache.memory_consumption=128\n\
opcache.interned_strings_buffer=16' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini;

# Install supervisor
RUN set -eux && apk add --no-cache supervisor
RUN set -eux && mkdir -p /var/log/supervisor

COPY config/supervisor/supervisord.conf /etc/supervisord.conf
COPY config/supervisor/supervisor.d/ /etc/supervisor.d/

# Config entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

RUN ls -la /var/www/html
RUN sed -r -i='' 's/post_max_size = 8M/post_max_size = 1G/g' /usr/local/etc/php/php.ini
RUN sed -r -i='' 's/upload_max_filesize = 2M/upload_max_filesize = 1G/g' /usr/local/etc/php/php.ini
RUN sed -r -i='' 's/max_file_uploads = 20/max_file_uploads = 100/g' /usr/local/etc/php/php.ini

# RUN sed -r -i='' 's/curl.cainfo=/curl.cainfo = $PHP_INI_DIR/cacert.pem/g' /usr/local/etc/php/php.ini
# RUN sed -r -i='' 's/openssl.cafile=/openssl.cafile = $PHP_INI_DIR/cacert.pem/g' /usr/local/etc/php/php.ini

EXPOSE 80
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
