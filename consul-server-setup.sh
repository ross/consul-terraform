#!/bin/bash

set -e
set -o pipefail
set -x

VERSION=0.5.2

sudo apt-get -qq update
sudo apt-get -qq --assume-yes install unzip
wget --quiet https://dl.bintray.com/mitchellh/consul/${VERSION}_linux_amd64.zip \
  -O /tmp/${VERSION}_linux_amd64.zip
wget --quiet https://dl.bintray.com/mitchellh/consul/${VERSION}_web_ui.zip \
  -O /tmp/${VERSION}_web_ui.zip
sudo adduser --disabled-password --quiet --gecos "" consul
cd /home/consul 
sudo -u consul mkdir bin
(cd bin && sudo -u consul unzip /tmp/${VERSION}_linux_amd64.zip)
sudo -u consul unzip /tmp/${VERSION}_web_ui.zip
echo -n "$1" | sudo -u consul tee /home/consul/server-name
echo -n "$2" | sudo -u consul tee /home/consul/server-region

sudo ln -sf /home/ubuntu/consul-upstart.conf /etc/init/consul.conf
sudo initctl reload-configuration
sudo service consul start
