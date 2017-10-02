How to run
--------------

1. build image: `docker build --pull -t piwik -f Dockerfile`
1. run: `docker run -p 80:80 -v "/srv/docker/volumes/piwik/config:/var/www/html/piwik/config" piwik`

Ideal setup for rancher
-----------------------

docker-compose.yml
-------------------
```
version: '2'
services:
  configuration:
    image: rawmind/alpine-volume:0.0.2-1
    environment:
      SERVICE_GID: '10001'
      SERVICE_UID: '10001'
      SERVICE_VOLUME: /var/www/html/piwik/config
    volumes:
    - PIWIK:/var/www/html/piwik/config
    labels:
      io.rancher.container.start_once: 'true'
      io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
      io.rancher.container.hostname_override: container_name
      io.rancher.container.pull_image: always
  piwik:
    image: insekticid/docker-piwik
    stdin_open: true
    links:
    - db
    tty: true
    volumes_from:
    - configuration
    labels:
      io.rancher.sidekicks: configuration
      io.rancher.container.hostname_override: container_name
      io.rancher.container.pull_image: always
  db:
      image: percona:5.7
      restart: "always"
      environment:
          - MYSQL_DATABASE=${MYSQL_DATABASE}
          - MYSQL_USER=${MYSQL_USER}
          - MYSQL_PASSWORD=${MYSQL_PASSWORD}
          - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
          - TZ=${WORKSPACE_TIMEZONE:-Europe/Prague}
          - LOCALE=cs_CZ
          - LANG=cs_CZ.utf8
      #env_file: .env
      volumes:
        - percona:/var/lib/mysql
```