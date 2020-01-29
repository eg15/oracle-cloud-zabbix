FROM ubuntu:18.04 as builder

ENV \
  URL_ZABBIX="https://downloads.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/4.4.4/zabbix-4.4.4.tar.gz" \
  URL_INSTANT_CLIENT_BASIC="https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-basic-19.5.0.0.0-1.x86_64.rpm" \
  URL_INSTANT_CLIENT_SQLPLUS="https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-sqlplus-19.5.0.0.0-1.x86_64.rpm" \
  URL_INSTANT_CLIENT_TOOLS="https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-tools-19.5.0.0.0-1.x86_64.rpm" \
  URL_INSTANT_CLIENT_SDK="https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-devel-19.5.0.0.0-1.x86_64.rpm"
ENV \
  ORACLE_HOME="/usr/lib/oracle/19.5/client64" \
  ORACLE_INCLUDE="/usr/include/oracle/19.5/client64"
ENV \
  TNS_ADMIN="$ORACLE_HOME/network/admin" \
  LD_LIBRARY_PATH="$ORACLE_HOME/lib"

RUN set -xue \
  && apt-get update \
  && apt-get install -y \
	alien \
	build-essential \
	curl \
	libaio-dev \
	libcurl4-openssl-dev \
	libevent-dev \
	libgnutls28-dev \
	libiksemel-dev \
	libopenipmi-dev \
	libpcre3-dev \
	libsnmp-dev \
	libssh2-1-dev \
	libxml2-dev \
	patch \
	unixodbc-dev \
	unzip \
  && curl -fsSL -o basic.rpm $URL_INSTANT_CLIENT_BASIC \
  && curl -fsSL -o sqlplus.rpm $URL_INSTANT_CLIENT_SQLPLUS \
  && curl -fsSL -o tools.rpm $URL_INSTANT_CLIENT_TOOLS \
  && curl -fsSL -o sdk.rpm $URL_INSTANT_CLIENT_SDK \
  && alien -i basic.rpm \
  && alien -i sqlplus.rpm \
  && alien -i tools.rpm \
  && alien -i sdk.rpm \
  && rm basic.rpm sqlplus.rpm tools.rpm sdk.rpm

COPY oracle.patch /tmp/

RUN set -xue \
  && curl -fsSL -o zabbix.tar.gz $URL_ZABBIX \
  && mkdir -p /src/zabbix \
  && tar -zxC /src/zabbix --strip=1 -f zabbix.tar.gz \
  && rm zabbix.tar.gz \
  && mkdir -p $ORACLE_HOME/rdbms \
  && ln -s $ORACLE_INCLUDE $ORACLE_HOME/rdbms/public \
  && cd /src/zabbix \
  && patch -p0 -i /tmp/oracle.patch \
  && rm /tmp/oracle.patch \
  && ./configure \
	--enable-agent \
	--enable-ipv6 \
	--enable-server \
	--prefix=/usr \
	--datadir=/usr/lib \
	--libdir=/usr/lib/zabbix \
	--sysconfdir=/etc/zabbix \
	--with-jabber \
	--with-libcurl \
	--with-libxml2 \
	--with-net-snmp \
	--with-openipmi \
	--with-openssl \
	--with-oracle \
	--with-oracle-include=$ORACLE_INCLUDE \
	--with-oracle-lib=$ORACLE_HOME/lib \
	--with-ssh2 \
	--with-unixodbc \
	--silent \
  && make \
  && make install clean distclean

###############################################################################

FROM ubuntu:18.04

ARG ORACLE_SERVICE_NAME
ARG ORACLE_USER
ARG ORACLE_PASSWORD
ARG ORACLE_WALLET_ZIP

ENV ORACLE_HOME="/usr/lib/oracle/19.5/client64"
ENV \
  TNS_ADMIN="$ORACLE_HOME/network/admin" \
  LD_LIBRARY_PATH="$ORACLE_HOME/lib" \
  PATH="$PATH:$ORACLE_HOME/bin" \
  ORACLE_SERVICE_NAME="$ORACLE_SERVICE_NAME" \
  ORACLE_USER="$ORACLE_USER" \
  ORACLE_PASSWORD="$ORACLE_PASSWORD" \
  ORACLE_WALLET_ZIP="$ORACLE_WALLET_ZIP"

RUN set -xue \
  && apt-get update \
  && apt-get install -y \
	ca-certificates \
	curl \
	fping \
	iputils-ping \
	libaio1 \
	libcurl4 \
	libevent-2.1-6 \
	libiksemel3 \
	libodbc1 \
	libopenipmi0 \
	libpcre3 \
	libsnmp30 \
	libssh2-1 \
	libxml2 \
	nmap \
	snmp-mibs-downloader \
	telnet \
#		net-tools vim less \
	traceroute \
	unixodbc \
	unzip \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -m u=rwx,g=rwx,o= -p /var/lib/zabbix \
  && addgroup --quiet --system --gid 3000 zabbix \
  && adduser --quiet --system --uid 3000 --disabled-login --ingroup zabbix --home /var/lib/zabbix --no-create-home zabbix \
  && chown zabbix:zabbix /var/lib/zabbix

COPY --from=builder /usr/sbin/zabbix_server /usr/sbin/
COPY --from=builder /usr/bin/zabbix* /usr/bin/
COPY --from=builder /usr/include/oracle/. /usr/include/oracle/
COPY --from=builder /usr/lib/oracle/. /usr/lib/oracle/
COPY --from=builder /src/zabbix/frontends/php/ /var/www/html/
COPY --from=builder /src/zabbix/database/oracle/*.sql /tmp/

COPY zabbix_server.conf entrypoint.sh healthcheck.sh /tmp/
ADD oracle.tgz /tmp/
RUN set -xue \
  && chown -R root:zabbix /var/www/html \
  && chmod 770 /var/www/html/conf \
  && sed -i s/ORACLE_SERVICE_NAME/$ORACLE_SERVICE_NAME/ /tmp/zabbix_server.conf \
  && sed -i s/ORACLE_USER/$ORACLE_USER/ /tmp/zabbix_server.conf \
  && sed -i s/ORACLE_PASSWORD/$ORACLE_PASSWORD/ /tmp/zabbix_server.conf \
  && mkdir /etc/zabbix \
  && mv /tmp/zabbix_server.conf /etc/zabbix/ \
  && mv /tmp/entrypoint.sh /tmp/healthcheck.sh / \
  && chmod 755 /entrypoint.sh /healthcheck.sh

EXPOSE 10051/tcp

ENTRYPOINT [ "/entrypoint.sh" ]
