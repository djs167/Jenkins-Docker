#!/bin/bash

# Installs all required software for Jenkins (all required tools)

# Variables
RANCHER_VERSION=${RANCHER_VERSION:-"0.6.13"}
GOSU_VERSION=${GOSU_VERSION:-"1.11"}

# Basic softwares
apt-get -qq update && \
    apt-get upgrade -y -qq && \
    apt-get -qq -y install git sudo curl gnupg jq gettext-base

echo "jenkins ALL=NOPASSWD: /usr/bin/apt-get" > /etc/sudoers.d/jenkins
usermod -a -G staff jenkins
usermod -s /bin/bash jenkins

# RVM (for Ruby things)
curl -sSL https://rvm.io/mpapis.asc | gpg --no-tty --import -
curl -sSL https://keybase.io/mpapis/pgp_keys.asc | gpg --no-tty --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg --no-tty --import -
# gpg --no-tty --keyserver-options "timeout=10 http-proxy=$HTTP_PROXY" --keyserver hkp://p80.pool.sks-keyservers.net:80 \
#   --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB 62C9E5F4DA300D94AC36166BE206C29FBF04FF17
\curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm requirements
usermod -a -G rvm jenkins
rvm install 2.4

# Docker
curl -sSL https://get.docker.com/ | sh
groupadd -g 994 -o rancher_docker
groupadd -g 1101 -o rancher_docker2
usermod -a -G docker jenkins
usermod -a -G rancher_docker jenkins
usermod -a -G rancher_docker2 jenkins

# Rancher CLI tools
curl -fsSLO https://github.com/rancher/cli/releases/download/v${RANCHER_VERSION}/rancher-linux-amd64-v${RANCHER_VERSION}.tar.gz
tar --strip-components=2 -xzvf rancher-linux-amd64-v${RANCHER_VERSION}.tar.gz -C /usr/local/bin
chmod +x /usr/local/bin/rancher
#chmod 755 /usr/local/bin/wait_for_rancher

# gosu for switching users
curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64"
curl -o /tmp/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc"
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
gpg --batch --verify /tmp/gosu.asc /usr/local/bin/gosu
chmod +x /usr/local/bin/gosu

# Clean up
apt-get autoremove
apt-get autoclean
apt-get clean

# # Finalize entrypoint
# chmod +x /entrypoint-wrapper.sh
# chmod +x /docker-entrypoint.sh
