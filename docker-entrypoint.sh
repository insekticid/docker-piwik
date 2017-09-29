#!/bin/bash
set -e

if [ ! -e piwik.php ]; then
	tar cf - --one-file-system -C /var/www/html . | tar xf -
	chown -R www-data .
fi

exec "$@"
