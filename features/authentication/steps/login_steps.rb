
Given /^I am not authenticated$/ do
  # yay!
end


Given /^I have one user "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  User.make(:admin) unless User.first(:conditions => {:global_admin => true})
  User.make(:login => login,
            :password => password,
            :password_confirmation => password)
end

Given /^I have one admin user "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  User.make(:admin, :login => login,
            :password => password,
            :password_confirmation => password)
end

Given /^"([^\"]*)" is project admin of "([^\"]*)" project$/ do |login, project_name|
  user = User.first(:conditions => {:login => login})
  project = Project.first(:condtions => {:name => project_name})
  function = Function.first(:conditions => {:project_admin => true}) ? Function.first(:conditions => {:project_admin => true}) : Function.make(:admin)
  project.project_members << ProjectMember.new(:user => user, :function => function)
  project.save!
  user.should be_admin(project)
end

Then /^the request should be success$/ do
  @response.status.should == 200
end

When /^logged with "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  When %{I go to /login}
  And %{I fill in "login" with "#{login}"}
  And %{I fill in "password" with "#{password}"}
  And %{I press "Log In"}
  Then %{the request should be success}
  And %{I should see an notice message}
end
