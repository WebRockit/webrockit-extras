#!/bin/sh

### This has been tested with CentOS 6.x x86_64 
###  
### Automate this by running:  
###    curl -L http://x.co/wrclientc6  | bash -s stable

# Install some base requirements
yum -y install wget freetype fontconfig 

# Install WebRockit repo
wget https://bintray.com/webrockit/webrockit/rpm -O /etc/yum.repos.d/bintray-webrockit-webrockit.repo --no-check-certificate 

# Install webRockit poller packages
yum -y install webrockit-poller webrockit-phantomas webrockit-nodejs-bin

# Install ruby 2.0 with rvm
curl -L get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm requirements
rvm install 2.0
rvm use 2.0 --default
rvm rubygems current

# Install gem: ghost
gem install ghost

# test poller:

/opt/phantomjs/collectoids/webrockit-poller/webrockit-poller.rb --url http://github.com | egrep 'requests|notfound|redirects|timetofirstbyte|htmlsize|domains|contentlength|ondomreadytime|windowonloadtime|httptrafficcompleted'
