#!/bin/bash
set -e

mkdir -p config config/environment
chown -R www-data:www-data config/
cp -r ../config.backup/global.ini.php config/
cp -r ../config.backup/global.php config/
cp -r ../config.backup/environment config/

if [ ! -e config/config.ini.php ]; then
	mkdir -p config
	chown -R www-data:www-data config/
	cp -r ../config.backup/* config/
	echo "Piwik Config via copy"
	#tar cf - --one-file-system -C /var/www/html . | tar xf -
	#chown -R www-data .
	
	exec "$@"
fi


bash -c '
bash -s <<EOF
trap "break;exit" SIGHUP SIGINT SIGTERM
while /bin/true; do
  su -s "/bin/bash" -c "php /var/www/html/piwik/console core:archive" www-data
  sleep 3600
done
EOF' & exec "$@"

wait