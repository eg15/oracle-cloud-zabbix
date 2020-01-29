FROM nginx:1.17.6-alpine

ARG ZABBIX_SERVER_NAME

RUN set -ex \
  && addgroup -g 3000 -S zabbix \
  && apk --no-cache add shadow \
  && usermod -aG zabbix nginx

COPY nginx-conf/. /etc/nginx/

RUN sed -i s/ZABBIX_SERVER_NAME/$ZABBIX_SERVER_NAME/ /etc/nginx/conf.d/zabbix.conf

#ENTRYPOINT [ "sh", "-c", "sleep 600" ]
