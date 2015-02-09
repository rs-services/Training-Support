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
# CAT that deploys a Puppet Master server (optionally) and a Puppet Client server.
#
# PREREQUISITES and CAT PREPARATION:
#   Server Templates: 
#     Master Server ServerTemplate:
#       See the Puppet_Master_Config_RightScript found here: https://github.com/rs-services/Training-Support/blob/master/Puppet/Puppet_Master_Config_RightScript
#       It provides instructions on how to create the necessary rightscript and servertemplate.
#     Slave Server ServerTemplate:
#       Import "Puppet Client Beta (v13.5)"
#   SSH Key:
#     The account must have an SSH key named "default"
#       You do not need to know the private key for "default" since you can use your personal SSH key for any access needed.

name "Puppet Test Environment"
rs_ca_ver 20131202
short_description "![Puppet](http://upload.wikimedia.org/wikipedia/en/c/c5/Puppet_Labs_Logo.png)\n
Deploys a Puppet Clent server and optionally a Puppet Master server."
long_description "The Puppet Master is just for testing purposes. It is not production hardened.\n
The Puppet Client server grabs a basic nginx manifest from the master.\n
So you can easily see if things worked as expected by pointing your browser at the client server URL provided."

##############
# Mappings    #
##############

# This CAT is more about Puppet than multiple clouds and stuff.
# But it's still nice to have a single place to manage some of these settings.
#define main() do 
#  
#  $$cat_cloud = 'us-east-1'
#  $$cat_instance_type = 'm1.small'
#  $$cat_ssh_key = 'default'
#  $$master_servertemplate = 'Puppet Master Test Server'
#  $$client_servertemplate = 'Puppet Client Beta (v13.5)'
#  
#end

mapping "cat_map" do {
  "globals" => {
    "ssh_key" => "default",
    "cloud" => "us-east-1",
    "instance_type" => "m1.small",
    "master_servertemplate" => "Puppet Master Test Server",
    "client_servertemplate" => "Puppet Client Beta (v13.5)"
  },
}
end

##############
# PARAMETERS 
# Inputs provided by users when launching the cloud application.
##############

# If the user is not deploying a master server, then an IP or FQDN for the existing master needs to be provided.
parameter "param_master_address" do
  category "Deployment Options"
  label "If you already have a Puppet Master server you want to use, enter the IP address or FQDN of that server here:"
  type "string"
  default "NA"
end

##############
# CONDITIONS #
##############

# Checks if being deployed in AWS.
# This is used to decide whether or not to pass an SSH key and security group when creating the servers.
condition "launchMaster" do
  equals?($param_master_address, "NA")
end


##############
# OUTPUTS    #
##############

output "master_server_ip" do
  condition $launchMaster
  label "Puppet Master server IP address"
  category "Connect"
  default_value @master_server.public_ip_address
end

output "slave_server_ip" do
  label "Puppet Client server IP address" 
  category "Connect"
  default_value @client_server.public_ip_address
end

output "slave_server_URL" do
  label "Puppet Client server test URL" 
  category "Connect"
  default_value join(["http://", @client_server.public_ip_address])
  description "You should see a nginx splash page."
end

##############
# RESOURCES  #
##############

resource "puppetmaster_sec_group", type: "security_group" do
  name join(["PuppetMasterSecGrp-",@@deployment.href])
  condition $launchMaster
  description "Puppet Master security group."
  cloud map($cat_map, "globals", "cloud")
end

resource "puppetmastersec_group_rule_tcp8140", type: "security_group_rule" do
  name "PuppetMaster_TCP8140_rule"
  condition $launchMaster
  description "Allow port 8140 access - used by Puppet clients."
  source_type "cidr_ips"
  security_group @puppetmaster_sec_group
  protocol "tcp"
  direction "ingress"
  cidr_ips "0.0.0.0/0"
  protocol_details do {
    "start_port" => "8140",
    "end_port" => "8140"
  } end
end

resource "puppetmastersec_group_rule_ssh", type: "security_group_rule" do
  name "PuppetMaster_ssh_rule"
  condition $launchMaster
  description "Allow port ssh access"
  source_type "cidr_ips"
  security_group @puppetmaster_sec_group
  protocol "tcp"
  direction "ingress"
  cidr_ips "0.0.0.0/0"
  protocol_details do {
    "start_port" => "22",
    "end_port" => "22"
  } end
end

resource "puppetclient_sec_group", type: "security_group" do
  name join(["PuppetClientSecGrp-",@@deployment.href])
  description "Puppet Client security group."
  cloud map($cat_map, "globals", "cloud")
end

resource "puppetclientsec_group_rule_http", type: "security_group_rule" do
  name "PuppetClient_http_rule"
  description "Allow http access - used for testing things worked."
  source_type "cidr_ips"
  security_group @puppetclient_sec_group
  protocol "tcp"
  direction "ingress"
  cidr_ips "0.0.0.0/0"
  protocol_details do {
    "start_port" => "80",
    "end_port" => "80"
  } end
