#!/bin/bash
set -e

if [ ! -d config ]; then
	cp -r ../config.backup/ config
	chown -R www-data:www-data config
	echo "Piwik Config via copy"
	#tar cf - --one-file-system -C /var/www/html . | tar xf -
	#chown -R www-data .
fi

exec "$@"
