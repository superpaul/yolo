#### NOTE: THIS ISN'T AN EXECUTABLE SHELL SCRIPT
#### I chose an sh extension for the nice syntax highlighting
#### Read the comments and follow their guidance
#### Some parts are copy and paste at command line
#### Others are not and may need manual editing or adjustment

### riak cs install on ubuntu

## set some variables for later use in config files
export RIAK_ETH="eth1" # set this to the interface riak, riak-cs and stanchion will listen on
export RIAK_IP=`ifconfig $RIAK_ETH | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'`
export RIAK_PACKAGES_DIR="/tmp" # absolute path to riak, riak-cs and stanchion install files
export RIAK_PACKAGE="riak_1.4.12-1_amd64.deb"
export STANCHION_PACKAGE="riak-cs_1.5.4-1_amd64.deb"
export RIAK_CS_PACKAGE="stanchion_1.5.0-1_amd64.deb"
export RIAK_CS_CONTROL_PACKAGE="" # leave this out by default

## tune ubuntu
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

## install packages
# if installing ubuntu debs use
sudo dpkg -i $RIAK_PACKAGES_DIR/$RIAK_PACKAGE $RIAK_PACKAGES_DIR/$STANCHION_PACKAGE $RIAK_PACKAGES_DIR/$RIAK_CS_PACKAGE
#sudo dpkg -i $RIAK_PACKAGES_DIR/$RIAK_CS_CONTROL_PACKAGE # if required

# if installing centos rpms use
#sudo rpm -Uvh $RIAK_PACKAGES_DIR/$RIAK_PACKAGE $RIAK_PACKAGES_DIR/$STANCHION_PACKAGE $RIAK_PACKAGES_DIR/$RIAK_CS_PACKAGE
#sudo rpm -Uvh $RIAK_PACKAGES_DIR/$RIAK_CS_CONTROL_PACKAGE # if required

## configure riak app.config
# - update IPs
# - increase the pb backlog setting
sudo sed -e "s/127.0.0.1/${RIAK_IP}/g" \
         -e "s/%% {pb_backlog, 64},/{pb_backlog, 256},/g" \
         -i.bak /etc/riak/app.config

# allow mult in riak_core - immediately after {riak_core, [
# need to do this manually as my file editing foo is too weak
sudo vim /etc/riak/app.config

{default_bucket_props, [{allow_mult, true}]},

# set multi backend in riak_kv 
# snippet specific for riak-cs 1.5.4, check your version
sudo vim /etc/riak/app.config

{add_paths, ["/usr/lib/riak-cs/lib/riak_cs-1.5.4/ebin"]},
{storage_backend, riak_cs_kv_multi_backend},
{multi_backend_prefix_list, [{<<"0b:">>, be_blocks}]},
{multi_backend_default, be_default},
{multi_backend, [
    {be_default, riak_kv_eleveldb_backend, [
        {max_open_files, 50},
        {data_root, "/var/lib/riak/leveldb"}
    ]},
    {be_blocks, riak_kv_bitcask_backend, [
        {data_root, "/var/lib/riak/bitcask"}
    ]}
]},

## configure riak vm.args
# - update IPs
# - enable and set zdbbl
sudo sed -e "s/127.0.0.1/${RIAK_IP}/g" \
         -e "s/#+zdbbl/+zdbbl/g" \
         -e "s/+zdbbl 32768/+zdbbl 128000/g" \
         -i.bak /etc/riak/vm.args

## configure stanchion app.config and vm.args
# - update IPs
sudo sed -e "s/127.0.0.1/${RIAK_IP}/g" \
         -i.bak /etc/stanchion/{app.config,vm.args}

## configure riak-cs app.config
# - update IPs
# - allow anonymous user creation - immediately before {cs_ip, ...}
# - if > 1.4 set fold_objects_for_list_keys true
sudo sed -e "s/127.0.0.1/${RIAK_IP}/g" \
         -e "s/{anonymous_user_creation, false},/{anonymous_user_creation, true},/g" \
         -e "s/{fold_objects_for_list_keys, false},/{fold_objects_for_list_keys, true},/g" \
         -i.bak /etc/riak-cs/app.config
# what about cs_root_host??

## configure riak-cs vm.args
# - update IPs
sudo sed -e "s/127.0.0.1/${RIAK_IP}/g" \
         -i.bak /etc/riak-cs/vm.args

## check IP changes
egrep 'http,|ip,' /etc/{riak,riak-cs,stanchion}/app.config

## check app.config syntax is valid
sudo riak chkconfig
sudo stanchion chkconfig
sudo riak-cs chkconfig

## check vm.args IP updates are correct
grep name /etc/{riak,riak-cs,stanchion}/vm.args

## start services in this order
sudo riak start
sudo stanchion start
sudo riak-cs start

## check services are running
sudo riak ping
sudo stanchion ping
sudo riak-cs ping

## create a user (on a single host) to assign as admin
curl -H 'Content-Type: application/json' \
  -X POST http://${RIAK_IP}:8080/riak-cs/user \
  --data '{"email":"admin@admin.com", "name":"admin"}'

# capture key_id and key_secret from the response 
# update admin key and secret in riak-cs and stanchion app.config then turn off anonymous user creation
sudo sed -e 's/{admin_key, "\(.*\)"}/{admin_key, "EQL0YSAQ3WV8FXH0GHCI"}/g' \
         -e 's/{admin_secret, "\(.*\)"}/{admin_secret, "m3CT4NG0Mw7uoUF5nd2RDLjbtXnQWbT6w6Y93w=="}/g' \
         -e 's/{anonymous_user_creation, true},/{anonymous_user_creation, false},/g' \
         -i.bak /etc/{riak-cs,stanchion}/app.config
# check update has worked
egrep 'admin_key|admin_secret' /etc/{riak-cs,stanchion}/app.config

## restart services in this order
sudo stanchion restart
sudo riak-cs restart

## install s3cmd and test it out!