end

resource "puppetclientsec_group_rule_ssh", type: "security_group_rule" do
  name "PuppetClient_ssh_rule"
  description "Allow ssh access."
  source_type "cidr_ips"
  security_group @puppetclient_sec_group
  protocol "tcp"
  direction "ingress"
  cidr_ips "0.0.0.0/0"
  protocol_details do {
    "start_port" => "22",
    "end_port" => "22"
  } end
end

resource "master_server", type: "server" do
  name "Puppet Master Server"
  condition $launchMaster
  cloud map($cat_map, "globals", "cloud")
  instance_type  map($cat_map, "globals", "instance_type")
  server_template find(map($cat_map, "globals", "master_servertemplate"))
  ssh_key map($cat_map, "globals", "ssh_key")
  security_groups @puppetmaster_sec_group
  inputs do {
    "PUPPET_MASTER_DNS_NAMES" => "env:Puppet Master Server:PUBLIC_IP"
  } end
end

resource "client_server", type: "server" do
  name "Puppet Client Server"
  cloud map($cat_map, "globals", "cloud")
  instance_type  map($cat_map, "globals", "instance_type")
  server_template find(map($cat_map, "globals", "client_servertemplate"))
  ssh_key map($cat_map, "globals", "ssh_key")
  security_groups @puppetclient_sec_group
  inputs do {
    "puppet/client/puppet_master_address" => switch($launchMaster, "env:Puppet Master Server:PUBLIC_IP", join(["text:",$param_master_address]))
  } end
end


###############
## Operations #
###############

# No operations at this time.


##############
# Definitions#
##############

# No definitions at this time.



########## HELPER FUNCTIONS ############
## Helper definition, runs a script on given server, waits until script completes or fails
## Raises an error in case of failure
#define run_script(@target, $right_script_href, $script_inputs) do
#  @task = @target.current_instance().run_executable(right_script_href: $right_script_href, inputs: $script_inputs)
#  sleep_until(@task.summary =~ "^(completed|failed)")
#  if @task.summary =~ "failed"
#    raise "Failed to run " + $right_script_href
#  end
#end

