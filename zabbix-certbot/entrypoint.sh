#!/bin/sh

[ -z "$ZABBIX_SERVER_NAME" ] && { >&2 echo "ZABBIX_SERVER_NAME is not defined, aborting."; exit 1; }
[ -z "$CERTBOT_EMAIL" ] && { >&2 echo "CERTBOT_EMAIL is not defined, aborting."; exit 1; }

if [ $# -eq 0 ]; then
    # /etc/letsencrypt/live/ZABBIX_SERVER_NAME/fullchain.pem
    # /etc/letsencrypt/live/ZABBIX_SERVER_NAME/privkey.pem
    if [ ! -f "/etc/letsencrypt/live/$ZABBIX_SERVER_NAME/fullchain.pem" ]; then
        certbot certonly --webroot --webroot-path=/var/www/html --email $CERTBOT_EMAIL --agree-tos -d $ZABBIX_SERVER_NAME
    else
        certbot renew
    fi
else
    certbot "$@"
fi
