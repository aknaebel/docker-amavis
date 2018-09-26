FROM ubuntu:18.04
MAINTAINER Alain Knaebel, <alain.knaebel@aknaebel.fr>

ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://fr.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb http://fr.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb http://fr.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb http://fr.archive.ubuntu.com/ubuntu/ xenial-proposed main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb http://security.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y amavisd-new spamassassin clamav-daemon \
			libnet-dns-perl libmail-spf-perl pyzor razor \
			arj bzip2 cabextract cpio file gzip lhasa nomarch pax rar unrar unzip zip zoo \
			supervisor rsyslog libdbd-mysql-perl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \

 && usermod -a -G amavis amavis \
 && usermod -a -G clamav clamav \
 && usermod -a -G amavis clamav \
 && usermod -a -G clamav amavis \
 && echo "0 1 * * * root /usr/bin/freshclam --stdout" >> /etc/crontab \
 && sed -i "s/ENABLED=0/ENABLED=1/" /etc/default/spamassassin \
 && sed -i "s/CRON=0/CRON=1/" /etc/default/spamassassin \
 && sed -i "s/# required_score/required_score/" /etc/spamassassin/local.cf \

 && sed -i 's/^logfile = .*$/logfile = \/var\/log\/mail.log/g' /etc/razor/razor-agent.conf \
 && sed -i "s/# rewrite_header/rewrite_header/" /etc/spamassassin/local.cf \

 && echo "TCPSocket 3310" >> /etc/clamav/clamd.conf \
 && sed -i 's/^AllowSupplementaryGroups false/AllowSupplementaryGroups true/' /etc/clamav/clamd.conf \

 && mkdir /var/run/clamav \
 && chown clamav:clamav /var/run/clamav \
 && chmod 755 /var/run/clamav \

 && mkdir -p /etc/spamassassin/sa-update-keys \
 && chmod 700 /etc/spamassassin/sa-update-keys \
 && chown debian-spamd:debian-spamd /etc/spamassassin/sa-update-keys \

 && su amavis -c 'razor-admin -create' \
 && su amavis -c 'razor-admin -register' \
 && su amavis -c 'pyzor discover' \

 && sed -i -r "/^#?compress/c\compress\ncopytruncate" /etc/logrotate.conf

COPY ./05-node_id /etc/amavis/conf.d/05-node_id
COPY ./15-content_filter_mode /etc/amavis/conf.d/15-content_filter_mode
COPY ./50-user /etc/amavis/conf.d/50-user
COPY ./50-custom /etc/amavis/conf.d/50-custom

COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker-entrypoint.sh /docker-entrypoint.sh

VOLUME ["/var/lib/amavis"]
VOLUME ["/var/lib/clamav"]
VOLUME ["/var/lib/spamassassin"]

EXPOSE 783
EXPOSE 3310
EXPOSE 10024
EXPOSE 10025

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD cron;/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
