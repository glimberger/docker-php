#Supported tags and respective `Dockerfile` link

- [`latest` (*master/Dockerfile*)](https://github.com/glimberger/docker-php/blob/master/Dockerfile))
- [`php 5.6 - apache` (*php5.6-apache/Dockerfile*)](https://github.com/glimberger/docker-php/blob/php5.6-apache/Dockerfile))
- [`php 7.1 - apache` (*php7.1-apache/Dockerfile*)](https://github.com/glimberger/docker-php/blob/php7.1-apache/Dockerfile))


Contains:

- PHP (from official [php-apache](https://hub.docker.com/_/php/)) with extensions (mysql , pgsql, opcache, intl, apcu, xdebug)
- Apache 2 httpd
- Composer + [hirak/prestissimo plugin](https://github.com/hirak/prestissimo)
- Node.js (LTS v6.11.4) + yarn (v1.2.0) + gulp


**Env variables:**

- `ICU_MAJOR_VERSION` & `ICU_MINOR_VERSION` (default to `58` & `2`)
- `APCU_VERSION` (default to `4.0.7`)
- `NODE_VERSION` (default to `6.11.4`)
- `YARN_VERSION` (default to `1.2.1`)
- `XDEBUG_REMOTE_HOST` (default to `localhost`) must be set to your machine IP

Env variables can be set on build   
For example to update Node.js to version 8.6.0 :
````
docker build /path/to/Dockerfile/directory --build-arg NODE_VERSION=8.6.0 -t myapp
````


