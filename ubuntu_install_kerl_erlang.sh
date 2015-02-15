#!/usr/bin/env bash

sudo apt-get update --fix-missing && sudo apt-get upgrade -y

# install dependencies to build erlang from source
sudo apt-get install -y \
autoconf \
build-essential \
libncurses5-dev \
openssl \
libssl-dev \
fop \
xsltproc \
unixodbc-dev

# install some useful tools
sudo apt-get install -y \
curl \
iperf \
git \
vim \
wget

# install a GUI if you need one
#sudo aptitude install --without-recommends ubuntu-desktop

# install kerl to manage erlang versions
sudo curl -o /usr/local/bin/kerl https://raw.githubusercontent.com/spawngrid/kerl/master/kerl
sudo chown root:root /usr/local/bin/kerl
sudo chmod a+x /usr/local/bin/kerl

# install basho version of erlang R15B01
kerl build git git://github.com/basho/otp.git basho_OTP_R15B01_scheduler_patch R15B01
kerl install R15B01 ~/erlang/R15B01
#. ~/erlang/R15B01/activate

# install basho version of erlang R16B02
kerl build git git://github.com/basho/otp.git OTP_R16B02_basho7 R16B02_basho7
kerl install R16B02_basho7 ~/erlang/R16B02_basho7
#. ~/erlang/R16B02-basho7/activate
