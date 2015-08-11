#!/bin/bash -e

# Make sure the server packages are up to date
apt-get update

# Add the RightScale Repo Key to Apt
curl http://mirror.rightscale.com/rightlink/rightscale.pub > /tmp/rightscale.pub
apt-key add /tmp/rightscale.pub
rm -rf /tmp/rightscale.pub

# Pin the Collectd Version
cat << EOF > /etc/apt/preferences.d/rightscale-collectd-pin-1001
# Collectd 5 is not currently supported by the RightScale monitoring servers
# Pin to previous version from "precise" to avoid issues. These packages are
# available from http://mirror.rightscale.com/rightscale_software_ubuntu

Package: collectd
Pin: version 4.10.1-2.1ubuntu7
Pin-Priority: 1001

Package: collectd-core
Pin: version 4.10.1-2.1ubuntu7
Pin-Priority: 1001
EOF

# Add the RightLink Repository to Apt
cat << EOF > /etc/apt/sources.list.d/rightlink.list
# RightLink Repository
deb [arch=amd64] http://mirror.rightscale.com/rightlink/apt/ trusty main
EOF

# Add the RightScale Extra Repository to Apt 
cat << EOF > /etc/apt/sources.list.d/rightscale_extra.sources.list
deb http://island10.rightscale.com/rightscale_software_ubuntu/latest trusty main
EOF

# Setup RightScale specific settings
cat << EOF > /etc/cloud/cloud.cfg.d/20_rightscale.cfg
# RightScale-specific settings
apt_update: false
apt_upgrade: false
apt_preserve_sources_list: true
EOF

# Update repository list and install RightLink for EC2 with Extra Packages 
apt-get update
apt-get install -y rightlink-cloud-ec2 rightimage-extras-base

##### Start Custom Image Setup #####
# Place custom configuration here

# apt-get install -y git httpd
# cd /var/www/
# git clone https://github.com/... /h
##### END Custom Image Setup #####

