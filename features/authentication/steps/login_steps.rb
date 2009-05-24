
Given /^I am not authenticated$/ do
  # yay!
end


Given /^I have one user "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
    User.gen!(:login => login,
             :password => password,
             :password_confirmation => password)
end

Given /^I have one admin user "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
    User.gen!(:admin, :login => login,
             :password => password,
             :password_confirmation => password)
end

Given /^"([^\"]*)" is project admin of "([^\"]*)" project$/ do |login, project_name|
  user = User.first(:login => login)
  project = Project.first(:name => project_name)
  member = Member.new(:user_id => user.id)
  function = Function.first(:name => 'Admin') ? Function.first(:name => 'Admin') : Function.gen!(:admin)
  member.function_id = function.id
  member.project_id = project.id
  member.save!
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
