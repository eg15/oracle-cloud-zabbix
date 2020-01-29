#!/bin/bash

COMPOSE="/usr/local/bin/docker-compose --no-ansi"

$COMPOSE up -d --build && $COMPOSE kill -s HUP zabbix-nginx
