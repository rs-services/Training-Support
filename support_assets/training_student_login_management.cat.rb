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
# Used to manage the "training@rightscale.com" user login that can be provided to students to use
# during training instead of inviting individual students.
#

name "INSTRUCTOR SUPPORT - Training User Management"
rs_ca_ver 20161221
short_description 'Updates password for training student account and updates applicable credential to remember the password.'


parameter "param_new_password" do 
  label "training@rightscale.com new password" 
  type "string" 
  description "New password for training student account." 
  no_echo true
  min_length 8
end



##############
# OUTPUTS    #
##############
output "server_url" do
  label "Training Account Password Credential" 
  description "Where to find the password if forgotten."
  default_value "TRAINING_STUDENT_PASSWORD"
end



###############
## Operations #
###############

operation "launch" do
  description "Manage training account password"
  definition "manage_training_account"
end


define manage_training_account($param_new_password) do
  $training_email = "training@rightscale.com"
  $cred_name = "TRAINING_STUDENT_PASSWORD"
  # grab the current password
  $training_current_password = cred($cred_name)
  
  # update the user with the new password
  $user_hash = {
    current_email: $training_email,
    current_password: $training_current_password,
    new_password: $param_new_password
  }
  # Find the user
  @user = rs_cm.users.get(filter: ["email=="+$training_email])
  # Update the user
  @user.update(user: $user_hash)

  # Store the new password in the credential
  @password_cred = rs_cm.credentials.get(filter: ["name=="+$cred_name])
  @password_cred.update(credential: { value: $param_new_password })
end

