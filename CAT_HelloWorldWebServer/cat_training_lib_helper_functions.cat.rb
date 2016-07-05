name 'TRAINING - Helper Functions'
rs_ca_ver 20160622
short_description 'Common set of helper functions used for CAT training.'

package "common/cat_training_helper_functions"

define run_script(@server, $script_name, $inputs_hash) do
  
  task_label("In run_script")
    
  @script = rs_cm.right_scripts.get(filter: join(["name==",$script_name]))
  $right_script_href=@script.href

  @task = @server.current_instance().run_executable(right_script_href: $right_script_href, inputs: $inputs_hash)
  
  if equals?(@tasks.summary, "/^failed/")
    raise "Failed to run " + $right_script_href + "."
  end
end