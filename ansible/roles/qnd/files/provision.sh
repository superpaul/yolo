#!/bin/sh
aptitude -y install lvm2 xfsprogs
umount /mnt
hdd="/dev/xvdb /dev/xvdc"
# /dev/xvdd /dev/xvde"
for i in $hdd;do
echo "n
p
1


t
8e
w
"|fdisk $i;
done 

vgcreate riak /dev/xvdb1
vgextend riak /dev/xvdc1
#vgextend riak /dev/xvdd1
#vgextend riak /dev/xvde1

lvcreate -n riak -l 100%FREE riak

mkdir /var/lib/riak
mkfs -t ext4 /dev/riak/riak
sed -i '$ d' /etc/fstab

echo "/dev/riak/riak  /var/lib/riak    ext4    noatime 0       2" >> /etc/fstab
mount /var/lib/riak

echo "vm.swappiness = 0" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 40000" >> /etc/sysctl.conf
echo "net.core.somaxconn=4000" >> /etc/sysctl.conf
echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.conf
echo "net.ipv4.tcp_sack = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_window_scaling = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fin_timeout = 15" >> /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_intvl = 30" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
echo "net.core.rmem_default = 8388608" >> /etc/sysctl.conf
echo "net.core.rmem_max = 8388608" >> /etc/sysctl.conf
echo "net.core.wmem_default = 8388608" >> /etc/sysctl.conf
echo "net.core.wmem_max = 8388608" >> /etc/sysctl.conf
echo "net.core.netdev_max_backlog = 10000" >> /etc/sysctl.conf

sysctl -p /etc/sysctl.conf

echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf

curl http://apt.basho.com/gpg/basho.apt.key | sudo apt-key add -

echo "deb http://apt.basho.com $(lsb_release -sc) main" > /etc/apt/sources.list.d/basho.list
aptitude update
aptitude -y install riak

perl -p -i.bak -e "s/127.0.0.1/`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`/" /etc/riak/*
perl -p -i.bak -e "s/{storage_backend, riak_kv_bitcask_backend},/{storage_backend, riak_kv_eleveldb_backend},/" /etc/riak/app.config
perl -p -i.bak -e "s/\{anti_entropy\, \{on\, \[\]\}\}\,/\{anti_entropy\, \{off\, \[\]\}\}\,/" /etc/riak/app.config
perl -p -i.bak -e "s/%{ring_creation_size, 64},/{ring_creation_size, 256},/" /etc/riak/app.config

ulimit -n 4096
riak start
riak ping
