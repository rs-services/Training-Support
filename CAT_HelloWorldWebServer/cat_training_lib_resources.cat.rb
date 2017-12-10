
name 'TRAINING - Common Resources'
rs_ca_ver 20160622
short_description 'Common set of resource declarations used for CAT training.'

package "common/cat_training_resources"

import "common/cat_training_mappings"
import "common/cat_training_parameters"


##############
# RESOURCES  #
##############

resource "ssh_key", type: "ssh_key" do
  name join(["sshkey_", last(split(@@deployment.href,"/"))])
  cloud map($map_cloud, $param_location, "cloud")
end

resource "sec_group", type: "security_group" do
  name join(["WebServerSecGrp-",@@deployment.href])
  description "Hello World web server security group."
  cloud map( $map_cloud, $param_location, "cloud" )
end

resource "sec_group_rule_http", type: "security_group_rule" do
  name join(["WebServerHttp-",@@deployment.href])
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
  name join(["WebServerSsh-",@@deployment.href])
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





## In order for this CAT to compile, the parameters passed to map()
## must exist. When this package is consumed, the consuming CAT will
## redefine these

mapping "map_cloud" do 
  like $cat_training_mappings.map_cloud
end

mapping "map_instance_type" do 
  like $cat_training_mappings.map_instance_type 
end

parameter "param_location" do
  like $cat_training_parameters.param_location
end

parameter "param_performance" do 
  like $cat_training_parameters.param_performance
end

parameter "param_webtext" do 
  like $cat_training_parameters.param_webtext
end

