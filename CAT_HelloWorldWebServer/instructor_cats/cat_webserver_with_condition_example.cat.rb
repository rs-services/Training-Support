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
# Launches a basic "Hello World" web server.
#
# PREREQUISITES and CAT PREPARATION:
#   Server Template: A server template called "Training Hello World Web ServerTemplate" must exist for the account being used.
#     This server template must have a rightscript called "Training Hello World Web RightScript" that can be invoked.
#     The server template must be able to be deployed to the clouds specified in the map_cloud mapping referenced below.
#   The import package files need to be uploaded. 
#
# FILES LOCATION:
#   This CAT file and related import files can be found at: https://github.com/rs-services/Training-Support/tree/master/CAT_HelloWorldWebServer
#

name 'TRAINING - Hello World Web Server CAT'
rs_ca_ver 20160622
short_description 'Automates the deployment of a simple web server.'
long_description 'Launches one or two web servers as specified by the user. The web servers display user-provided text. The user can modify that text after launch.'

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

# Contrived example to show how conditions work
parameter "param_extra_server" do
  category "Deployment Options"
  label "Extra Server?" 
  type "string" 
  description "Whether or not you want to launch two hello world servers instead of just one." 
  allowed_values "Yes", "No"
  default "No"
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
end

# This web_server_2 is only launched if the user indicated they wanted an extra server.
# Notice the use of the like option to point at the other web_server configuration.
resource "web_server_2", type: "server" do
  condition $extraServer
  like @web_server
  name join(["WebServer2-",last(split(@@deployment.href,"/"))])
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

# Checks if user wants to launch an extra server.
condition "extraServer" do
  equals?($param_extra_server, "Yes")
end


##############
# OUTPUTS    #
##############

output "server_url" do
  label "Server URL" 
  category "Connect"
  default_value join(["http://", @web_server.public_ip_address])
  description "Access the web server page."
end

output "server_2_url" do
  condition $extraServer
  label "Server #2 URL" 
  category "Connect"
  default_value join(["http://", @web_server_2.public_ip_address])
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
  call cat_training_helper_functions.run_script(@web_servers, "Training Hello World Web RightScript", {WEBTEXT: "text:"+$param_webtext})
    
end


