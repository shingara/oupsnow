
Given /^I am not authenticated$/ do
  # yay!
end


Given /^I have one user "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
    User.gen!(:login => login,
             :password => password,
             :password_confirmation => password)
    User.count.should == 1
end

Then /^the login request should success$/ do
  @response.status.should == 200
end
