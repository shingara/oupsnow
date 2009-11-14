
Given /^I am not authenticated$/ do
  # yay!
end


Given /^I have one\s+user "([^\"]*)" with password "([^\"]*)"$/ do |email, password|
  User.make(:admin) unless User.first(:conditions => {:global_admin => true})
  User.make(:email => email,
            :password => password,
            :password_confirmation => password)
end

Given /^I have one admin user "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  User.make(:admin, :login => login,
            :password => password,
            :password_confirmation => password)
end

Given /^"([^\"]*)" is project admin of "([^\"]*)" project$/ do |email, project_name|
  user = User.first({:email => email})
  project = Project.first({:name => project_name})
  function = Function.first({:project_admin => true}) || Function.make(:admin)
  project.project_members << ProjectMember.new(:user => user, :function => function)
  project.save!
  user.should be_admin(project)
end

Then /^the request should be success$/ do
  @response.code.should == "200"
end

When /^logged with "([^\"]*)" with password "([^\"]*)"$/ do |email, password|
  When %{I go to login}
  And %{I fill in "user_email" with "#{email}"}
  And %{I fill in "user_password" with "#{password}"}
  And %{I press "Log In"}
  Then %{the request should be success}
  And %{I should see an success message}
end
