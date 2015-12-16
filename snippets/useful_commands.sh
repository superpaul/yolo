
# consider all partitions in this directory and print those which should not be part of the ring
# ring_size 512 (2^160 / 2^151 = 512)
for p in ./*; do if [ $(echo "scale=0; $(basename $p) % 2^151" | bc -q) != 0 ]; then echo $p; fi; done
# ring_size 1024 (2^160 / 2^150 = 1024)
for p in ./*; do if [ $(echo "scale=0; $(basename $p) % 2^150" | bc -q) != 0 ]; then echo $p; fi; done

# from an unpacked list of riak-debug output, list partitions and which node debug they are within
# (unsorted)
ls -R riak* | grep "leveldb-be_default/" | cut -d "/" -f1 -f4 > cluster_partitions
# (sorted by partition)
ls -R riak* | grep "leveldb-be_default/" | cut -d "/" -f1 -f4 | sed -e "s/://" -e "s/\// /" | awk {'print $2 " " $1'} | sort -n > cluster_partitions

# unpack multiple tar.gz archives recursively in one dir (e.g. Nokia archive from Ilkka)
find . -name "*.tar.gz" | xargs -n1 tar xf
