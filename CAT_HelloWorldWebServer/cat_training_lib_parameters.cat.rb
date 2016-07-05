
name 'TRAINING - Common Parameters'
rs_ca_ver 20160622
short_description 'Common set of parameter declarations used for CAT training.'

package "common/cat_training_parameters"

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

# Project ID for the application
parameter "param_projectid" do
  category "Project Options"
  label "Project ID"
  type "string"
  description "Project Id for the application."
  min_length 8
  max_length 24
  allowed_pattern "^[0-9a-zA-Z]+$"
  constraint_description "Must be alphanumeric string of 8 to 24 characters."
  default "Project1234"  
end



