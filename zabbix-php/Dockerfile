FROM oraclelinux:7-slim

ARG PHP_TZ

ENV ORACLE_HOME "/usr/lib/oracle/19.5/client64"
ENV TNS_ADMIN "/usr/lib/oracle/19.5/client64/network/admin"
ENV LD_LIBRARY_PATH "/usr/lib/oracle/19.5/client64/lib"
ENV ORACLE_SID zabbix

COPY php-conf/. /etc/
COPY healthcheck.sh /

RUN set -xue \
    && yum -y install oracle-release-el7 oracle-php-release-el7 oracle-epel-release-el7 \
    && yum-config-manager --enable ol7_oracle_instantclient \
    && yum -y install oracle-instantclient19.5-basic oracle-instantclient19.5-devel oracle-instantclient19.5-sqlplus ssmtp php-fpm php-oci8-12c php-gd php-xml php-bcmath php-mbstring \
    && rm -rf /var/cache/yum \
    && groupadd --gid 3000 zabbix \
    && adduser --uid 3000 --gid 3000 zabbix \
    && sed -i s#PHP_TZ#$PHP_TZ# /etc/php.ini \
    && chmod 755 /healthcheck.sh

ENTRYPOINT [ "php-fpm", "-F" ]
