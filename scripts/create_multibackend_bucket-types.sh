sudo riak-admin bucket-type create leveldb_backend '{"props":{"backend":"leveldb_mult"}}'
sudo riak-admin bucket-type activate leveldb_backend2
sudo riak-admin bucket-type create bitcask_backend '{"props":{"backend":"bitcask_mult"}}'
sudo riak-admin bucket-type activate bitcask_backend2
