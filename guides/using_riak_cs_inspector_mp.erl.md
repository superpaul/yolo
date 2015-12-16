* use `riak_cs_inspector_mp.erl` to list users

```
$ riak-cs escript /root/riak_cs_inspector_mp.erl user list

Connecting to localhost:8087...
Key ID ================================= Sibl. == Name =================================== Secret =================================
0QFIFCKF5KTKMNT2NKGF                            1 admin                                    GWzKme017gRqSdUXigVSDcpzkOULCyj5mG0aWw==
7R13BCBVTQ_5XJXWUQBR                            1 test1                                    iM0XYshk1azHs18ilDuymol79j_mTHxEs1f4aQ==
GYUUQEKM-O-7NDKNNGHQ                            1 test2                                    BrdmQ_FCIjAe7FUoEAToCry-I_fJLvOYDO8oOw==
```

* use `riak_cs_inspector_mp.erl` to list _all_ buckets

```
$ riak-cs escript /root/riak_cs_inspector_mp.erl bucket list

Connecting to localhost:8087...
CS Bucket Name ================================================= Sibl. == Owner Key ==============================
test1-bucket1                                                    1        7R13BCBVTQ_5XJXWUQBR                    
test2-bucket1                                                    1        GYUUQEKM-O-7NDKNNGHQ                    
admin-bucket1                                                    1        0QFIFCKF5KTKMNT2NKGF                    
admin-bucket2                                                    1        0QFIFCKF5KTKMNT2NKGF      
```

* per user we can filter the bucket list (to be clear you don't need to filter by user, but this may be a logical approach to tackle a user at a time)

```
# riak-cs escript /root/riak_cs_inspector_mp.erl bucket list | grep <user key id>
$ riak-cs escript /root/riak_cs_inspector_mp.erl bucket list | grep 0QFIFCKF5KTKMNT2NKGF

Connecting to localhost:8087...
CS Bucket Name ================================================= Sibl. == Owner Key ==============================
admin-bucket1                                                    1        0QFIFCKF5KTKMNT2NKGF                    
admin-bucket2                                                    1        0QFIFCKF5KTKMNT2NKGF                    
```

* for each user and bucket we list the objects

```
# riak-cs escript /root/riak_cs_inspector_mp.erl object list <bucket>
$ riak-cs escript /root/riak_cs_inspector_mp.erl object list admin-bucket1

Connecting to localhost:8087...
Key ============================ Sibl. == State ========== UUID =========================== Content-Length== Type ==== First Block ====
largefile                        1        active           e8caf524aea84fe78c4e8c56230d1496         50000000 multipart Found           
prvfile                          1        active           4446e7214b534cd9b1fd1cf49181c6e5          2000000 normal    Found           
pubfile                          1        active           7cc0338f028d41ad819804709b468061          3000000 normal    Found       
```

* for each object we list the blocks 
* __Note: A BLOCK LIST TRIGGERS BLOCK READ-REPAIR!__

```
$ riak-cs escript /root/riak_cs_inspector_mp.erl block list <bucket> <key> <UUID>
$ riak-cs escript /root/riak_cs_inspector_mp.erl block list admin-bucket1 pubfile 7cc0338f028d41ad819804709b468061

Connecting to localhost:8087...
Blocks in object [pubfile/7cc0338f028d41ad819804709b468061]:
UUID =========================== Seq ==== Size ===== Value(first 8 or 32 bytes) =====================================
7cc0338f028d41ad819804709b468061        0    1048576                                  <<221,158,91,99,181,124,168,5>>
7cc0338f028d41ad819804709b468061        1    1048576                                    <<87,145,61,62,97,38,86,136>>
7cc0338f028d41ad819804709b468061        2     902848                                  <<135,247,204,210,6,229,64,60>>
```

