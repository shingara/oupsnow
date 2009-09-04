User.blueprint {
  login { /\w+/.gen }
  email { "#{/\w+/.gen}.#{/\w+/.gen}@gmail.com"}
  password  { "tintinpouet"}
  password_confirmation { 'tintinpouet' }
  global_admin { false }
}

User.blueprint(:admin) do
  login { 'admin' }
  email { "#{/\w+/.gen}.#{/\w+/.gen}@gmail.com" }
  password { "tintinpouet" }
  password_confirmation { 'tintinpouet' }
  global_admin { true }
end

Function.blueprint(:admin) do
  name { /\w+/.gen }
  project_admin { false }
end

Function.blueprint do
  name { 'Admin' }
  project_admin { true }
end

# The project generate by blueprint is invalid
# if you want a valid factory use make_project helper method
Project.blueprint do
  name { /\w+/.gen }
  description { (0..3).of { /[:paragraph:]/.generate }.join("\n") }
end

def make_project_member(user=nil)
  unless user
    user = User.first ? User.first : User.make(:admin)
  end
  ProjectMember.new(:user_name => user.login,
                    :user => user,
                    :project_admin => true)
end

##
# generate a valid project
# if you don't use this method, all validation failed
def make_project(params={})
  project_members = params[:project_members]
  pr = Project.make_unsaved(params)
  if project_members
    pr.project_members = project_members
  else
    pr.project_members = [make_project_member]
  end
  if pr.project_members.first
    pr.user_creator = pr.project_members.first.user
  end
  pr.save
  pr
end

Ticket.blueprint do
  title { /\w+/.gen }
  description { (0..3).of { /[:paragraph:]/.generate }.join("\n") }
  project { make_project }
end

Milestone.blueprint do
  name { /\w+/.gen }
  description { (0..3).of { /[:paragraph:]/.generate }.join("\n") }
end

State.blueprint do
  name { /\w+/.gen }
end

Event.blueprint do
  eventable { make_project }
  user { User.first ? User.first : User.make(:admin) }
  event_type { :created }
  project { Project.first }
end
