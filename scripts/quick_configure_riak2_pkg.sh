export riak_hostname="$(hostname --fqdn)"
export riak_ipaddr="0.0.0.0"

echo "nodename = riak@${riak_hostname}" | sudo tee -a /etc/riak/riak.conf
echo "anti_entropy = passive" | sudo tee -a /etc/riak/riak.conf
echo "listener.http.internal = ${riak_ipaddr}:8098" | sudo tee -a /etc/riak/riak.conf
echo "listener.protobuf.internal = ${riak_ipaddr}:8087" | sudo tee -a /etc/riak/riak.conf
echo "ring_size = 32" | sudo tee -a /etc/riak/riak.conf