#!/bin/bash

COMPOSE="/usr/local/bin/docker-compose --no-ansi"
DOCKER="/usr/bin/docker"

cd "$(dirname "${BASH_SOURCE[0]}")"

$COMPOSE run zabbix-certbot && $COMPOSE kill -s HUP zabbix-nginx
#$DOCKER system prune -af
