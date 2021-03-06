[![Docker Pulls](https://img.shields.io/docker/pulls/gl1m/docker-php.svg)](https://hub.docker.com/r/gl1m/docker-php/)
[![Docker Automated build](https://img.shields.io/docker/automated/gl1m/docker-php.svg)](https://hub.docker.com/r/gl1m/docker-php/)
[![Docker Build Status](https://img.shields.io/docker/build/gl1m/docker-php.svg)](https://hub.docker.com/r/gl1m/docker-php/)
[![GitHub last commit](https://img.shields.io/github/last-commit/glimberger/docker-php.svg)](https://github.com/glimberger/docker-php)

#Supported tags and respective `Dockerfile` link

- [`latest` `php7.3-apache` (*master/Dockerfile*)](https://github.com/glimberger/docker-php/blob/master/Dockerfile))
- [`php5.6-apache` (*php5.6-apache/Dockerfile*)](https://github.com/glimberger/docker-php/blob/php5.6-apache/Dockerfile))
- [`php7.1-apache` (*php7.1-apache/Dockerfile*)](https://github.com/glimberger/docker-php/blob/php7.1-apache/Dockerfile))


Contains:

- PHP (from official [php-apache](https://hub.docker.com/_/php/)) with extensions (mysql , pgsql, opcache, intl, apcu, xdebug)
- Apache 2 httpd
- [Composer](https://getcomposer.org/) + [hirak/prestissimo plugin](https://github.com/hirak/prestissimo)
- [Node.js](https://nodejs.org/en/) + [yarn](https://yarnpkg.com/lang/en/) + webpack


**Build args:**

- `NODE_VERSION` (default to `10.13.0`)
- `YARN_VERSION` (default to `1.16.0`)
- `PHP_INI` path to user-defined INI file (see [default user-defined php.ini](https://github.com/glimberger/docker-php/blob/master/php.ini))

**Example:**

To update Node.js to version 8.6.0:
````
docker build /path/to/Dockerfile/directory --build-arg NODE_VERSION=8.6.0 -t myapp
````
To replace the user-defined INI file:
````
docker build /path/to/Dockerfile/directory --build-arg PHP_INI=php.ini -t myapp
````

**Docker compose**

[Symfony stack example](https://gist.github.com/glimberger/50ee9b7f0340c41f3e7fefd402a05768)
