#!/usr/bin/env bash

# dependencies
sudo apt-get update && sudo apt-get install -y \
curl \
vim \
libncurses5-dev \
openssl \
libssl-dev \
fop \
xsltproc \
unixodbc-dev \
build-essential \
libc6-dev-i386 \
git \
maven \
python-pip \
libpam0g-dev \
libssl0.9.8 \
s3cmd \
tidy \
libdigest-hmac-perl

# get s3curl from github
git clone https://github.com/rtdp/s3curl.git ~/s3curl

# install riak python client
pip install riak

# is java needed?
echo "Do you need Open JDK for Riak EE?"
#sudo apt-get install -y openjdk-7-jdk
echo "Do you need Oracle JRE for Yokozuna?"
#https://github.com/flexiondotorg/oab-java6
#http://askubuntu.com/questions/56104/how-can-i-install-sun-oracles-proprietary-java-6-7-jre-or-jdk