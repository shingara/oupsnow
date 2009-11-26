
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

Function.blueprint do
  name { /\w+/.gen }
  project_admin { false }
end

Function.blueprint(:admin) do
  name { 'Admin' }
  project_admin { true }
end

# The project generate by blueprint is invalid
# if you want a valid factory use make_project helper method
Project.blueprint do
  name { /\w+/.gen }
  description { (0..3).of { /[:paragraph:]/.generate }.join("\n") }
end


ProjectMember.blueprint do
  user { User.make }
  function { Function.make }
end

ProjectMember.blueprint(:admin) do
  user { User.first || User.make(:admin) }
  function { Function.admin || Function.make(:admin) }
end

##
# generate a valid project
# if you don't use this method, all validation failed
def make_project(params={})
  project_members = params[:project_members]
  pr = Project.make_unsaved(params)
  pr.project_members = project_members || [ProjectMember.make(:admin)]
  if pr.project_members.first
    pr.user_creator = pr.project_members.first.user
  end
  pr.save
  pr
end

def make_ticket_update(ticket, params={}, user=User.make)
  ticket.generate_update(Ticket.make_unsaved({:description => (1..3).of { /[:paragraph:]/.generate }.join("\n")}.merge(params)),user)
  ticket.ticket_updates.last
end


def make_word
  /\w+/.gen
end

def make_tag_list
  (1..6).of { /\w+/.gen }.join(",")
end

Ticket.blueprint do
  title { make_word }
  description { (0..3).of { /[:paragraph:]/.generate }.join("\n") }
  tag_list { 'foo,bar' }
  project { make_project }
  user_creator { self.project.project_members.first.user }
  state { State.first(:conditions => {:name => 'new'}) || State.make(:name => 'new') }
  milestone { Milestone.first(:project_id => self.project.id) || Milestone.make(:project => self.project) }
  user_assigned_id {nil}
end

def make_ticket(opts={})
  unless opts[:tag_list]
    opts = opts.merge(:tag_list => make_tag_list)
  end
  ticket = Ticket.make(opts)
  ticket.write_create_event
  ticket
end

Milestone.blueprint do
  name { /\w+/.gen }
  description { (0..3).of { /[:paragraph:]/.generate }.join("\n") }
  project { make_project }
end

def need_a_milestone(project=nil)
  make_project unless Project.first
  pr = project || Project.first
  Milestone.make(:project => pr)
end

State.blueprint do
  name { /\w+/.gen }
end

Event.blueprint do
  eventable { make_project }
  user { User.first || User.make(:admin) }
  event_type { :created }
  project { Project.first }
end

Priority.blueprint do
  name { /\w+/.gen }
end
