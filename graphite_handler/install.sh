mkdir -p /etc/sensu/handlers/metrics
cp webrockit_graphite.rb /etc/sensu/handlers/metrics/
chmod 755 /etc/sensu/handlers/metrics/webrockit_graphite.rb

mkdir -p /etc/sensu/conf.d/handlers
cp webrockit.json /etc/sensu/conf.d/handlers/
