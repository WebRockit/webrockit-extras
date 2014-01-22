yum -y install http://yum.basho.com/gpg/basho-release-5-1.noarch.rpm
yum -y install riak
sed -i 's/riak_kv_bitcask_backend/riak_kv_eleveldb_backend/g' /etc/riak/app.config
grep storage_backend /etc/riak/app.config |grep riak_kv_eleveldb_backend ||echo "ERROR"
chkconfig riak on
echo '*               soft     nofile          65536' >> /etc/security/limits.conf
echo '*               hard     nofile          65536' >> /etc/security/limits.conf
/etc/init.d/riak start
