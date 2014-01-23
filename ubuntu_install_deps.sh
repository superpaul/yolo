#!/usr/bin/env bash

# install dependencies
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
libdigest-hmac-perl \
iperf \
r-base \
ruby1.9.1 \
ruby1.9.1-dev

# get s3curl from github
git clone https://github.com/rtdp/s3curl.git ~/s3curl

# 
echo "Do you need basho bench and erlang source?"
# get basho bench from github
#git clone https://github.com/basho/basho_bench.git ~/basho_bench
# install erlang from source for basho_bench
#wget http://erlang.org/download/otp_src_R15B01.tar.gz
#tar zxvf otp_src_R15B01.tar.gz
#cd otp_src_R15B01
#./configure && make && sudo make install
#cd

# install riak python client
sudo pip install riak

# is java needed?
echo "Do you need Open JDK for Riak EE? sudo apt-get install -y openjdk-6-jdk"
echo "Do you need Oracle JRE for Yokozuna?"
#https://github.com/flexiondotorg/oab-java6
#http://askubuntu.com/questions/56104/how-can-i-install-sun-oracles-proprietary-java-6-7-jre-or-jdk