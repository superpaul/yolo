#!/usr/bin/env bash

riak_version="riak-ee-1.4.3"

# make sure you're home
if [ $(pwd) != "$HOME" ]; then
  echo "[error] run this script from $HOME"
  exit 1
fi

# add symlinks for the dev nodes to the below dir
devlink_dir="$HOME"
echo "[info] creating dev node symlinks in $devlink_dir"
for d in dev{1..6}; do 
  ln -s $riak_version/dev/$d $d
done

devrel_devnodes=$(ls $devlink_dir | grep ^dev[0-9] | wc -l)
if [ $devrel_devnodes -lt 6 ]; then
  echo "[error] only $devrel_devnodes nodes found at $devlink_dir"
  exit 1
else
  echo "[info] $devrel_devnodes nodes found at $devlink_dir"
fi

# hack out sfwi as unpatched erlang in use 
for d in dev{1..6}; do 
  sed -e 's/+sfwi/#+sfwi/' -i.bak $d/etc/vm.args
done

# start all nodes
for d in dev{1..6}; do
  echo "[info] starting $d"
  $d/bin/riak start
  echo "[info] pinging $d"
  $d/bin/riak ping
done
 
echo "[info] sleeping for 5 seconds"
#this should be a riak_kv_wait_for_service check
sleep 5
 
# create clusters
for d in dev{2,3}; do
  echo "[info] creating cluster 1"
  $d/bin/riak-admin cluster join dev1@127.0.0.1
done
for d in dev{5,6}; do
  echo "[info] creating cluster 2"
  $d/bin/riak-admin cluster join dev4@127.0.0.1
done

echo "[info] sleeping for 5 seconds"
#this should be a riak_kv_wait_for_service check
sleep 5
 
for d in dev{1,4}; do
  echo "[info] cluster plan and commit"
  $d/bin/riak-admin cluster plan && $d/bin/riak-admin cluster commit
done