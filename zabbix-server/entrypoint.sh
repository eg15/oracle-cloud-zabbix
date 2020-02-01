#!/bin/bash

export ORACLE_HOME=/usr/lib/oracle/19.5/client64
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$ORACLE_HOME/bin
export TNS_ADMIN=$ORACLE_HOME/network/admin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/lib64:/usr/lib
export ORACLE_SID=ZABBIX

if [ ! -f $TNS_ADMIN/tnsnames.ora ]; then
  echo "'$TNS_ADMIN/tnsnames.ora' does not exist..."
  if [ ! -f $TNS_ADMIN/$ORACLE_WALLET_ZIP ]; then
    echo "'$TNS_ADMIN/$ORACLE_WALLET_ZIP' does not exist either. Please download the Oracle Wallet ZIP file to continue."
    sleep 1
    exit 1
  else
    unzip -o $TNS_ADMIN/$ORACLE_WALLET_ZIP -d $TNS_ADMIN
    if [ $? -ne 0 ]; then
      echo "'unzip $TNS_ADMIN/$ORACLE_WALLET_ZIP' failed, aborting..."
      sleep 1
      exit 1
    else
      echo "'unzip $TNS_ADMIN/$ORACLE_WALLET_ZIP' succeeded..."
      if [ ! -f $TNS_ADMIN/tnsnames.ora ]; then
        echo "...but '$TNS_ADMIN/tnsnames.ora' still does not exist. Please check the contents of the Oracle Wallet ZIP file."
        sleep 1
        exit 1
      fi
    fi
  fi
fi

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
if [ $? -ne 0 ]; then
  echo "SQL*Plus error while checking if USERS table exists"
  exit 1
fi
if [ "$count" -eq 0 ]; then
  # USERS table does not exist, populate the database
  sqlplus -s $ORACLE_USER/$ORACLE_PASSWORD@$ORACLE_SERVICE_NAME <<-EOF
	whenever sqlerror exit sql.sqlcode;
	set echo off
	set heading off
	@/tmp/oracle/schema.sql
	exit;
EOF
  if [ $? -ne 0 ]; then
    echo "SQL*Plus error while populating the Zabbix schema"
    exit 1
  fi
  (
    cd /tmp/oracle/images
    sqlldr $ORACLE_USER/$ORACLE_PASSWORD@$ORACLE_SERVICE_NAME control=IMAGES_DATA_TABLE.ctl
    if [ $? -ne 0 ]; then
      echo "SQL*Loader error while uploading images"
      exit 1
    fi
  )
  sqlplus -s $ORACLE_USER/$ORACLE_PASSWORD@$ORACLE_SERVICE_NAME <<-EOF
	whenever sqlerror exit sql.sqlcode;
	set echo off
	set heading off
	@/tmp/oracle/data.sql
	exit;
EOF
  if [ $? -ne 0 ]; then
    echo "SQL*Plus error while uploading data.sql"
    exit 1
  fi
  #rm -rf /tmp/oracle
fi

/usr/sbin/zabbix_server -f
