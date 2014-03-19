#!/bin/sh

### This has been tested with CentOS 6.x x86_64
###
### Automate this by running:
###    curl -L http://x.co/wrchecksyncc6  | bash -s stable

# Install some base requirements
yum -y install wget freetype fontconfig

# Install WebRockit repo
wget http://yum.webrockit.io/repos/webrockit.repo -O /etc/yum.repos.d/webrockit.repo

# Install webRockit checksync packages
yum -y install webrockit-checksync
