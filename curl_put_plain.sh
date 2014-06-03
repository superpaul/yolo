#!/usr/bin/env bash

# Set some defaults
riak_ip="localhost"
riak_port="8098"
bucket="b1"
start_key="1"
end_key="100"

# Usage output
usage()
{
cat << EOF
USAGE: $0 -s <riak_ip> -p <riak_port> -b <bucket> -f <first_key> -l <last_key>

OPTIONS:
  -h      Show this message
  -s      Riak IP
  -p      Riak port
  -b      Bucket
  -f      First key
  -l      Last key
EOF
}

# Get options
while getopts "hs:p:b:f:l:" option;
do
  case $option in
    h)
      usage
      exit 1
    ;;
    s)
      riak_ip=$OPTARG
    ;;
    p)
      riak_port=$OPTARG
    ;;
    b)
      bucket=$OPTARG
    ;;
    f)
      start_key=$OPTARG
    ;;
    l)
      end_key=$OPTARG
    ;;
  esac
done

# Check Riak stats returns 200
riak_http_check="$(curl http://$riak_ip:$riak_port/stats -sI | head -1 | awk '{print $2}')"
if [ $riak_http_check -ne 200 ]; then
  echo "ERROR: Riak is not available at $riak_ip:$riak_port"
  exit 1
fi

# Check end_key is > start_key
if [ $start_key -gt $end_key ]; then
  echo "ERROR: <first_key> must be less than <last_key>"
  exit 1
fi

# Run DELETE loop
let key=$start_key
while [ $key -le $end_key ]; do
  echo "INFO: PUT - http://$riak_ip:$riak_port/buckets/$bucket/keys/$key"
  curl -XPUT http://$riak_ip:$riak_port/buckets/$bucket/keys/$key \
         -d "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
  let key=key+1
done
