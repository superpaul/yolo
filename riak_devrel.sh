#!/usr/bin/env bash


##
## only support default 5 node cluster at the moment
##

riak_version="riak-1.4.3"

# make sure you're home
if [ $(pwd) != "$HOME" ]; then
  echo "[error] run this script from $HOME"
  exit 1
fi

# add symlinks for the dev nodes to the below dir
devlink_dir="$HOME"
echo "[info] creating dev node symlinks in $devlink_dir"
for d in dev{1..5}; do ln -s $riak_version/dev/$d $d; done

devrel_devnodes=$(ls $devlink_dir | grep ^dev[0-9] | wc -l)
if [ $devrel_devnodes -lt 5 ]; then
  echo "[error] only $devrel_devnodes nodes found at $devlink_dir"
  exit 1
else
  echo "[info] $devrel_devnodes nodes found at $devlink_dir"
fi

function riak_create_cluster() {
  # if no nodes are found in home dir attempt to build links
  echo "[info] function - riak_build_links()"
  ## create cluster
  # start riak nodes
  riak_control start
  sleep 3
  # join nodes
  for d in dev{2..5}; do
    echo "[info] joining $d to cluster"
    $d/bin/riak-admin cluster join dev1@127.0.0.1
  done
  sleep 4
  # cluster plan and commit
  echo "[info] cluster plan and commit"
  dev1/bin/riak-admin cluster plan && dev1/bin/riak-admin cluster commit
}

function riak_control() {
  for d in dev{1..5}; do
    echo "[info] $1ing $d"
    $devlink_dir/$d/bin/riak $1
    echo "[info] pinging $d"
    $devlink_dir/$d/bin/riak ping
  done
}

function riak_status() {
  ./riak_check_beams.sh
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
