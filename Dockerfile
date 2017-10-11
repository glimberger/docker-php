FROM php:7.1-apache

LABEL maintainer="Guillaume Limberger <glim.dev@gmail.com>"


# Apache
# Enable rewrite module
RUN a2enmod rewrite

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
    && apt-get clean
# end COMMON -----------------------------------------------------------------------------------------------------------


# LOCALE ---------------------------------------------------------------------------------------------------------------
RUN sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr
ENV LC_ALL fr_FR.UTF-8
# end LOCALE -----------------------------------------------------------------------------------------------------------


# PGSQL LDAP XDEBUG OPCACHE LDAP ---------------------------------------------------------------------------------------
# https://github.com/docker-library/php/issues/75#issuecomment-82075678
RUN set -xe \
    && docker-php-ext-install pgsql pdo_pgsql \
    && pecl install xdebug \
	&& docker-php-ext-enable xdebug \
    && docker-php-ext-install opcache \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install ldap
# end PGSQL LDAP XDEBUG OPCACHE LDAP -----------------------------------------------------------------------------------


# ICU ------------------------------------------------------------------------------------------------------------------
ARG ICU_MAJOR_VERSION=58
ENV ICU_MAJOR_VERSION ${ICU_MAJOR_VERSION}

ARG ICU_MINOR_VERSION=2
ENV ICU_MINOR_VERSION ${ICU_MINOR_VERSION}

# https://github.com/docker-library/php/issues/307#issuecomment-262491765
RUN set -xe \
    && curl -sS -o /tmp/icu.tar.gz -L http://download.icu-project.org/files/icu4c/${ICU_MAJOR_VERSION}.${ICU_MINOR_VERSION}/icu4c-${ICU_MAJOR_VERSION}_${ICU_MINOR_VERSION}-src.tgz \
    && tar -zxf /tmp/icu.tar.gz -C /tmp \
    && cd /tmp/icu/source \
    && ./configure --prefix=/usr/local \
    && make \
    && make install \
    && docker-php-ext-configure intl --with-icu-dir=/usr/local \
    && docker-php-ext-install intl
# end ICU --------------------------------------------------------------------------------------------------------------


# APCU -----------------------------------------------------------------------------------------------------------------
ARG APCU_VERSION=5.1.8
ENV APCU_VERSION ${APCU_VERSION}

RUN set -xe \
    && pecl install apcu-${APCU_VERSION} \
    && docker-php-ext-enable apcu
# end APCU -------------------------------------------------------------------------------------------------------------


# COMPOSER -------------------------------------------------------------------------------------------------------------
# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER 1

COPY ./docker-install-composer.sh /usr/local/bin/install-composer
RUN set -xe \
    && chmod +x /usr/local/bin/install-composer \
    && install-composer \
    && mv composer.phar /usr/local/bin/composer \
    && chown -R www-data: /var/www \
    && mkdir -p /var/www/.composer \
    && chown -R www-data: /var/www/.composer \
    && mkdir -p /root/.composer \
    && chown -R www-data: /root/.composer \
    && composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-progress --no-suggest --optimize-autoloader --classmap-authoritative
# end COMPOSER ---------------------------------------------------------------------------------------------------------


# NODEJS ---------------------------------------------------------------------------------------------------------------
ARG NODE_VERSION=6.11.4
ENV NODE_VERSION ${NODE_VERSION}

COPY ./docker-install-node.sh /usr/local/bin/install-node
RUN set -xe \
    && chmod +x /usr/local/bin/install-node \
    && install-node
# end NODEJS -----------------------------------------------------------------------------------------------------------


# YARN -----------------------------------------------------------------------------------------------------------------
ARG YARN_VERSION=1.2.0
ENV YARN_VERSION ${YARN_VERSION}

COPY ./docker-install-yarn.sh /usr/local/bin/install-yarn
RUN set -ex \
   && chmod +x /usr/local/bin/install-yarn \
   && install-yarn
# end YARN -------------------------------------------------------------------------------------------------------------


# PHP INI --------------------------------------------------------------------------------------------------------------
ARG XDEBUG_REMOTE_HOST=localhost
ENV XDEBUG_REMOTE_HOST ${XDEBUG_REMOTE_HOST}
COPY ./php.ini /usr/local/etc/php/
RUN echo 'xdebug.remote_host=${XDEBUG_REMOTE_HOST}' >> /usr/local/etc/php/php.ini
# end PHP INI