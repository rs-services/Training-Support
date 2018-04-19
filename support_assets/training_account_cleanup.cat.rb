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

name "INSTRUCTOR SUPPORT - Training Account Clean Up"
rs_ca_ver 20161221
short_description 'Cleans up the training account.'



###############
## Operations #
###############

operation "launch" do
  description "Clean up the account"
  definition "clean_account"
 
end

define clean_account() do
  
  # Terminate all running or failed cloud apps in the account
  
  
  # Delete all terminated cloud apps in the account
  
  # Terminate all servers in the account
  
  # Disable all the server arrays in the account and terminate the instances
  
  # Delete all ServerTemplates that are not used for the training CAT
  
  # Delete all RightScripts that are not used for training CAT
  
  # Delete all ssh keys
  
  # Delete all security groups
  
  # Change the account name to indicate it is now available
  
end

define manage_training_account($param_new_password) return $training_student_login do
  $training_student_login = "UNDEFINED"
  $cred_name = "TRAINING_STUDENT_PASSWORD"
  
  @password_cred = rs_cm.credentials.get(filter: ["name=="+$cred_name])
  if equals?(size(@password_cred), 0) # credential not found
    raise "Credential, "+$cred_name+",  not found. Create credential with the name with the trainingX@rightscale.com user password."
  end
  
  $cred_description = @password_cred.description
  $cred_description_parts = split($cred_description, " ")
  foreach $part in $cred_description_parts do
    if $part =~ "/training.*@rightscale.com/"
      $training_student_login = $part
    end
  end
  
  if $training_student_login == "UNDEFINED" 
    raise "Update the DESCRIPTION for credential, "+$cred_name+", to include the training service accont email address."
  end
  
  # grab the current password
  $training_current_password = cred($cred_name)
    
  # update the user with the new password
  $user_hash = {
    current_email: $training_student_login,
    current_password: $training_current_password,
    new_password: $param_new_password
  }
  # Find the user
  @user = rs_cm.users.get(filter: ["email=="+$training_student_login])
  # Update the user
  @user.update(user: $user_hash)

  # Store the new password in the credential
  @password_cred.update(credential: { value: $param_new_password })
end



