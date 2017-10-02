#!/bin/bash
set -e

if [ ! -e config/global.php ]; then
	cp -r ../config.backup/* config/
	chown -R www-data:www-data config/
	echo "Piwik Config via copy"
	#tar cf - --one-file-system -C /var/www/html . | tar xf -
	#chown -R www-data .
fi

while /bin/true; do
	su -s "/bin/bash" -c "php /var/www/html/piwik/console core:archive" www-data
	sleep 3600
done

exec "$@"
