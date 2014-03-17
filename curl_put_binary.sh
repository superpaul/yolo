#!/usr/bin/env bash

base_dir=$(dirname $0)
http_ip="$1"
http_port="$2"
bucket="$3"
start_key="$4"
end_key="$5"

# Check end_key is > start_key
if [[ $start_key -gt $end_key ]]; then
  echo "ERROR: <first_key> must be less than <last_key>"
  exit 1
fi

# Check Riak stats returns 200
riak_http_check="$(curl http://$riak_ip:$riak_port/stats -sI | head -1 | awk '{print $2}')"

# If Riak is up run PUT loop
if [[ $riak_http_check -ne 200 ]]; then
  echo "ERROR: Riak is not available at $riak_ip:$riak_port"
  exit 1
else
  let key=$start_key
  riak_ip="$http_ip"
  riak_port="$http_port"
  if [[ ! -f /tmp/riak_object ]]; then
    echo "INFO: Creating test object"
    dd if=/dev/urandom of=/tmp/riak_object bs=64k count=1
  fi
  while [ $key -le $end_key ]; do
    echo "INFO: PUT - http://$riak_ip:$riak_port/buckets/$bucket/keys/$key"
    curl -XPUT http://$riak_ip:$riak_port/buckets/$bucket/keys/$key \
         --data-binary @/tmp/riak_object
    let key=key+1
  done
  if [[ -f /tmp/riak_object ]]; then
    echo "INFO: Deleting test object"
    rm /tmp/riak_object
  fi
  exit 0
fi

# Echo usage
echo "INFO: $0 <riak_ip> <riak_port> <bucket> <first_key> <last_key"