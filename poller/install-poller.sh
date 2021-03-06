#!/bin/sh

### This has been tested with CentOS 6.x x86_64
###
### Automate this by running:
###    curl -L http://x.co/wrclientc6  | bash -s stable

# We need the Sensu client to be installed. Let's check for it.
if [ ! -e /opt/sensu/embedded/bin/gem ]; then
   echo "Please install the Sensu client."
   echo "See:  http://sensuapp.org/docs/0.12/guide"
   echo ""
   echo "CentOS Quick Client Install:"
   echo "########################"
   echo "echo '[sensu]"
   echo "name=sensu-main"
   echo "baseurl=http://repos.sensuapp.org/yum/el/\$releasever/\$basearch/"
   echo "gpgcheck=0"
   echo "enabled=1' > /etc/yum.repos.d/sensu.repo"
   echo "yum -y install sensu"
   exit
fi

export OLD_GEM_PATH=${GEM_PATH}
export GEM_PATH=/opt/sensu/embedded/lib/ruby/gems/2.0.0:${GEM_PATH}
# Install gem: ghost, into Sensu path
/opt/sensu/embedded/bin/gem install ghost
# fix ghost to use sensu's ruby
sed -i -c -e '1s/^.*$/#!\/opt\/sensu\/embedded\/bin\/ruby/' /opt/phantomjs/collectoids/webrockit-poller/ghost
export GEM_PATH=${OLD_GEM_PATH}

# Install some base requirements
yum -y install wget freetype fontconfig

# Install WebRockit repo
wget http://yum.webrockit.io/repos/webrockit.repo -O /etc/yum.repos.d/webrockit.repo

# Install webRockit poller packages
yum -y install webrockit-poller webrockit-phantomas webrockit-nodejs-bin


# adjust sensu to match number of cores available x2, with a minimum of 4
CORES=`grep processor /proc/cpuinfo | tail -n1 | awk '{print $NF+1}'`
if [ ${CORES} -lt 4 ]; then CORES=4; fi
if [ -e "/opt/sensu/embedded/lib/ruby/gems/2.0.0/gems/eventmachine-1.0.3/lib/eventmachine.rb" ]; then
  sed -i -c -e 's/EventMachine.threadpool_size\ =\ 20/EventMachine.threadpool_size\ =\ '${CORES}'/g' /opt/sensu/embedded/lib/ruby/gems/2.0.0/gems/eventmachine-1.0.3/lib/eventmachine.rb
fi

# why aren't you using sudoers.d?
bash -c "egrep -q '^#includedir /etc/sudoers.d$' /etc/sudoers || sudo -- echo '#includedir /etc/sudoers.d' >> /etc/sudoers"

# test poller:

/opt/phantomjs/collectoids/webrockit-poller/webrockit-poller.rb --url http://github.com
