name 'TRAINING - Common Mappings'
rs_ca_ver 20161221
short_description 'Common mappings used for CAT training.'

package "common/cat_training_mappings"

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


