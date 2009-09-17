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
  unless Project.first(:conditions => {:name => name})
    lambda do
      make_project(:name => name)
    end.should change(Project, :count)
  end
end

Given /^I have a project "([^\"]*)" without members$/ do |name|
  Given %{I have a project "#{name}"}
  pm = Project.first(:conditions => {:name => name})
  pm.project_members = []
  pm.save
end

Then /^"([^\"]*)" "([^\"]*)" "([^\"]*)" doesn't exist$/ do |klass, attribute, value|
    Object.const_get(klass).send(:first, {attribute.to_sym => value}).should be_nil
end

Given /^"([^\"]*)" not admin on project "([^\"]*)"$/ do |login, project_name|
    project = Project.first(:conditions => {:name => project_name})
    project.project_members.each {|pm|
      if pm.user.login == login
        pm.function = Function.not_admin
      end
    }
    project.save
end

Given /^"([^\"]*)"\s+admin on project "([^\"]*)"$/ do |login, project_name|
    project = Project.first(:conditions => {:name => project_name})
    project.project_members.each {|pm|
      if pm.user.login == login
        pm.function = Function.admin
      end
    }
    project.save
end

Given /^(\d+) tickets with state "([^\"]*)" on project "(.*)"$/ do |num, state_name, project_name|
  state = State.first(:conditions => {:name => state_name}) || State.make(:name => state_name)
  project = Project.first(:name => project_name) || Project.make(:conditions => {:name => project_name})
  num.to_i.times {
     Ticket.make(:state => state,
               :project => project)
  }
end

Given /^(\d+) tickets with state "([^\"]*)" and tag "([^\"]*)" on project "([^\"]*)"$/ do |num, state_name, tag_name, project_name|
  state = State.first(:conditions => {:name => state_name}) || State.make(:name => state_name)
  project = Project.first(:conditions => {:name => project_name}) || Project.make(:name => project_name)
  num.to_i.times {
    Ticket.make(:state => state,
               :project => project,
               :tag_list => tag_name)
  }
end

def user_with_name(name)
  User.first(:conditions => {:login => name}) ||  User.make(:login => name)
end

def project_with_name(name)
  Project.first(:conditions => {:name => name}) || Project.gen(:name => name)
end

def function_with_name(name)
  Function.first(:conditions => {:name => name}) || Function.make(:name => name,
                         :project_admin => (name == 'admin'))
end

Given /^I have user "([^\"]*)" with function "([^\"]*)" on project "([^\"]*)"$/ do |user_name, function_name, project_name|
  user = user_with_name(user_name)
  project = project_with_name(project_name)
  function = function_with_name(function_name)
  project.project_members << ProjectMember.new(:user => user, :function => function)
  project.save
end

Given /^I have user "([^\"]*)" with function "([^\"]*)" on project "([^\"]*)" and no other user$/ do |user_name, function_name, project_name|
  Given %{I have user "#{user_name}" with function "#{function_name}" on project "#{project_name}"}

  user = user_with_name(user_name)
  project = project_with_name(project_name)
  project.project_members.delete_if{ |pm| pm.user_id != user.id }
  project.save!
end

Then /^the member "([^\"]*)" has function "([^\"]*)" in project "([^\"]*)"$/ do |user_name, function_name, project_name|
  u = User.first(:conditions => {:login => user_name})
  pr = Project.first(:conditions => {:name => project_name})
  pr.project_members.should_not be_empty
  pr.project_members.find{|pm| pm.user_id = u.id}
end

Given /^I have state "([^\"]*)"$/ do |name|
    State.make(:name => name) unless State.first(:conditions => {:name => name})
end

Then /^I have (\d+) ticket on project "([^\"]+)"$/ do |num_ticket, project_name|
  Project.count(:name => project_name).should == 1
  Project.first(:conditions => {:name => project_name}).tickets.count.should == num_ticket.to_i
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
  project = Project.first(:conditions => {:name => project_name})
  number.to_i.times do
    Ticket.make(:project => project)
  end
end
