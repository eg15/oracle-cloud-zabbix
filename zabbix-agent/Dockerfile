FROM ubuntu:18.04 as builder

ENV URL_ZABBIX "https://downloads.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/4.4.4/zabbix-4.4.4.tar.gz"

RUN set -xue \
  && apt-get update \
  && apt-get install -y curl unzip build-essential libcurl4-openssl-dev libldap2-dev libpcre3-dev libgnutls28-dev libssl-dev

RUN set -xe \
  && curl -fsSL -o zabbix.tar.gz $URL_ZABBIX \
  && mkdir -p /src/zabbix \
  && tar -zxC /src/zabbix --strip=1 -f zabbix.tar.gz \
  && rm zabbix.tar.gz \
  && cd /src/zabbix \
  && ./configure \
	--enable-agent \
	--enable-ipv6 \
	--with-libcurl \
	--with-ldap \
	--with-openssl \
	--sysconfdir=/etc/zabbix \
	--prefix=/usr \
	--datadir=/usr/lib \
	--libdir=/usr/lib/zabbix \
	--silent \
  && make \
  && make install clean distclean

###############################################################################

FROM ubuntu:18.04

COPY --from=builder /usr/sbin/zabbix* /usr/sbin/
COPY --from=builder /usr/bin/zabbix* /usr/bin/
#COPY --from=builder /src/zabbix/conf/zabbix_agentd.conf /etc/zabbix/
COPY zabbix_agentd.conf /etc/zabbix/
COPY healthcheck.sh /

RUN set -xue \
  && apt-get update \
  && apt-get install -y curl telnet iputils-ping traceroute libpcre3 libssl1.1 libcurl4 libldap-2.4 \
	net-tools vim less \
  && rm -rf /var/lib/apt/lists/* \
  && addgroup --quiet --system --gid 3000 zabbix \
  && adduser --quiet --system --uid 3000 --disabled-login --ingroup zabbix --home /var/lib/zabbix zabbix \
  && mkdir -p /etc/zabbix \
  && mkdir -p /etc/zabbix/zabbix_agentd.d \
  && mkdir -p /var/lib/zabbix \
  && mkdir -p /var/lib/zabbix/enc \
  && mkdir -p /var/lib/zabbix/modules \
  && chown -R zabbix:root /var/lib/zabbix \
  && chmod 755 /healthcheck.sh

EXPOSE 10050/TCP

ENTRYPOINT [ "zabbix_agentd", "-f" ]
