#!/bin/bash
export HOSTNAME="mail.concord-consulting.pro"

# Create directory for persistent storage
mkdir -p /var/$HOSTNAME/zimbra

# Install packages needed
yum -y install bash-completion \
bind \
bind-utils \
glibc \
hostname \
iproute \
iputils \
libaio \
libstdc++.so.6 \
nmap-ncat \
ntp \
net-tools \
openssh-server \
perl \
perl-core \
rsyslog \
sqlite \
sudo \
sysstat \
unzip \
vim \
wget \
mc
