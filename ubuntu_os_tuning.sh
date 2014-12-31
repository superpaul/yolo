#!/usr/bin/env bash

# set ulimits
sudo sh -c 'echo \
"* soft nofile 131072
* hard nofile 131072
root soft nofile 131072
root hard nofile 131072" \
>> /etc/security/limits.conf'

sudo sh -c 'echo \
"session    required    pam_limits.so" \
>> /etc/pam.d/common-session'

sudo sh -c 'echo \
"session    required    pam_limits.so" \
>> /etc/pam.d/common-session-noninteractive'

# set these values in sysctl.conf
sudo sh -c 'echo \
"vm.swappiness=0
net.core.wmem_default=8388608
net.core.rmem_default=8388608
net.core.wmem_max=8388608
net.core.rmem_max=8388608
net.core.netdev_max_backlog=10000
net.core.somaxconn=4000
net.ipv4.tcp_max_syn_backlog=40000
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_tw_reuse=1
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_mem  = 134217728 134217728 134217728
net.ipv4.tcp_rmem = 4096 277750 134217728
net.ipv4.tcp_wmem = 4096 277750 134217728
net.core.netdev_max_backlog = 300000" \
>> /etc/sysctl.conf'

# make changes effective
sudo sysctl -p

# vim syntax highlighting for easy 
# app.config and vm.args review
sudo sh -c 'echo \
"syntax on
filetype on
au BufNewFile,BufRead app.config set filetype=erlang
au BufNewFile,BufRead vm.args set filetype=sh" \
>> ~/.vimrc'