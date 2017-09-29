How to run
--------------

1. build image: `docker build --pull -t piwik -f Dockerfile`
1. copy config files from image: `mkdir -p /srv/docker/volumes/piwik/config && docker run -d -name piwiksetup --rm piwik && docker cp piwiksetup:/var/www/html/piwik/config/ /srv/docker/volumes/piwik/ && docker stop piwiksetup`
1. run on port 80: `docker run -p 80:80 -v "/srv/docker/volumes/piwik/config:/var/www/html/piwik/config" piwik`