# Run a rightscript or recipe on a server or instance collection.
#
# @param @target [ServerResourceCollection|InstanceResourceCollection] the
#   resource collection to run the executable on.
# @param $options [Hash] a hash of options where the possible keys are;
#   * ignore_lock [Bool] whether to run the executable even when the instance
#     is locked.  Default: false
#   * wait_for_completion [Bool] Whether this definition should block waiting for
#     the executable to finish running or fail.  Default: true
#   * inputs [Hash] the inputs to pass to the run_executable request.  Default: {}
#   * rightscript [Hash] a hash of rightscript details where the possible keys are;
#     * name [String] the name of the rightscript to execute
#     * revision [Int] the revision number of the rightscript to run.
#       If not supplied the "latest" (which could be HEAD) will be used.
#     * href [String] if specified href takes prescedence and defines the *exact*
#       rightscript and revision to execute
#     * revmatch [String] a ServerTemplate runlist name (one of "boot",
#       "operational","decomission").  When supplied only the "name" option
#       is considered and is required.  The RightScript which is executed will
#       be the one with the same name that is in the specified runlist.
#   * recipe [String] the recipe name to execute (must be associated with the
#     @target's ServerTemplate)
#
# @return @task [TaskResourceCollection] the task returned by the run_executable
#   request
#
# @see http://reference.rightscale.com/api1.5/resources/ResourceInstances.html#multi_run_executable
# @see http://reference.rightscale.com/api1.5/resources/ResourceTasks.html
define run_executable(@target,$options) return @tasks do
  @tasks = rs.tasks.empty()
  $default_options = {
    ignore_lock: false,
    wait_for_completion: true,
    inputs: {}
  }

  $merged_options = $options + $default_options

  # TODO: type() always returns just "collection" reported as line 11 in the doc
  # https://docs.google.com/a/rightscale.com/spreadsheets/d/1zEqFvhLDygFdxm588LGrHshpBgp41xvIeqjEVigdHto/edit#gid=0
  @instances = rs.instances.empty()
  $target_type = to_s(@target)
  #$target_type = type(@target)
  #if $target_type == "rs.servers"
  if $target_type =~ "servers"
    @instances = @target.current_instance()
  #elsif $target_type == "rs.instances"
  elsif $target_type =~ "instances"
    @instances = @target
  else
    raise "run_executable() can not operate on a collection of type "+$target_type
  end

  $run_executable_params_hash = {inputs: $merged_options["inputs"]}
  if contains?(keys($merged_options),["rightscript"])
    if contains?(keys($merged_options["rightscript"]),["revmatch"])
      if !contains?(keys($merged_options["rightscript"]),["name"])
        raise "run_executable() requires both 'name' and 'revmatch' when specifying 'revmatch'"
      end
      call instance_get_server_template(@instances) retrieve @server_template
      call server_template_get_rightscript_from_runnable_bindings(@server_template, $merged_options["rightscript"]["name"], {runlist: $merged_options["rightscript"]["revmatch"]}) retrieve $script_href
      if !$script_href
        raise "run_executable() unable to find RightScript named "+$merged_options["rightscript"]["name"]+" in the "+$merged_options["rightscript"]["revmatch"]+" runlist of the ServerTempate "+@server_template.name
      end
      $run_executable_params_hash["right_script_href"] = $script_href
    elsif any?(keys($merged_options["rightscript"]),"/(name|href)/")
      if contains?(keys($merged_options["rightscript"]),["href"])
        $run_executable_params_hash["right_script_href"] = $merged_options["rightscript"]["href"]
      else
        @scripts = rs.right_scripts.get(filter: ["name=="+$merged_options["rightscript"]["name"]])
        if empty?(@scripts)
          raise "run_executable() unable to find RightScript with the name "+$merged_options["rightscript"]["name"]
        end
        $revision = 0
        if contains?(keys($merged_options["rightscript"]),["revision"])
          $revision = $merged_options["rightscript"]["revision"]
        end
        $revisions, @script_to_run = concurrent map @script in @scripts return $available_revision,@script_with_revision do
          $available_revision = @script.revision
          if $available_revision == $revision
            @script_with_revision = @script
          else
            # TODO: This won't be necessary when RCL assigns the proper empty return
            # collection type.
            @script_with_revision = rs.right_scripts.empty()
          end
        end
        if empty?(@script_to_run)
          raise "run_executable() found the script named "+$merged_options["rightscript"]["name"]+" but revision "+$revision+" was not found.  Available revisions are "+to_s($revisions)
        end
        $run_executable_params_hash["right_script_href"] = @script_to_run.href
      end
    else
      raise "run_executable() requires either 'name' or 'href' when executing a RightScript.  Found neither."
    end
  elsif contains?(keys($merged_options),["recipe"])
    $run_executable_params_hash["recipe_name"] = $merged_options["recipe"]
  else
    raise "run_executable() requires either 'rightscript' or 'recipe' in the $options.  Found neither."
  end

  @tasks = @instances.run_executable($run_executable_params_hash)

  if $merged_options["wait_for_completion"]
    sleep_until(@tasks.summary =~ "^(completed|failed)")
    if @tasks.summary =~ "failed"
      raise "Failed to run " + to_s($run_executable_params_hash)
    end
  end
end

# Does some validation and gets the server template for an instance
#
# @param @instance [InstanceResourceCollection] the instance for which to get
#   the server template
#
# @return [ServerTemplateReourceCollection] The server template for the @instance
#
# @raise a string error message if the @instance parameter is not an instance
#   collection
# @raise a string error message if the @instance does not have a server_template
#   rel
define instance_get_server_template(@instance) return @server_template do
  $type = to_s(@instance)
  if !($type =~ "instance")
    raise "instance_get_server_template requires @instance to be of type rs.instances.  Got "+$type+" instead"
  end
  $stref = select(@instance.links, {"rel": "server_template"})
  if size($stref) == 0
    raise "instance_get_server_template can't get the ServerTemplate of an instance which does not have a server_template rel."
  end
  @server_template = @instance.server_template()
end

# Return a rightscript href (or null) if it was found in the runnable bindings
# of the supplied ServerTemlate
#
# @param @server_template [ServerTemplateResourceCollection] a collection
#   containing exactly one ServerTemplate to search for the specified RightScript
# @param $name [String] the string name of the RightScript to return
# @param $options [Hash] a hash of options where the possible keys are;
#   * runlist [String] one of (boot|operational|decommission).  When supplied
#     the search will be restricted to the supplied runlist, otherwise all
#     runnable bindings will be evaulated, and the first result will be returned
#
# @return $href [String] the href of the first RightScript found (or null)
#
# @raise a string error message if the @server_template parameter contains more
#   than one (1) ServerTemplate
define server_template_get_rightscript_from_runnable_bindings(@server_template, $name, $options) return $href do
  if size(@server_template) != 1
    raise "server_template_get_rightscript_from_runnable_bindings() expects exactly one ServerTemplate in the @server_template parameter.  Got "+size(@server_template)
  end
  $href = null
  $select_hash = {"right_script": {"name": $name}}
  if contains?(keys($options),["runlist"])
    $select_hash["sequence"] = $options["runlist"]
  end
  @right_scripts = select(@server_template.runnable_bindings(), $select_hash)
  if size(@right_scripts) > 0
    $href = @right_scripts.right_script().href
  end
end



