#!/bin/bash
set -e

mkdir -p config config/environment
chown -R www-data:www-data config/

if [ $CRON_ENABLED ]; then
	bash -c '
	bash -s <<EOF
	trap "break;exit" SIGHUP SIGINT SIGTERM
	while /bin/true; do
	  su -s "/bin/bash" -c "php /var/www/html/piwik/console core:archive" www-data
	  sleep 600
	done
	EOF' & exec "$@"

	wait
else
	exec "$@"
fi
