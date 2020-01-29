#!/bin/bash

COMPOSE="/usr/local/bin/docker-compose --no-ansi"
DOCKER="/usr/bin/docker"

$COMPOSE run zabbix-certbot && $COMPOSE kill -s HUP zabbix-nginx
#$DOCKER system prune -af
