Test: Riak KV Repair in a similar way to Nokia's de-duplication process.

Theory: You should be able to remove 50% of the ring and still recover all data as
you are storing three replicas by default.

Summary Steps:

* start a default cluster (bitcask; 64 ring_size)
* load it with data using a known data set
* stop the node and remove every other partition
* start the node and query all the data
* check the percentage of not_found results (if any)

Detailed Steps:

* start a default cluster (bitcask; 64 ring_size)

```
sudo riak start
```

* load it with data using a known data set

```
dd if=/dev/urandom of=/tmp/riak_object bs=64k count=1
for key in {1..500}; do
  curl http://localhost:8098/buckets/tb/keys/${key} \
       --data-binary @/tmp/riak_object
done
```

* stop the node and remove every other partition

```
sudo riak stop
# find and remove every other partition
```

* start the node and query all the data

```
rm /tmp/response_codes
for key in {1..500}; do
  curl --silent http://localhost:8098/buckets/tb/keys/${key} \
       --write-out '%{http_code}\n' \
       --output /dev/null >> /tmp/response_codes
done
```

* check the percentage of not_found results (if any)

```
egrep --count "200|300" /tmp/response_codes
egrep --invert-match --count "200|300" /tmp/response_codes
```
