Then /^I should see "(.*)"$/ do |text|
  webrat_session.response.body.to_s.should =~ /#{text}/m
end

Then /^I should not see "(.*)"$/ do |text|
  webrat_session.response.body.to_s.should_not =~ /#{text}/m
end

Then /^I should see an? (\w+) message$/ do |message_type|
  webrat_session.response.should have_xpath("//*[@class='#{message_type}']")
end

Then /^the (.*) ?request should fail/ do |_|
  webrat_session.response.should_not be_successful
end

Given /^I have a project "([^\"]*)"$/ do |name|
  lambda do
    Project.gen!(:name => name)
  end.should change(Project, :count)
end

Then /^"([^\"]*)" "([^\"]*)" "([^\"]*)" doesn't exist$/ do |klass, attribute, value|
    Object.const_get(klass).send(:first, {attribute.to_sym => value}).should be_nil
end
