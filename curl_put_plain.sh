#!/usr/bin/env bash

base_dir=$(dirname $0)
riak_ip="$1"
riak_port="$2"
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
  while [ $key -le $end_key ]; do
    echo "INFO: PUT - http://$riak_ip:$riak_port/buckets/$bucket/keys/$key"
    curl -XPUT http://$riak_ip:$riak_port/buckets/$bucket/keys/$key \
         -d "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    let key=key+1
  done
  exit 0
fi

# Echo usage
echo "INFO: $0 <riak_ip> <riak_port> <bucket> <first_key> <last_key"
