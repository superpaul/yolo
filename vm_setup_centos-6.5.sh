#!/usr/bin/env bash

# enable eth0
sed -e 's/ONBOOT=no/ONBOOT=yes/' -i.bak /etc/sysconfig/network-scripts/ifcfg-eth0
ifup eth0

# instal some useful tools
yum -y install wget curl git man vim ntp gcc bzip2 make kernel-devel-`uname -r`

# add vagrant user
useradd vagrant
mkdir -m 0700 -p /home/vagrant/.ssh
curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
sed -i 's/^\(Defaults.*requiretty\)/#\1/' /etc/sudoers
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# fix networking
cat << EOF1 > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=dhcp
EOF1
rm -f /etc/udev/rules.d/70-persistent-net.rules

# set some service runlevels
# and configure ntp
chkconfig ntpd on
chkconfig sshd on
chkconfig iptables off
chkconfig ip6tables off
service ntpd stop
ntpdate time.nist.gov
service ntpd start

# set sensible ulimits
cat << EOF1 >> /etc/security/limits.conf
* soft nofile 131072
* hard nofile 131072
root soft nofile 131072
root hard nofile 131072
EOF1

# set these values in sysctl.conf
cat << EOF1 >> /etc/sysctl.conf
vm.swappiness=0
net.core.wmem_default=8388608
net.core.rmem_default=8388608
net.core.wmem_max=8388608
net.core.rmem_max=8388608
net.core.netdev_max_backlog=10000
net.core.somaxconn=4000
net.ipv4.tcp_max_syn_backlog=40000
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_tw_reuse=1
EOF1

# make changes effective
sudo sysctl -p

# vim syntax highlighting for easy 
# app.config and vm.args review
cat << EOF1 >> /home/vagrant/.vimrc
syntax on
filetype on
au BufNewFile,BufRead app.config set filetype=erlang
au BufNewFile,BufRead vm.args set filetype=sh
EOF1

# install virtualbox guest additions
mount -o loop,ro /dev/cdrom /media
/media/VBoxLinuxAdditions.run
umount /media

# clean up
yum clean all
rm -rf /tmp/*
rm -f /var/log/wtmp /var/log/btmp
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
history -c

# shutdown
shutdown -h now
