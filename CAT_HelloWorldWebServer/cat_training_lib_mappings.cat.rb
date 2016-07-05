name 'TRAINING - Common Mappings'
rs_ca_ver 20160622
short_description 'Common set of mapping declarations used for CAT training.'

package "common/cat_training_mappings"

##############
# MAPPINGS   #
##############

# Maps the user's selected performance level into a specific instance type.
mapping "map_instance_type" do {
  "AWS" => {
    "low" => "m3.medium",  
    "medium" => "m3.large", 
    "high" => "m3.xlarge", 
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



