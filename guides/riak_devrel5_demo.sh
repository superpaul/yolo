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
grep storage_backend dev?/etc/app.config
for d in dev{1..5}; do sed -e 's/riak_kv_bitcask_backend/riak_kv_eleveldb_backend/' -i.bak $d/etc/app.config; done
grep storage_backend dev?/etc/app.config

## start nodes
for d in dev{1..5}; do $d/bin/riak start; done

## check nodes are up
for d in dev{1..5}; do $d/bin/riak ping; done
ps -ef | grep beam

## cover clustering, the ring, consistent hashing, partitions, vnodes, replicas etc
for d in dev{2..5}; do $d/bin/riak-admin cluster join dev1@127.0.0.1; done
dev1/bin/riak-admin cluster plan
dev1/bin/riak-admin cluster commit

## cover cluster clear
#dev1/binriak-admin cluster clear shuts nodes down

## show transfers taking place
dev1/bin/riak-admin transfers

## increase transfer limit to speed things up
dev1/bin/riak-admin transfer-limit
dev1/bin/riak-admin transfer-limit 8

## show riak data being distributed around the ring
watch "du -d0 dev?/data/leveldb"

## insert zombie data
python bulk_import.py

## kill some nodes
for d in dev{4..5}; do $d/bin/riak stop; done

## show r and pr reads
curl http://localhost:10018/buckets/za/keys/310-673-3772 | python -mjson.tool
curl http://localhost:10018/buckets/za/keys/310-673-3772?pr=3 | python -mjson.tool

## show w and pw writes
curl -i -XPUT http://localhost:10018/buckets/primary/keys/key_1 -d "Ben"
curl -i -XPUT http://localhost:10018/buckets/primary/keys/key_2?pw=3 -d "Bob"
# PW-value unsatisfied: 2/3

## show metadata in curl requests
curl -i http://localhost:10018/buckets/za/keys/310-673-3772

## show some 2i querys
curl http://localhost:10018/buckets/za/index/city_bin/Wytheville | python -mjson.tool
curl http://localhost:10018/buckets/za/index/state_bin/CA | python -mjson.tool
curl http://localhost:10018/buckets/za/index/blood_bin/O%2B | python -mjson.tool

## show a 2i range query
curl http://localhost:10018/buckets/za/index/weight_bin/220/240 | python -mjson.tool
curl http://localhost:10018/buckets/za/index/weight_bin/220/222?return_terms=true | python -mjson.tool

## MR
curl -X POST http://localhost:10018/mapred \
-H 'content-type: application/json' \
-d @- \
<<EOF
{
   "inputs":{
       "bucket":"za",
       "index":"weight_bin",
       "start":"220",
       "end":"240"
   },
   "query":[
      {
         "reduce":{
            "language":"erlang",
            "module":"riak_kv_mapreduce",
            "function":"reduce_identity",
            "keep":true
         }
      }
   ]
}
EOF

## example cluster operations

## leave node 1
dev1/bin/riak-admin cluster leave
dev3/bin/riak-admin cluster leave dev1@127.0.0.1

##observe transfers
watch -d dev1/bin/riak-admin transfers
watch -d ls dev{1..5}/data/bitcask
#the leaving node will stop

## wipe node 1
rm -rf dev1/data/*

## use node 6 as a replacement for node 1
dev1/bin/riak start
dev1/bin/riak-admin cluster join dev3@127.0.0.1
dev3/bin/riak-admin cluster replace dev4@127.0.0.1 dev1@127.0.0.1
dev3/bin/riak-admin cluster plan
dev3/bin/riak-admin cluster commit

## kill node 3
kill -9 $(ps -ef | grep dev3 | grep beam | awk '{print $2}')

## force remove node 3
dev1/bin/riak-admin cluster force-remove dev3@127.0.0.1

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