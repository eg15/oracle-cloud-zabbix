FROM certbot/certbot:latest

ARG CERTBOT_EMAIL
ARG ZABBIX_SERVER_NAME

ENV \
  CERTBOT_EMAIL="$CERTBOT_EMAIL" \
  ZABBIX_SERVER_NAME="$ZABBIX_SERVER_NAME"

COPY entrypoint.sh /
RUN chmod 755 /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD []
