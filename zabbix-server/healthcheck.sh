#!/bin/bash

export ORACLE_HOME=/usr/lib/oracle/19.5/client64
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$ORACLE_HOME/bin
export TNS_ADMIN=$ORACLE_HOME/network/admin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/lib64:/usr/lib
export ORACLE_SID=ZABBIX

[ -f $TNS_ADMIN/tnsnames.ora ] || { >&2 echo "$TNS_ADMIN/tnsnames.ora does not exist"; exit 1; }

count=$(sqlplus -s $ORACLE_USER/$ORACLE_PASSWORD@$ORACLE_SERVICE_NAME <<-EOF
	whenever sqlerror exit sql.sqlcode;
	set echo off
	set heading off
	set feed off
	set pagesize 0
	select count(*) from all_tables where table_name='USERS';
	exit;
EOF
)
[ $? -ne 0 ] && { >&2 echo "SQL*Plus error"; exit 2; }
[ "$count" -ne 1 ] && { >&2 echo "There should be only one USERS table; SELECT returned: $count"; exit 3; }

exit 0
