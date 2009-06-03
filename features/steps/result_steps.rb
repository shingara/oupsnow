Then /^I should see "(.*)"$/ do |text|
  webrat_session.response.body.to_s.should =~ /#{text}/m
end

Then /^I should not see "([^\"]*)"$/ do |text|
  webrat_session.response.body.to_s.should_not =~ /#{text}/m
end

Then /^I should see an? (\w+) message$/ do |message_type|
  webrat_session.response.should have_xpath("//*[@class='#{message_type}']")
end

Then /^I should see (\d+) "(\w+)" tag with content "(\w+)"$/ do |num, tag_name, content|
  webrat_session.response.should have_selector(tag_name, :content => content, :count => num.to_i)
end

Then /^I should not see "(\w+)" tag with content "(\w+)"$/ do |tag_name, content|
  webrat_session.response.should_not have_selector(tag_name, :content => content)
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

Given /^"([^\"]*)" not admin on project "([^\"]*)"$/ do |login, project_name|
    project = Project.first(:name => project_name)
    member = project.members('user.login' => login)
    if !member.empty? && member.project_admin?
      member.function = Function.not_admin
      member.save
    end
end

Given /^(\d+) tickets with state "(.*)" on project "(.*)"$/ do |num, state_name, project_name|
  state = State.first(:name => state_name)
  state = State.gen!(:name => state_name) unless state
  project = Project.first(:name => project_name)
  project = Project.gen(:name => project_name) unless project
  num.to_i.times {
    Ticket.gen(:state => state,
               :project_id => project.id)
  }
end
