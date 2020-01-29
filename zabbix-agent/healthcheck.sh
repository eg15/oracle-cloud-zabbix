#!/bin/bash

ZABBIX_GET=$(command -v zabbix_get) || { >&2 echo "zabbix_get is not installed, aborting."; exit 1; }
ZABBIX_AGENTD=$(command -v zabbix_agentd) || { >&2 echo "zabbix_agentd is not installed, aborting."; exit 2; }

# zabbix_get -s 127.0.0.1 -p 10050 -k system.cpu.load[all,avg1]
# 0.290000
ZABBIX_GET_OUTPUT=$("$ZABBIX_GET" -s 127.0.0.1 -p 10050 -k 'system.cpu.load[all,avg1]')
echo "$ZABBIX_GET_OUTPUT" | grep -qE ^\-?[0-9]?\.?[0-9]+$ || { >&2 echo "zabbix_get is not responding properly: $ZABBIX_GET_OUTPUT"; exit 3; }

# zabbix_agentd -t agent.hostname
# agent.hostname                                [s|Zabbix server]
ZABBIX_AGENTD_OUTPUT=$("$ZABBIX_AGENTD" -t agent.hostname)
echo "$ZABBIX_AGENTD_OUTPUT" | grep -q 'Zabbix server' || { >&2 echo "zabbix_agentd is not responding properly: $ZABBIX_AGENTD_OUTPUT"; exit 4; }

exit 0
