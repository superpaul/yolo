#!/usr/bin/env bash

function alert_msg() {
  case $1 in
    "u" )
      alert="usage"
      ;;
    "i" )
      alert="info"
      ;;
    "e" )
      alert="error"
      ;;
  esac
  message="$2"  
  echo "$alert: $message"
}

base_dir=$(dirname $0)
http_ip="$1"
http_port="$2"
bucket="$3"
start_key="$4"
end_key="$5"

# check end_key is > start_key
if [[ $start_key -gt $end_key ]]; then
  alert_msg e "<first_key> must be less than <last_key>"
  alert_msg u "$0 <riak_ip> <riak_port> <bucket> <first_key> <last_key>"
  exit 1
fi

if [[ $http_port -gt 1024 ]]; then
  riak_ip="$http_ip"
  riak_port="$http_port"
else
  alert_msg e "riak port must be above 1024"
  alert_msg u "$0 <riak_ip> <riak_port> <bucket> <first_key> <last_key>"
  exit 1
fi

if [[ ! -f /tmp/riak_object ]]; then
  alert_msg i "creating test object"
  dd if=/dev/urandom of=/tmp/riak_object bs=64k count=1
fi

riak_http_check="$(curl http://$riak_ip:$riak_port/stats -sI | head -1 | awk '{print $2}')"

if [[ $riak_http_check -ne 200 ]]; then
  alert_msg e "riak not available on $riak_ip:$riak_port"
  exit 1
else
  let key=$start_key
  while [ $key -le $end_key ]; do
    alert_msg i "PUT - http://$riak_ip:$riak_port/buckets/$bucket/keys/$key"
    curl -XPUT http://$riak_ip:$riak_port/buckets/$bucket/keys/$key \
         --data-binary @/tmp/riak_object
    let key=key+1
    sleep 0.1s
  done
fi

if [[ -f /tmp/riak_object ]]; then
  alert_msg i "deleting test object"
  rm /tmp/riak_object
fi