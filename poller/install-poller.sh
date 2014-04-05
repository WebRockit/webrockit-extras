#!/bin/sh

### This has been tested with CentOS 6.x x86_64
###
### Automate this by running:
###    curl -L http://x.co/wrclientc6  | bash -s stable

# Install some base requirements
yum -y install wget freetype fontconfig

# Install WebRockit repo
wget http://yum.webrockit.io/repos/webrockit.repo -O /etc/yum.repos.d/webrockit.repo

# Install webRockit poller packages
yum -y install webrockit-poller webrockit-phantomas webrockit-nodejs-bin

# TODO: convert this to use Sensu omnibus ruby
# Install ruby 2.0 with rvm, as root under CentOS 5
curl -L get.rvm.io |  bash -s stable
source /etc/profile.d/rvm.sh
rvm requirements
rvm install 2.0.0-p451
rvm use 2.0.0-p451 --default
rvm rubygems current

# Install gem: ghost
gem install ghost

# adjust sensu to match number of cores available x2, with a minimum of 4
CORES=`grep processor /proc/cpuinfo | tail -n1 | awk '{print $NF+1}'`
if [ ${CORES} -lt 4 ]; then CORES=4; fi
if [ -e "/opt/sensu/embedded/lib/ruby/gems/2.0.0/gems/eventmachine-1.0.3/lib/eventmachine.rb" ]; then
  sed -i -c -e 's/EventMachine.threadpool_size\ =\ 20/EventMachine.threadpool_size\ =\ '${CORES}'/g' /opt/sensu/embedded/lib/ruby/gems/2.0.0/gems/eventmachine-1.0.3/lib/eventmachine.rb
fi

# why aren't you using sudoers.d?
bash -c "egrep -q '^#includedir /etc/sudoers.d$' /etc/sudoers || sudo -- echo '#includedir /etc/sudoers.d' >> /etc/sudoers"

# TODO: move this into poller rpm
egrep -q GEM_HOME /etc/sudoers.d/sensu || echo 'Defaults:sensu env_keep=GEM_HOME' >> /etc/sudoers.d/sensu

# test poller:

/opt/phantomjs/collectoids/webrockit-poller/webrockit-poller.rb --url http://github.com
