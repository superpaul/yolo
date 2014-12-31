#!/usr/bin/env bash

##
## only support default 5 node cluster at the moment
##

riak_version="riak-1.4.12"
riak_node_count=4

# make sure you're home
if [ $(pwd) != "$HOME" ]; then
  echo "[error] run this script from $HOME"
  exit 1
fi

# add symlinks for the dev nodes to the below dir
devlink_dir="$HOME"
echo "[info] creating dev node symlinks in $devlink_dir"
for n in $(seq 1 ${riak_node_count}); do ln -s $riak_version/dev/dev${n} dev${n}; done

devrel_devnodes=$(ls $devlink_dir | grep ^dev[0-9] | wc -l)
echo "[info] $devrel_devnodes nodes found at $devlink_dir"

function riak_create_cluster() {
  # if no nodes are found in home dir attempt to build links
  echo "[info] function - riak_build_links()"
  ## create cluster
  # start riak nodes
  riak_control start
  sleep 3
  # join nodes
  for n in $(seq 2 ${riak_node_count}); do
    echo "[info] joining dev${n} to cluster"
    dev${n}/bin/riak-admin cluster join dev1@127.0.0.1
  done
  sleep 4
  # cluster plan and commit
  echo "[info] cluster plan and commit"
  dev1/bin/riak-admin cluster plan && dev1/bin/riak-admin cluster commit
}

function riak_control() {
  for n in $(seq 1 ${riak_node_count}); do
    echo "[info] $1ing dev${n}"
    $devlink_dir/dev${n}/bin/riak $1
    echo "[info] pinging dev${n}"
    $devlink_dir/dev${n}/bin/riak ping
  done
}

function riak_status() {
  #./riak_check_beams.sh
  ps -ef | grep 'beam' | grep -v 'grep' | awk '{print $2" "$8}'
}

case $1 in
  cluster )
    riak_create_cluster
    ;;    
  start )
    riak_control start
    ;;
  stop )
    riak_control stop
    ;;
  status )
    riak_status
    ;;
  * )
    echo "usage: $0 (cluster|start|stop|status)"
    ;;
esac
