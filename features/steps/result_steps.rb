Then /^I should see "(.*)"$/ do |text|
  webrat_session.response.body.to_s.should =~ /#{text}/m
end

Then /^I should not see "([^\"]*)"$/ do |text|
  webrat_session.response.body.to_s.should_not =~ /#{text}/m
end

Then /^I should see an? (\w+) message$/ do |message_type|
  webrat_session.response.should have_xpath("//*[@class='#{message_type}']")
end

Then /^I should see id (\w+)$/ do |id_txt|
  webrat_session.response.should have_xpath("//*[@id='#{id_txt}']")
end

Then /^I should see (\d+) "(\w+)" tag with content "([^\"]*)"$/ do |num, tag_name, content|
  webrat_session.response.should have_selector(tag_name, :content => content, :count => num.to_i)
end

Then /^I should not see "(\w+)" tag with content "(\w+)"$/ do |tag_name, content|
  webrat_session.response.should_not have_selector(tag_name, :content => content)
end

Then /^the (.*) ?request should fail/ do |_|
  webrat_session.response.should_not be_successful
end

Given /^I have a project "([^\"]*)"$/ do |name|
  unless Project.first(:name => name)
    lambda do
      Project.gen!(:name => name)
    end.should change(Project, :count)
  end
end

Given /^I have a project "([^\"]*)" without members$/ do |name|
  Given %{I have a project "#{name}"}
  Project.first(:name => name).members.each {|m| m.destroy}
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

Given /^(\d+) tickets with state "([^\"]*)" on project "(.*)"$/ do |num, state_name, project_name|
  state = State.first(:name => state_name)
  state = State.gen!(:name => state_name) unless state
  project = Project.first(:name => project_name)
  project = Project.gen(:name => project_name) unless project
  num.to_i.times {
     Ticket.gen(:state_id => state.id,
               :project_id => project.id)
  }
end

Given /^(\d+) tickets with state "([^\"]*)" and tag "([^\"]*)" on project "([^\"]*)"$/ do |num, state_name, tag_name, project_name|
  state = State.first(:name => state_name)
  state = State.gen!(:name => state_name) unless state
  project = Project.first(:name => project_name)
  project = Project.gen(:name => project_name) unless project
  num.to_i.times {
    Ticket.gen(:state_id => state.id,
               :project_id => project.id,
               :tag_list => tag_name)
  }
end

def user_with_name(name)
  user = User.first(:login => name)
  user = User.gen(:login => name) unless user
  user
end

def project_with_name(name)
  project = Project.first(:name => name)
  project = Project.gen(:name => name) unless project
  project
end

def function_with_name(name)
  function = Function.first(:name => name)
  function = Function.gen(:name => name,
                         :project_admin => (name == 'admin')) unless function
  function
end

Given /^I have user "([^\"]*)" with function "([^\"]*)" on project "([^\"]*)"$/ do |user_name, function_name, project_name|
  user = user_with_name(user_name)
  project = project_with_name(project_name)
  function = function_with_name(function_name)
  member = project.members.create(:user => user, :function => function)
end

Given /^I have user "([^\"]*)" with function "([^\"]*)" on project "([^\"]*)" and no other user$/ do |user_name, function_name, project_name|
  Given %{I have user "#{user_name}" with function "#{function_name}" on project "#{project_name}"}

  user = user_with_name(user_name)
  project = project_with_name(project_name)
  project.members.all(:user_id.not => user.id).each { |m| m.destroy }
end

Then /^the member "([^\"]*)" has function "([^\"]*)" in project "([^\"]*)"$/ do |user_name, function_name, project_name|
  User.first(:login => user_name).members.first(:project_id => Project.first(:name => project_name).id).function.name.should == function_name
end

When /transaction commit/ do
  transaction = DataMapper.repository(:default).adapter.pop_transaction
  transaction.commit
end

Given /^I have state "([^\"]*)"$/ do |name|
    State.gen(:name => name) if State.first(:name => name).nil?
end

Then /^I have (\d+) ticket on project "([^\"]+)"$/ do |num_ticket, project_name|
  Project.all(:name => project_name).count.should == 1
  Project.first(:name => project_name).tickets.count.should == num_ticket.to_i
end

Then /^I should see an? ([^\"]*) message with "([^\"]*)"$/ do |class_name, content|
  Then %{I should see a #{class_name} message}
  webrat_session.response.should have_selector("div", :class => class_name, :content => content)
end

Then /^I should see an? ([^\"]*) message with child "([^\"]*)"$/ do |class_name, content|
  Then %{I should see a #{class_name} message}
  webrat_session.response.should have_selector("fieldset", :class => class_name) do |n|
    n.should have_selector("p", :content => content)
  end
end

Given /^I create (\d+) ticket on project "([^\"]*)"$/ do |number, project_name|
  project = Project.first(:name => project_name)
  number.to_i.times do
    Ticket.gen(:project_id => project.id, :num => project.new_num_ticket)
  end
end
