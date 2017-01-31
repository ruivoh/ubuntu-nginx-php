FROM ubuntu:latest

MAINTAINER Joao Gabriel C. Laass <gabriel@orangepixel.com.br>

# Configure Ubuntu Language
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install packages
RUN apt-get update \
    && apt-get install -y \
        curl zip unzip git nginx supervisor nano htop \    
        php7.0 php7.0-bcmath php7.0-cli php7.0-fpm php7.0-gd php7.0-gmp php7.0-intl \
        php7.0-json php7.0-xml php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-opcache php7.0-bz2 php-pear \
        php-mysql php7.0-pspell php7.0-xml php7.0-zip php7.0-readline php7.0-curl php7.0-sqlite3 php7.0-soap \
        php-imagick imagemagick \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && mkdir /run/php \
    && apt-get clean
    
    #&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure Nginx
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/default /etc/nginx/sites-enabled/default

# Configure PHP-FPM
COPY config/php/php.ini /etc/php7/conf.d/zzz_custom.ini
COPY config/php/www.conf /etc/php/7.0/fpm/pool.d/www.conf

# Configure Supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN journalctl --vacuum-time=2d && journalctl --vacuum-size=500M

RUN mkdir -p /var/www/src
WORKDIR /var/www/src
COPY src/ /var/www/src/

EXPOSE 80 443
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]