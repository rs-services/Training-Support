#
#The MIT License (MIT)
#
#Copyright (c) 2014 By Mitch Gerdisch
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.


#RightScale Cloud Application Template (CAT)

# DESCRIPTION
# Basic CAT file to introduce Self-Service and CATs.
# Uses a "Hello World Web Server" server template which is simply a Base Linux ServerTemplate with
# a script that installs httpd and drops in an index.html file with a line of text defined by an input.
#
# PREREQUISITES and CAT PREPARATION:
#   Server Template: A server template called "Hello World Web Server" must exist for the account being used.
#     This server template must have a rightscript called helloworld_rightscript that can be invoked.
#     The server template must be able to be deployed to the clouds specified in the map_cloud mapping below.
#   SSH Key:
#     The account must have an SSH key named "default"
#       You do not need to know the private key for "default" since you can use your personal SSH key for any access needed.

name 'TRAINING - Hello World Web Server CAT'
rs_ca_ver 20160622
short_description 'Automates the deployment of a simple single VM server.'

##################
# Imports        #
##################

import "common/cat_training_resources"
import "common/cat_training_parameters"
import "common/cat_training_mappings"
import "common/cat_training_helper_functions"

##############
# PARAMETERS 
# Inputs provided by users when launching the cloud application.
##############

parameter "param_location" do
  like $cat_training_parameters.param_location
end

parameter "param_performance" do 
  like $cat_training_parameters.param_performance
end

# What text does the user want the web server to display when browser is pointed at it.
parameter "param_webtext" do 
  like $cat_training_parameters.param_webtext
end

# Project ID for the application
parameter "param_projectid" do
  like $cat_training_parameters.param_projectid 
end


##############
# MAPPINGS   #
##############

# Maps the user's selected performance level into a specific instance type.
mapping "map_instance_type" do 
  like $cat_training_mappings.map_instance_type 
end

# Maps the user's selected cloud into a specific cloud or region.
mapping "map_cloud" do 
  like $cat_training_mappings.map_cloud 
end

##############
# RESOURCES  #
##############

resource "ssh_key", type: "ssh_key" do
  like $cat_training_resources.ssh_key 
end

#resource "sec_group", type: "security_group" do
#  like $cat_training_resources.sec_group 
#end
#
#resource "sec_group_rule_http", type: "security_group_rule" do
#  like $cat_training_resources.sec_group_rule_http 
#end
#
#resource "sec_group_rule_ssh", type: "security_group_rule" do
#  like $cat_training_resources.sec_group_rule_ssh 
#end


#resource "web_server", type: "server" do
#  like $cat_training_resources.web_server 
#end
#
###############
## CONDITIONS #
###############
#
## Checks if being deployed in AWS.
## This is used to decide whether or not to pass an SSH key and security group when creating the servers.
#condition "inAWS" do
#  equals?(map($map_cloud, $param_location,"provider"), "AWS")
#end
#
#
###############
## OUTPUTS    #
###############
#
#output "server_url" do
#  label "Server URL" 
#  category "Connect"
#  default_value join(["http://", @web_server.public_ip_address])
#  description "Access the web server page."
#end
#
#
################
### Operations #
################
#
## Allows user to modify the web page text.
#operation "update_web_page" do
#  label "Update Web Page"
#  description "Modify the web page text."
#  definition "update_webtext"
#end
#
#operation "enable" do
#  description "Post launch actions"
#  definition "post_launch"
#end
#
###############
## Definitions#
###############
#
## 
## Perform custom enable operation.
## 
#define post_launch($param_projectid) do
#  #Add project id tag to the server
#  $tags=[join(["project:id=",$param_projectid])]
#  rs.tags.multi_add(resource_hrefs: @@deployment.servers().current_instance().href[], tags: $tags)
#end
#
#
##
## Modify the web page text
##
#define update_webtext(@web_server, $param_webtext) do
#  task_label("Update Web Page")
#  call run_script(@web_server, "training_helloworld_update_rightscript", {WEBTEXT: "text:"+$param_webtext})
#end


