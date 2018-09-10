#!/bin/bash
set -e

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
