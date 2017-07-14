#Supported tags and respective `Dockerfile` link

- [`latest` (*master/Dockerfile*)](https://github.com/glimberger/docker-php/blob/master/Dockerfile))
- [`php 5.6 - apache` (*php5.6-apache/Dockerfile*)](https://github.com/glimberger/docker-php/blob/php5.6-apache/Dockerfile))
- [`php 7.1 - apache` (*php5.6-apache/Dockerfile*)](https://github.com/glimberger/docker-php/blob/php7.1-apache/Dockerfile))


Contains:

- PHP (from official [php-apache](https://hub.docker.com/_/php/)) with extensions (mysql , pgsql, opcache, intl, apcu, xdebug)
- Apache 2 httpd
- Composer
- NodeJS + yarn + bower


**Env variables:**

- `ICU_MAJOR_VERSION` & `ICU_MINOR_VERSION` (default to `58` & `2`)
- `APCU_VERSION` (default to `4.0.7`)
- `NODE_VERSION` (default to `7.10.1`)
- `YARN_VERSION` (default to `0.24.6`)

Define env variables can be changed on build   
For example to update nodejs to version 8.x :
````
docker build /path/to/Dockerfile/directory --build-arg NODE_VERSION=8.1.4 -t web
````


**Notes**

- Symfony `sf` alias to `php bin/console`

