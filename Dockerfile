#!/usr/bin/bash
FROM centos:latest
MAINTAINER exmo

RUN set -ex
RUN yum -y install bash-completion bind bind-utils glibc hostname iproute iputils libaio libstdc++.so.6 nmap-ncat ntp net-tools openssh-server perl perl-core rsyslog sqlite sudo sysstat unzip vim wget mc

COPY ./etc/named/db.domain /var/named/db.domain
COPY ./etc/named/named.conf /etc/named.conf
COPY opt /opt/
COPY zimbra.repo /etc/yum.repos.d/
COPY ./entrypoint.sh /entrypoint.sh

VOLUME ["/opt/zimbra"]

WORKDIR /opt/zimbra

EXPOSE 22 25 465 587 110 143 993 995 80 443 8080 8443 7071

#RUN /opt/start.sh
#ENTRYPOINT ["/entrypoint.sh"]
#ENTRYPOINT ["/opt/start.sh"]
# CMD ["/opt/start.sh"]