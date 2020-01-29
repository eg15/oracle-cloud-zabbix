#!/bin/bash

GREP=$(command -v grep) || { >&2 echo "grep is not installed, aborting."; exit 1; }
PHP_FPM=$(command -v php-fpm) || { >&2 echo "php-fpm is not installed, aborting."; exit 2; }

# php-fpm -t
# [20-Jan-2020 16:33:05] NOTICE: configuration file /etc/php-fpm.conf test is successful
CONFIG_CHECK=$("$PHP_FPM" -t 2>&1)
echo "$CONFIG_CHECK" | grep -q "test is successful" || { >&2 echo "$CONFIG_CHECK"; exit 3; }

# php-fpm -i | grep oracle
# System => Linux zabbix-php 4.15.0-1030-oracle #33-Ubuntu SMP Fri Nov 15 13:20:06 UTC 2019 x86_64
# LD_LIBRARY_PATH => /usr/lib/oracle/19.5/client64/lib
# TNS_ADMIN => /usr/lib/oracle/19.5/client64/network/admin
# ORACLE_HOME => /usr/lib/oracle/19.5/client64
# $_SERVER['LD_LIBRARY_PATH'] => /usr/lib/oracle/19.5/client64/lib
# $_SERVER['TNS_ADMIN'] => /usr/lib/oracle/19.5/client64/network/admin
# $_SERVER['ORACLE_HOME'] => /usr/lib/oracle/19.5/client64
PHP_INFO=$("$PHP_FPM" -i)
echo "$PHP_INFO" | grep -qE 'ORACLE_HOME => [.0-9a-z/]' || { >&2 echo "ORACLE_HOME is not set"; exit 4; }
echo "$PHP_INFO" | grep -qE 'TNS_ADMIN => [.0-9a-z/]' || { >&2 echo "TNS_ADMIN is not set"; exit 5; }

# grep -rq /sock/php-fpm.sock /proc/net/
# echo $?
# 0
# grep -rq /sOcK/pHp-fPm.sOcK /proc/net/
# echo $?
# 1
grep -rq /sock/php-fpm.sock /proc/net/ || { >&2 echo "php-fpm.sock does not exist"; exit 6; }

exit 0
