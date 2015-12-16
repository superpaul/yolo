### riak-cs demo

## install and configure s3cmd
sudo apt-get install s3cmd git tidy libdigest-hmac-perl --yes
s3cmd --configure
 # access key is admin key
 # secret key is admin secret
 # http proxy server is riak-cs IP (hostname --fqdn)
 # http proxy port is riak-cs port (8080)

## install and configure s3curl
wget https://raw.githubusercontent.com/rtdp/s3curl/master/s3curl.pl && chmod u+x s3curl.pl
vim ~/.s3curl
 # access key is admin key
 # secret key is admin secret
chmod 600 ~/.s3curl

## generate testfiles
dd if=/dev/urandom of=prvfile bs=1MB count=2
dd if=/dev/urandom of=pubfile bs=1MB count=3


### test riak-cs as a proxy server

## test upload and retrieval with s3cmd
# make testbucket
s3cmd mb s3://testbucket
# put testfile in test-bucket
s3cmd put prvfile s3://testbucket/
s3cmd put pubfile s3://testbucket/
# list acl on bucket/files
s3cmd info s3://testbucket/
s3cmd info s3://testbucket/prvfile
s3cmd info s3://testbucket/pubfile
# set public acl on pubtestfile
s3cmd setacl s3://testbucket/pubfile --acl-public
# list acl on pubtestfile
s3cmd info s3://testbucket/pubfile
# get files
wget http://testbucket.s3.amazonaws.com:8080/prvfile
wget http://testbucket.s3.amazonaws.com:8080/pubfile -O dlpubfile
# show md5s
md5sum pubfile
md5sum dlpubfile


## test using s3curl
# list buckets for admin user
./s3curl.pl --id admin -- -s -x localhost:8080 http://s3.amazonaws.com/ | tidy -xml -indent
# list users on the system
./s3curl.pl --id admin -- -s -x localhost:8080 http://s3.amazonaws.com/riak-cs/users | tidy -xml -indent
# as admin, create a new user with anonymous_user_creation false 
./s3curl.pl --id admin --post --contentType application/json -- -s -x localhost:8080 http://s3.amazonaws.com/riak-cs/user --data '{"email":"foobar@example.com", "name":"foo bar"}'
# get a buckets acl
./s3curl.pl --id admin -- -s -x localhost:8080 http://s3.amazonaws.com/testbucket?acl | tidy -xml -indent
# get an objects acl
./s3curl.pl --id admin -- -s -x localhost:8080 http://s3.amazonaws.com/testbucket/prvfile?acl | tidy -xml -indent





### test riak-cs via direct access

## reconfigure for direct access

# hack /etc/hosts for direct access demo
 # 127.0.0.1 riak-cs.localhost
 # 127.0.0.1 testbucket.localhost

# set cs_root_host in riak-cs app.config
sudo sed -e 's/s3.amazonaws.com/localhost/g' \
         -i.bak /etc/riak-cs/app.config
# restart riak-cs
sudo riak-cs restart

# reconfigure s3cmd for direct access
vim .s3cfg
 # set host_base and host_bucket in .s3cfg (don't forget port on host_base for demo)
 # clear proxy_host and set proxy_port to 0

# reconfigure s3curl for direct access
vim s3curl.pl 
 # add s3curl.pl endpoint (not including port for demo)

## test direct with s3cmd
# list acl on bucket/files
s3cmd info s3://testbucket/
s3cmd info s3://testbucket/prvfile
s3cmd info s3://testbucket/pubfile

## test direct using s3curl
# list testbucket contents
./s3curl.pl --id admin -- -s -v http://testbucket.localhost:8080/ | tidy -xml -indent
# get testbucket acl
./s3curl.pl --id admin -- -s -v http://testbucket.localhost:8080/?acl | tidy -xml -indent
# list users
./s3curl.pl --id admin -- -s -v http://riak-cs.localhost:8080/users | tidy -xml -indent
# as admin, create a new user with anonymous_user_creation false 
./s3curl.pl --id admin --post --contentType application/json -- -s --data '{"email":"foobar@example.com", "name":"foo bar"}' http://riak-cs.localhost:8080/user
# as admin, disable a user account 
./s3curl.pl --id admin --post --contentType application/json -- -s --data '{"status":"disabled"}' http://riak-cs.localhost:8080/user/IBP3YYSISHAOJAG18ZTH
# as admin, delete a user account
 # deleting accounts not supported


## tail logs
tail -f /var/log/{riak-cs,stanchion,riak}/console.log