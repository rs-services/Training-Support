#Copyright 2015 RightScale
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.


#RightScale Cloud Application Template (CAT)




# Required prolog
name 'Launch Raw Instances'
rs_ca_ver 20160622
short_description "CAT that launches a specified number of raw instances. Used to spin up a bunch of raw instances for the Enabling Running Instances training module."

############################
# INPUTS                   #
############################
parameter "param_num_students" do 
  category "User Inputs"
  label "Number of  Class Participants" 
  description "Raw instances will be created for each participant plus one for the instructor."
  type "number" 
  default 1
end


############################
# RESOURCE DEFINITIONS     #
############################

### Server Definition ###
resource "instance", type: "instance" do
  name "raw_instance"
  cloud "EC2 us-east-1"
  instance_type "m3.medium"
  ssh_key_href @ssh_key
  security_groups @sec_group
  image "ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-20160314"
end

### Security Group Definitions ###
# Note: Even though not all environments need or use security groups, the launch operation/definition will decide whether or not
# to provision the security group and rules.
resource "sec_group", type: "security_group" do
  name join(["LinuxServerSecGrp-",last(split(@@deployment.href,"/"))])
  description "Linux Server security group."
  cloud "EC2 us-east-1"
end

resource "sec_group_rule_ssh", type: "security_group_rule" do
  name join(["Linux server SSH Rule-",last(split(@@deployment.href,"/"))])
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

### SSH Key ###
resource "ssh_key", type: "ssh_key" do
  name join(["sshkey_", last(split(@@deployment.href,"/"))])
  cloud "EC2 us-east-1"
end


operation "launch" do 
  description "Launch the instance(s)"
  definition "launcher"
end

define launcher($param_num_students, @instance, @sec_group, @sec_group_rule_ssh, @ssh_key) return @instance, @sec_group_rule_ssh, @ssh_key do
  # Import the latest RL10 ST from the marketplace.
  # This is used as part of the training module to wrap the instance.
  call import_latest_rl10_st_from_marketplace()
  
  # Provision dependencies
  provision(@ssh_key)
  provision(@sec_group_rule_ssh)
  
  # Now cycle through and launch the requested number of instances
  $instance_num = 1
  $instance_hash = to_object(@instance)
  $instance_base_name = $instance_hash["fields"]["name"]
  while $instance_num <= $param_num_students do
    $instance_hash["fields"]["name"] = $instance_base_name + "-" + to_s($instance_num)
    @modified_instance = $instance_hash
    provision(@modified_instance)
    $instance_num = $instance_num + 1
  end
  
  # Now make one for the instructor
  $instance_hash["fields"]["name"] = $instance_base_name + "-instructor"
  @instance = $instance_hash
  provision(@instance)
end


define import_latest_rl10_st_from_marketplace() do
  @pub_st=last(rs_cm.publications.index(filter: ["name==RightLink 10.", "name==Linux Base"]))
  @pub_st.import()
end

