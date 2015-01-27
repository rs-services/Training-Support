#
# Cookbook Name:: httpd
# Recipe:: setup_index_page
#
# Copyright 2012, RightScale <ryan.geyer@rightscale.com>
#
# All rights reserved - Do Not Redistribute
#

# Make sure apache is installed first
include_recipe "httpd::install_httpd"

template "/var/www/index.html" do
  source "index.html.erb"
  mode 0644
  action :create
end