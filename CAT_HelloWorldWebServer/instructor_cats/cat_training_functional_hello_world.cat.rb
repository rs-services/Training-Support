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
# ADVANCED/OPTIONAL MODIFICATIONS:
#   - Raise an error if the server does not achieve operational state when (re)starting. See the "start_server()" definition.
#   - When updating the webtext through the more actions button, update the server input to store this value so subsequent stop/starts will retain the value. 
#       (Hint: use the built-in multi_update_inputs() function.)
# 
# FILES LOCATION:
#   This CAT file and related import files can be found at: https://github.com/rs-services/Training-Support/tree/master/CAT_HelloWorldWebServer
#

name "Instructor - Hello World CAT"
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
  server_template find("Training Hello World Web ServerTemplate")
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
  
  # This is a way to drive output values from RCL.
  output_mappings do {
    $server_url => $web_server_link,
  } end
end

# Default stop/start behavior in CAT is to terminate/(re)launch the server.
# By defining custom stop/start operations, this default behavior can be overridden.
# In this case, we do a "stop" which releases the CPU and RAM but keeps the EBS drive around.
# The "start" then launches using that existing EBS drive.
operation "stop" do
  description "Server stop"
  definition "stop_server"
end

operation "start" do
  description "Server start"
  definition "start_server"
  
  # This is a way to drive output values from RCL.
  output_mappings do {
    $server_url => $web_server_link,
  } end
end

##############
# Definitions#
##############

# 
# Perform custom enable operation.
# 
define post_launch(@web_server, $param_projectid) return $web_server_link do
  #Add project id tag to the server
  $tags=[join(["project:id=",$param_projectid])]
  rs_cm.tags.multi_add(resource_hrefs: @@deployment.servers().current_instance().href[], tags: $tags)
  
  # Get the link to the web server
  call get_server_link(@web_server) retrieve $web_server_link

end

#
# Stop and Start operations
# 
define stop_server(@web_server) return @web_server do
  @web_server.current_instance().stop()
  sleep_until(@web_server.state == "provisioned")
end

define start_server(@web_server) return @web_server, $web_server_link do
  @web_server.current_instance().start()
  sleep_until(@web_server.state == "operational" || @web_server.state == "stranded")
  
  # If it's not happy raise an error which will show in SS UI
  if @web_server.state != "operational"
    raise "Server restart failed."
  end
  
  # Get the link to the web server with the (likely) new IP address)
  call get_server_link(@web_server) retrieve $web_server_link

end


#
# Modify the web page text
#
define update_webtext($param_webtext) do
  task_label("Update Web Page")
  
  # This is a rather unnecessary approach since I know I have just the one web server resource but this logic is not affected if later we add multiple web servers.
  # That said the run_script() function assumes a collection
  @web_servers = rs_cm.servers.get(filter: [ "deployment_href=="+to_s(@@deployment.href) ])
    
  # Prepare the input hash
  $inp = {WEBTEXT: "text:"+$param_webtext}
    
  # Update the server level inputs with the updated webtext.
  call update_servers_inputs(@web_servers, $inp)
  
  # Call a function to run the rightscript that updates the webtext.
  # See the cat_training_lib_helper_functions.cat.rb for this function
  call cat_training_helper_functions.run_script(@web_servers, "training_helloworld_update_rightscript",  $inp)
end

#
# Helper function to update the server inputs
# 
define update_servers_inputs(@servers, $input_hash) do
  @servers.current_instance().multi_update_inputs(inputs: $inp)
end


#
# Helper function to get the server link
# 
define get_server_link(@server) return $server_link do
  
  # Make sure the IP address is seen before trying to get it
  sleep_until(logic_not(equals?(@server.current_instance().public_ip_addresses[0], null)))
  
  $server_link = "http://"+@server.current_instance().public_ip_addresses[0]
end


