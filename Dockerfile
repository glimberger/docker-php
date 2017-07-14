FROM php:7.1.6-apache

LABEL maintainer "Guillaume Limberger <glim.dev@gmail.com>"

# Apache
# Enable rewrite module
RUN a2enmod rewrite

RUN set -xe \
    && apt-get update \
    && apt-get install --no-install-recommends -y apt-utils git unzip vim wget libicu-dev libpq-dev libldap2-dev \
    && apt-get clean

RUN set -xe \

    # PDO extensions
    && docker-php-ext-install pgsql pdo_pgsql pdo_mysql \

    # Xdebug
    && pecl install xdebug \
	&& docker-php-ext-enable xdebug

ARG ICU_MAJOR_VERSION=58
ENV ICU_MAJOR_VERSION ${ICU_MAJOR_VERSION}

ARG ICU_MINOR_VERSION=2
ENV ICU_MINOR_VERSION ${ICU_MINOR_VERSION}

RUN set -xe \
    # https://github.com/docker-library/php/issues/307#issuecomment-262491765
    && curl -sS -o /tmp/icu.tar.gz -L http://download.icu-project.org/files/icu4c/${ICU_MAJOR_VERSION}.${ICU_MINOR_VERSION}/icu4c-${ICU_MAJOR_VERSION}_${ICU_MINOR_VERSION}-src.tgz \
    && tar -zxf /tmp/icu.tar.gz -C /tmp \
    && cd /tmp/icu/source \
    && ./configure --prefix=/usr/local \
    && make \
    && make install \
    && docker-php-ext-configure intl --with-icu-dir=/usr/local \
    && docker-php-ext-install intl

RUN set -xe \
    # APCu
    && docker-php-ext-install apcu \

    # opcache extension
    && docker-php-ext-install opcache \

    # Ldap
    # https://github.com/docker-library/php/issues/75#issuecomment-82075678
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install ldap

# Composer
COPY ./install-composer.sh /usr/local/bin/docker-app-install-composer
RUN set -xe \
    && chmod +x /usr/local/bin/docker-app-install-composer \
    && docker-app-install-composer \
    && mv composer.phar /usr/local/bin/composer


# Install composer cache
RUN set -xe \
    && chown -R www-data: /var/www \
    && mkdir -p /var/www/.composer \
    && chown -R www-data: /var/www/.composer \
    && mkdir -p /root/.composer \
    && chown -R www-data: /root/.composer

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-progress --no-suggest --optimize-autoloader --classmap-authoritative

# node.js
# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" ; \
  done

#ARG NODE_VERSION=7.10.1
ARG NODE_VERSION=8.1.4
ENV NODE_VERSION ${NODE_VERSION}

RUN set -ex \
  && curl -SLO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v${NODE_VERSION}-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v${NODE_VERSION}-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v${NODE_VERSION}-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ARG YARN_VERSION=0.27.5
ENV YARN_VERSION ${YARN_VERSION}

RUN set -ex \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" ; \
  done \
  && curl -fSL -o yarn.js "https://yarnpkg.com/downloads/${YARN_VERSION}/yarn-legacy-${YARN_VERSION}.js" \
  && curl -fSL -o yarn.js.asc "https://yarnpkg.com/downloads/${YARN_VERSION}/yarn-legacy-${YARN_VERSION}.js.asc" \
  && gpg --batch --verify yarn.js.asc yarn.js \
  && rm yarn.js.asc \
  && mv yarn.js /usr/local/bin/yarn \
  && chmod +x /usr/local/bin/yarn

COPY ./php.ini /usr/local/etc/php/

COPY ./post-install.sh /usr/local/bin/docker-app-post-install
RUN set -ex \
    && chmod +x /usr/local/bin/docker-app-post-install \
    && docker-app-post-install