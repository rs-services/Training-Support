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
# Automates cleaning up training account.
# Lightly tested so ymmv
#

name "INSTRUCTOR SUPPORT - Training Account Clean Up"
rs_ca_ver 20161221
short_description 'Cleans up the training account.'

import "training/support/user_management"

###############
## Operations #
###############

operation "launch" do
  description "Clean up the account"
  definition "clean_account"
end

define clean_account() do
  
  # Terminate all running or failed cloud apps in the account
  @executions = rs_ss.executions.get()
  sub task_label: "Terminating running or failed cloud apps" do
    $wake_condition = "/^(terminated|failed)$/"
    foreach @execution in @executions do
      if (@execution.status == "running") || (@execution.status == "failed")
        @execution.terminate()
        sleep_until(@execution.status[] =~ $wake_condition)
      end
    end
  end
  
  # Delete all terminated cloud apps in the account
  sub task_label: "Deleting terminated cloud apps" do
    foreach @execution in @executions do
      if (@execution.status == "terminated")
        @execution.delete()
      end
    end
  end
  
  # Delete all CATs that are not the training CAT
  # Not a perfect solution but as long as students keep "Hello" in their CAT name it'll work.
  # Otherwise, as instructors notice the rogue CATs in Designer, then can delete them easily enough.
  sub task_label: "Deleting CATs" do
    $training_cat_name = "TRAINING - Hello World CAT"
    @cats = rs_ss.templates.get()
    $$deleted_cats = []
    foreach @cat in @cats do
      if @cat.name =~ "Hello"
        if @cat.name != $training_cat_name
          @cat.delete()
        end
      end
    end

end
  
  # Disable all the server arrays in the account and terminate the instances
  sub task_label: "Terminating server arrays" do
    @server_arrays = rs_cm.server_arrays.get()
    @server_arrays.update(server_array: { state: "disabled"})
    
    sub on_error: skip do
      @array_instances = @server_arrays.current_instances()
    delete(@array_instances)
    end
     
    # Delete the server arrays
    @server_arrays.destroy()
  end
  
  # Terminate all servers and instances in the account
  sub task_label: "Terminating servers and instances" do
    @servers = rs_cm.servers.get()
    delete(@servers)
    
    @instances = rs_cm.instances.get()
    delete(@instances)
  end
  
  # Delete all Deployments
  sub task_label: "Deleting deployments" do
    @deployments = rs_cm.deployments.get()
    foreach @deployment in @deployments do
      if downcase(@deployment.name) != "default"
        @deployment.destroy()
      end
    end
  end
  
  # Delete all ServerTemplates that are not used for the training CAT
  sub task_label: "Deleting server templates" do
    $training_st_name = "Training Hello World Web Server"
    @sts = rs_cm.server_templates.get(filter: ["revision==0"])
    foreach @st in @sts do
      if @st.name != $training_st_name
        sub on_error:skip do
          @st.destroy()
        end
      end
    end
  end
  
  # Delete all RightScripts that are not used for training CAT
  sub task_label: "Deleting rightscripts" do
    $training_script_names = [ "training_helloworld_install_rightscript", "training_helloworld_update_rightscript" ]
    @scripts = rs_cm.right_scripts.get()
    foreach @script in @scripts do
      if logic_not(contains?($training_script_names, [@script.name]))
        if @script.revision == 0
          sub on_error: skip do 
            @script.destroy()
          end
        end
      end
    end
  end
  
  # Delete all ssh keys security groups
  sub task_label: "Deleting security groups" do
    $clouds = ["/api/clouds/1","/api/clouds/3", "/api/clouds/6"]
    foreach $cloud in $clouds do
      @cloud = rs_cm.get(href: $cloud)
      @cloud.ssh_keys().destroy()
      @sgs = @cloud.security_groups()
      foreach @sg in @sgs do
        if downcase(@sg.name) != "default"
          @sg.destroy()
        end
      end
    end
  end
  
  # Reset the training user password
  sub task_label: "Resetting training student password" do
    $new_password = "a"+uuid()
    call user_management.manage_training_account($new_password)
  end
end





