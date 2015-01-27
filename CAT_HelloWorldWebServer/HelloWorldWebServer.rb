#
#The MIT License (MIT)
#
#Copyright (c) 2014 BMitch Gerdisch
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
# Super basic CAT file to introduce Self-Service and CATs.
# Uses a "Hello World Web Server" server template which is simply a Base Linux ServerTemplate with
# a script that installs httpd and drops in an index.html file with a line of text defined by an input.
#
# PREREQUISITES and CAT PREPARATION:
#   Server Template: A server template called "Hello World Web Server" must exist for the account being used.
#     This server template must have a rightscript that can be invoked.
#     The server template must be able to be deployed to the clouds specified in the map_cloud mapping below.
#   map_account: 
#     The map_account mapping below must point to an ssh_key that exists in the account and cloud being used.
#     The hello_world_script key must point to the HREF number for a script that is able to be invoked in the ServerTemplate. See prerequisite above.


name 'Hello World Web Server - CHANGEME'
rs_ca_ver 20131202
short_description 'Automates the deployment of a simple single VM server.'

##############
# PARAMETERS 
# Inputs provided by users when launching the cloud application.
##############

# Which cloud?
# Maps to specific cloud below.
parameter "param_location" do 
  category "Deployment Options"
  label "Cloud" 
  type "string" 
  description "Cloud to deploy in." 
  allowed_values "AWS-US-East", "AWS-US-West"
  default "AWS-US-East"
end

# What type of instance?
# Maps to a specific instance type below.
parameter "param_performance" do 
  category "Deployment Options"
  label "Performance profile" 
  type "string" 
  description "Compute and RAM" 
  allowed_values "low", "medium", "high"
  default "low"
end

# What text does the user want the web server to display when browser is pointed at it.
parameter "param_webtext" do 
  category "Application Options"
  label "Web Text" 
  type "string" 
  description "Text to display on the web server." 
  default "Hello World!"
end



##############
# MAPPINGS   #
##############

# Maps the user's selected performance level into a specific instance type.
mapping "map_instance_type" do {
  "AWS" => {
    "low" => "m1.small",  
    "medium" => "m1.medium", 
    "high" => "c3.large", 
  },
}
end

# Maps the user's selected cloud into a specific cloud or region.
mapping "map_cloud" do {
  "AWS-US-East" => {
    "provider" => "AWS",
    "cloud" => "us-east-1",
  },
  "AWS-US-West" => {
    "provider" => "AWS",
    "cloud" => "us-west-1",
  },
}
end

# *** CHANGEME CHANGEME CHANGEME ***
# Account specific mappings
mapping "map_account" do {
  "training_account" => {
    "ssh_key" => "default", # Be sure there is an ssh key called default or change this to an ssh key that does exist for the account. You do NOT need to have access to the private key.
    "hello_world_script" => "12345678",  # This is the HREF number for the hello world script in the Hello World server template.
  },
}
end


##############
# CONDITIONS #
##############

# Checks if being deployed in AWS.
# This is used to decide whether or not to pass an SSH key and security group when creating the servers.
condition "inAWS" do
  equals?(map($map_cloud, $param_location,"provider"), "AWS")
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


##############
# RESOURCES  #
##############

resource "sec_group", type: "security_group" do
  name join(["HelloWorldSecGrp-",@@deployment.href])
  description "Hello World web server security group."
  cloud map( $map_cloud, $param_location, "cloud" )
end

resource "sec_group_rule_http", type: "security_group_rule" do
  name "HelloWorld Security Group HTTP Rule"
  description "Allow HTTP access."
  source_type "cidr_ips"
  security_group @sec_group
  protocol "tcp"
  direction "ingress"
  cidr_ips "0.0.0.0/0"
  protocol_details do {
    "start_port" => "80",
    "end_port" => "80"
  } end
end

resource "sec_group_rule_ssh", type: "security_group_rule" do
  name "HelloWorld Security Group SSH Rule"
  description "Allow SSH access."
  source_type "cidr_ips"
  security_group @sec_group
  protocol "tcp"
  direction "ingress"
  cidr_ips "0.0.0.0/0"
  protocol_details do {
    "start_port" => "22",
    "end_port" => "22"
  } end
end


resource "web_server", type: "server" do
  name "Hello World Web Server"
  cloud map( $map_cloud, $param_location, "cloud" )
  instance_type  map( $map_instance_type, map( $map_cloud, $param_location,"provider"), $param_performance)
  server_template find("Hello World Web Server")
  ssh_key switch($inAWS, map($map_account, "training_account", "ssh_key"), null)
  security_groups @sec_group
  inputs do {
    "WEBTEXT" => join(["text:", $param_webtext])
  } end
end


###############
## Operations #
###############

# Allows user to modify the web page text.
operation "Update Web Page" do
  description "Modify the web page text."
  definition "update_webtext"
end


##############
# Definitions#
##############

#
# Modify the web page text
#
define update_webtext(@web_server, $map_account, $param_webtext) do
  task_label("Update Web Page")
  $hello_world_script = map( $map_account, "training_account", "hello_world_script" )
  call run_script(@web_server,  join(["/api/right_scripts/", $hello_world_script]), {WEBTEXT: "text:"+$param_webtext}) 
end


# Helper definition, runs a script on given server, waits until script completes or fails
# Raises an error in case of failure
define run_script(@target, $right_script_href, $script_inputs) do
  @task = @target.current_instance().run_executable(right_script_href: $right_script_href, inputs: $script_inputs)
  sleep_until(@task.summary =~ "^(completed|failed)")
  if @task.summary =~ "failed"
    raise "Failed to run " + $right_script_href
  end
end
