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


# DESCRIPTION
# Basic CAT file to introduce Self-Service and CATs.
# Launches a basic "Hello World" web server.
#
# PREREQUISITES
# The student has gone through the ServerTemplate exercise and created a basic Hello World ServerTemplate.
# Or the instructor has provided the ServerTemplate.
#
# REQUIRED MODIFICATIONS:
#   - Specify a name for the CAT (around line 36)
#   - Specify the name of your Hello World ServerTemplate in the server declarateion (around line 98)
#   - Update the update_webtext() definition to use your web text setting RightScript you developed for the Hello World ServerTemplate (around line 177)
#   
# FILES LOCATION:
#   This CAT file and related import files can be found at: https://github.com/rs-services/Training-Support/tree/master/CAT_HelloWorldWebServer
#

name # See http://docs.rightscale.com/ss/reference/cat/v20160622/index.html#fields
rs_ca_ver 20160622
short_description 'Automates the deployment of a simple web server.'

##################
# Imports        #
##################

import "common/cat_training_parameters"
import "common/cat_training_mappings"
import "common/cat_training_helper_functions"
import "common/cat_training_resources"

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

resource "web_server", type: "server" do
  like @cat_training_resources.web_server
  server_template # See find() as defined here: http://docs.rightscale.com/ss/reference/cat/v20160622/index.html#built-in-methods-and-other-keywords
                  # See server resource declaration info here: http://docs.rightscale.com/ss/reference/cat/v20160622/ss_CAT_resources.html#resources-server
end

resource "ssh_key", type: "ssh_key" do
  like @cat_training_resources.ssh_key
end

resource "sec_group", type: "security_group" do
  like @cat_training_resources.sec_group
end

resource "sec_group_rule_http", type: "security_group_rule" do
  like @cat_training_resources.sec_group_rule_http
end

resource "sec_group_rule_ssh", type: "security_group_rule" do
  like @cat_training_resources.sec_group_rule_ssh
end


##############
# CONDITIONS #
##############

# NONE at this time


##############
# OUTPUTS    #
##############

output "server_url" do
  label "Server URL" 
  category "Connect"
  default_value join(["http://", @web_server.public_ip_address])
  description "Access the web server page."
end


###############
## Operations #
###############

# Allows user to modify the web page text.
operation "update_web_page" do
  label "Update Web Page"
  description "Modify the web page text."
  definition "update_webtext"
end

operation "enable" do
  description "Post launch actions"
  definition "post_launch"
end

##############
# Definitions#
##############

# 
# Perform custom enable operation.
# 
define post_launch($param_projectid) do
  #Add project id tag to the server
  $tags=[join(["project:id=",$param_projectid])]
  rs_cm.tags.multi_add(resource_hrefs: @@deployment.servers().current_instance().href[], tags: $tags)
end


#
# Modify the web page text
#
define update_webtext($param_webtext) do
  task_label("Update Web Page")
  
  @web_servers = rs_cm.servers.get(filter: [ "deployment_href=="+to_s(@@deployment.href) ])
  # See the cat_traininglib_helper_functions.cat.rb for this function
  call cat_training_helper_functions.run_script(@web_servers, "YOUR_UPDATE_RIGHTSCRIPT_GOES_HERE", {WEBTEXT: "text:"+$param_webtext})
end

