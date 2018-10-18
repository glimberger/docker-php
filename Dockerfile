FROM php:7.2-apache

LABEL maintainer="Guillaume Limberger <glim.dev@gmail.com>"


# Apache
# Enable rewrite module
RUN a2enmod rewrite

# Fix server's fully qualified domain name
ARG APACHE_SERVERNAME=localhost
RUN echo "ServerName" $APACHE_SERVERNAME >> /etc/apache2/apache2.conf


# COMMON ---------------------------------------------------------------------------------------------------------------
RUN set -xe \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        locales \
        apt-utils \
        git \
        unzip \
        vim \
        wget \
        libicu-dev \
        libpq-dev \
        libldap2-dev \
        zlib1g-dev \
    && apt-get clean
# end COMMON -----------------------------------------------------------------------------------------------------------


# LOCALE ---------------------------------------------------------------------------------------------------------------
RUN sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr
ENV LC_ALL fr_FR.UTF-8
# end LOCALE -----------------------------------------------------------------------------------------------------------


# PGSQL LDAP XDEBUG OPCACHE BCMATH MBSTRING APCU LDAP ZIP --------------------------------------------------------------
# https://github.com/docker-library/php/issues/75#issuecomment-82075678
RUN set -xe \
    && docker-php-ext-install \
        pgsql \
        pdo_pgsql \
        zip \
    && pecl install xdebug apcu \
	&& docker-php-ext-enable xdebug apcu \
    && docker-php-ext-install \
        opcache \
        bcmath \
        mbstring \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install ldap
# end PGSQL LDAP XDEBUG OPCACHE BCMATH MBSTRING LDAP APCU ZIP ----------------------------------------------------------


# ICU ------------------------------------------------------------------------------------------------------------------
ARG ICU_MAJOR_VERSION=61
ARG ICU_MINOR_VERSION=1

# https://github.com/docker-library/php/issues/307#issuecomment-262491765
# https://github.com/docker-library/php/issues/455#issuecomment-309921509
RUN set -xe \
    && curl -sS -o /tmp/icu.tar.gz -L http://download.icu-project.org/files/icu4c/$ICU_MAJOR_VERSION.$ICU_MINOR_VERSION/icu4c-${ICU_MAJOR_VERSION}_${ICU_MINOR_VERSION}-src.tgz \
    && tar -zxf /tmp/icu.tar.gz -C /tmp \
    && cd /tmp/icu/source \
    && ./configure --prefix=/usr/local \
    && make \
    && make install \
    && rm -rf /tmp/icu*

# PHP_CPPFLAGS are used by the docker-php-ext-* scripts
ENV PHP_CPPFLAGS="$PHP_CPPFLAGS -std=c++11"

RUN set -xe \
    && docker-php-ext-configure intl --with-icu-dir=/usr/local \
    && docker-php-ext-install intl
# end ICU --------------------------------------------------------------------------------------------------------------


# COMPOSER -------------------------------------------------------------------------------------------------------------
COPY ./docker-install-composer.sh /usr/local/bin/install-composer
RUN chmod +x /usr/local/bin/install-composer
RUN set -xe \
    && install-composer
RUN mv composer.phar /usr/local/bin/composer \
    && chown -R www-data: /var/www \
    && mkdir -p /var/www/.composer \
    && chown -R www-data: /var/www/.composer \
    && mkdir -p /root/.composer \
    && chown -R www-data: /root/.composer

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN composer global require "hirak/prestissimo" --prefer-dist --no-progress --no-suggest --optimize-autoloader --classmap-authoritative
# end COMPOSER ---------------------------------------------------------------------------------------------------------


# NODEJS NVM ---------------------------------------------------------------------------------------------------------------
ARG NODE_VERSION=10.11.0
ARG NVM_DIR=/usr/local/nvm

# https://github.com/creationix/nvm#install-script
RUN mkdir $NVM_DIR && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# confirm installation
RUN node -v
RUN npm -v
# end NODEJS -----------------------------------------------------------------------------------------------------------


# YARN -----------------------------------------------------------------------------------------------------------------
ARG YARN_VERSION=1.10.1

COPY ./docker-install-yarn.sh /usr/local/bin/install-yarn
RUN chmod +x /usr/local/bin/install-yarn
RUN set -xe \
    && install-yarn
# end YARN -------------------------------------------------------------------------------------------------------------


# PHP INI --------------------------------------------------------------------------------------------------------------
ARG PHP_INI=php.ini
COPY $PHP_INI /usr/local/etc/php/
# end PHP INI ----------------------------------------------------------------------------------------------------------

# APACHE CONF ----------------------------------------------------------------------------------------------------------
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
# end APACHE CONF ------------------------------------------------------------------------------------------------------