# Commonly used webrat steps
# http://github.com/brynary/webrat

When /^I go to (.*)$/ do |path|
  @response = visit path
end

When /^I press "(.*)"$/ do |button|
  @response = click_button(button)
end

When /^I follow "(.*)"$/ do |link|
  @response = click_link(link)
end

When /^I fill in "(.*)" with "(.*)"$/ do |field, value|
  @response = fill_in(field, :with => value) 
end

When /^I select "(.*)" from "(.*)"$/ do |value, field|
  @response = select(value, :from => field) 
end

When /^I check "(.*)"$/ do |field|
  @response = check(field) 
end

When /^I uncheck "(.*)"$/ do |field|
  @response = uncheck(field) 
end

When /^I choose "(.*)"$/ do |field|
  @response = choose(field)
end

When /^I attach the file at "(.*)" to "(.*)" $/ do |path, field|
  @response = attach_file(field, path)
end
