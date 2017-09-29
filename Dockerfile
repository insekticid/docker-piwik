FROM phpearth/php:7.1-nginx

MAINTAINER piwik@exploit.cz

ENV PHP_INI_DIR /etc/php/7.1
RUN mkdir -p $PHP_INI_DIR/conf.d && rm /etc/nginx/conf.d/default.conf 

RUN apk add --no-cache php7.1-gd php7.1-mbstring php7.1-intl php7.1-pdo_mysql make gnupg geoip-dev composer php7.1-apcu

RUN apk add --no-cache --virtual .build-deps php7.1-dev gcc g++ \
    && pecl install geoip-1.1.1 \
    && rm -rf /tmp/* /var/cache/apk/* \
    && apk del .build-deps
    #&& pecl clear-cache

ENV PIWIK_VERSION 3.1.1

RUN curl -fsSL -o piwik.tar.gz \
      "https://builds.piwik.org/piwik-${PIWIK_VERSION}.tar.gz" \
 && curl -fsSL -o piwik.tar.gz.asc \
      "https://builds.piwik.org/piwik-${PIWIK_VERSION}.tar.gz.asc" \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys 814E346FA01A20DBB04B6807B5DBD5925590A237 \
 && gpg --batch --verify piwik.tar.gz.asc piwik.tar.gz \
 && rm -r "$GNUPGHOME" piwik.tar.gz.asc \
 && tar -xzf piwik.tar.gz -C /var/www/html \
 && rm piwik.tar.gz

COPY php.ini /etc/php/7.1/conf.d/php.ini

RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.1/php-fpm.d/www.conf && \
    #sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php/7.1/php-fpm.d/www.conf && \
    #sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /etc/php/7.1/php-fpm.d/www.conf && \
    #sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /etc/php/7.1/php-fpm.d/www.conf && \
    #sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" /etc/php/7.1/php-fpm.d/www.conf && \
    #sed -i -e "s/pm.max_requests = 500/pm.max_requests = 1000/g" /etc/php/7.1/php-fpm.d/www.conf && \
    sed -i -e "s/;pm.status_path = \/status/pm.status_path = \/status/g" /etc/php/7.1/php-fpm.d/www.conf && \
    sed -i -e "s/;ping.path = \/ping/ping.path = \/ping/g" /etc/php/7.1/php-fpm.d/www.conf && \
    sed -i -e "s/;clear_env = no/clear_env = no/g" /etc/php/7.1/php-fpm.d/www.conf && \
    sed -i -e "s/;ping.response = pong/ping.response = pong/g" /etc/php/7.1/php-fpm.d/www.conf

RUN mkdir -p /usr/local/share/GeoIP && curl -fsSL -o /usr/local/share/GeoIP/GeoIPCity.dat.gz https://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz \
 && gunzip /usr/local/share/GeoIP/GeoIPCity.dat.gz

COPY nginx.conf /etc/nginx/
COPY sites-available/* /etc/nginx/sites-available/
#COPY docker-entrypoint.sh /entrypoint.sh

RUN chown -R www-data:www-data /var/www/html /var/tmp/nginx

WORKDIR /var/www/html
# "/entrypoint.sh" will populate it at container startup from /usr/src/piwik
VOLUME /var/www/html

#ENTRYPOINT ["/entrypoint.sh"]

#EXPOSE 9000