### riak devrel demo

## make riak rel (explain this is fine for testing and developing)
make rel

## make riak devrel (show clustering and explain use case, not required for dev)
make devrel

## set ulimit
ulimit -n 4096

## configure for eleveldb backend, explain backends
# show the configuration section in app.config
cd dev
sed -e "s/search = off/search = on/g" \
-e "s/## ring_size = 64/ring_size = 32/g" \
-e "s/## strong_consistency = on/strong_consistency = on/g" \
-e "s/-Xms1g -Xmx1g/-Xms128m -Xmx128m/g" \
-i.bak dev{1..5}/etc/riak.conf

## check node config
for d in dev{1..5}; do $d/bin/riak chkconfig; done

## start nodes
for d in dev{1..5}; do $d/bin/riak start; done

## check nodes are up
for d in dev{1..5}; do $d/bin/riak ping; done
ps -ef | grep beam
ps -ef | grep java

## cover clustering, the ring, consistent hashing, partitions, vnodes, replicas etc
for d in dev{2..5}; do $d/bin/riak-admin cluster join dev1@127.0.0.1; done
dev1/bin/riak-admin cluster plan
dev1/bin/riak-admin cluster commit

## cover cluster clear
#dev1/binriak-admin cluster clear shuts nodes down

## show transfers taking place
dev1/bin/riak-admin transfers