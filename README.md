#Supported tags and respective `Dockerfile` link

- [`latest` (*master/Dockerfile*)](https://github.com/glimberger/docker-php/blob/master/Dockerfile))
- [`php 5.6 - apache` (*php5.6-apache/Dockerfile*)](https://github.com/glimberger/docker-php/blob/php5.6-apache/Dockerfile))


Contains:

- PHP (from official [php-apache](https://hub.docker.com/_/php/)) with extensions (mysql , pgsql, opcache, intl, apcu, xdebug)
- Apache 2 httpd
- Composer
- NodeJS + yarn + bower


Env variables:

- `ICUVERSION` (default to `58.2`)
- `ICU_VERSION` (default to `58_2`)
- `APCU_VERSION` (default to `4.0.7`)
- `COMPOSER_ALLOW_SUPERUSER` (default to `1`)
- `NODE_VERSION` (default to `7.10.0`)
- `YARN_VERSION` (default to `0.24.6`)

#Notes

- Symfony `sf` alias to `php bin/console`