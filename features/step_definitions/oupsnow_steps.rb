When /^I select "([^\"]*)" from "member_function" of "([^\"]*)" from "([^\"]*)" project$/ do |value, user_name, project_name|
  field = "member_function[#{Project.first({:name => project_name}).project_members.detect{ |pm|
    pm.user_name == user_name
  }.id}]"
  select(value, :from => field)
end

When /^I submit "(.*)"$/ do |form_id|
  submit_form(form_id)
end

