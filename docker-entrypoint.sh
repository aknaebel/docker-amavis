#!/bin/bash

sed -i "s/##VIMBADMIN_PASSWORD##/${VIMBADMIN_PASSWORD}/g" /etc/amavis/conf.d/50-user
sed -i "s/##DBHOST##/${DBHOST}/g" /etc/amavis/conf.d/50-user
sed -i "s/##HOSTNAME##/${HOSTNAME}/g" /etc/amavis/conf.d/05-node_id
sed -i "s/##HOSTNAME##/${HOSTNAME}/g" /etc/amavis/conf.d/50-custom

mkdir -p /var/lib/amavis/tmp
mkdir -p /var/lib/amavis/db

chown -R amavis:amavis /var/lib/amavis
chown -R clamav:clamav /var/lib/clamav
chown -R debian-spamd:debian-spamd /var/lib/spamassassin
chmod g+rx /var/spool/amavisd/tmp

su amavis -c 'razor-admin -create'
su amavis -c 'razor-admin -register'
su amavis -c 'pyzor discover'

freshclam
echo ${DOMAIN} >> /etc/mailname
exec "$@"
