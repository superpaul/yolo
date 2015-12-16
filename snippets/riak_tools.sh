# rolling restarts
riak-admin ringready # should report true
riak-admin transfers # should NOT show pending transfers
riak stop
riak start
riak-admin wait-for-service riak_kv
## move to next node

# upgrading riak
riak-admin ringready # should report true
riak-admin transfers # should NOT show pending transfers
riak stop
## install new package
## make any app.config changes
riak start
riak-admin wait-for-service riak_kv
## move to next node

# transfers and transfer-limit
riak stop # one node
## load cluster with data
## check fallback partitions on other nodes
watch -n 1 "riak-admin transfers" # partitions eligible every 30 seconds
riak start # stopped node
riak-admin transfer-limit
riak-admin transfer-limit 16
riak-admin transfer-limit 2

# adding nodes (ALREADY COVERED IN SETUP)

# removing nodes
riak-admin cluster leave # node running the command leaves
riak-admin cluster leave riak@node6 # have another node leave

## watch transfers
riak-admin transfers

## wipe the node6 so it is fresh
rm -rf /var/lib/riak/* # only on OS not EE

## use node 6 as a replacement for node 1
riak start
riak-admin cluster join riak@node2
riak-admin cluster replace riak@node1 riak@node6
riak-admin cluster plan
riak-admin cluster commit

## confirm node1 stopped, is empty and when started is not part of a ring
riak start

## kill node 4
kill -9 $(ps -ef | grep beam | awk '{print $2}')

## force replace node 5 (any non-claimant) with node 1
kill -9 $(ps -ef | grep dev5 | grep beam | awk '{print $2}')
dev1/bin/riak start
dev3/bin/riak-admin member-status
#observe individual member status
dev3/bin/riak-admin down dev5@127.0.0.1
dev1/bin/riak-admin cluster join dev3@127.0.0.1
dev3/bin/riak-admin member-status
#observe individual member status
dev3/bin/riak-admin cluster force-replace dev5@127.0.0.1 dev1@127.0.0.1
dev3/bin/riak-admin cluster plan
dev3/bin/riak-admin cluster commit