require 'randexp'

Factory.define :user do |u|
  u.login { /\w+/.gen }
  u.email { "#{/\w+/.gen}.#{/\w+/.gen}@gmail.com"}
  u.password  { "tintinpouet"}
  u.password_confirmation { 'tintinpouet' }
  u.global_admin { false }
end

Factory.define(:admin, :parent => :user) do |u|
  u.login { 'admin' }
  u.global_admin { true }
end

Factory.define(:function) do |f|
  f.name { /\w+/.gen }
  f.project_admin { false }
end

Factory.define(:admin_function, :class => 'Function') do |f|
  f.name { 'Admin' }
  f.project_admin { true }
end

# The project generate by blueprint is invalid
# if you want a valid factory use make_project helper method
Factory.define(:project) do |f|
  f.name { /\w+/.gen }
  f.description { (0..3).of { /[:paragraph:]/.generate }.join("\n") }
end


Factory.define(:project_member) do |m|
  m.user { Factory(:user) }
  m.function { Factory(:function) }
end

Factory.define(:admin_project_member, :class => 'ProjectMember',:default_strategy => :build) do |a|
  a.user_id { (User.first || Factory(:admin)).id }
  a.function_id { (Function.admin || Factory(:admin_function)).id }
end

##
# generate a valid project
# if you don't use this method, all validation failed
def make_project(params={})
  project_members = params[:project_members]
  pr = Factory.build(:project, params)
  pr.project_members = project_members || [Factory(:admin_project_member)]
  if pr.project_members.first
    pr.user_creator = pr.project_members.first.user
  end
  pr.save
  pr
end

def make_ticket_update(ticket, params={}, user=ticket.project.project_members.first.user)
  ticket.generate_update(
    ({:tag_list => ticket.tag_list,
     :state_id => ticket.state_id.to_s,
     :milestone_id => ticket.milestone_id.to_s,
     :user_assigned_id => ticket.user_assigned_id.to_s,
    :description => (1..3).of { /[:paragraph:]/.generate }.join("\n")}.merge(params)),user)
  ticket.ticket_updates.last
end


def make_word
  /\w+/.gen
end

def make_tag_list
  (1..6).of { /\w+/.gen }.join(",")
end

Factory.define(:ticket) do |t|
  t.title { make_word }
  t.description { (0..3).of { /[:paragraph:]/.generate }.join("\n") }
  t.tag_list { 'foo,bar' }
  t.project { make_project }
  t.tuser_creator { self.project.project_members.first.user }
  t.state { State.first(:conditions => {:name => 'new'}) || Factory(:state, :name => 'new') }
  t.milestone { Milestone.first(:project_id => self.project.id) || Factory(:milestone, :project => self.project) }
  t.user_assigned_id {nil}
end

def make_ticket(opts={})
  unless opts[:tag_list]
    opts = opts.merge(:tag_list => make_tag_list)
  end
  ticket = Factory(:ticket, opts)
  ticket.write_create_event
  ticket
end

Factory.define(:milestone) do |m|
  m.name { /\w+/.gen }
  m.description { (0..3).of { /[:paragraph:]/.generate }.join("\n") }
  m.project { make_project }
end

def need_a_milestone(project=nil)
  make_project unless Project.first
  pr = project || Project.first
  Factory(:milestone, :project => pr)
end

Factory.define(:state) do |s|
  s.name { /\w+/.gen }
end

Factory.define(:event) do |e|
  e.eventable { make_project }
  e.user { User.first || Factory(:admin) }
  e.event_type { :created }
  e.project { Project.first }
end

Factory.define(:priority) do |pr|
  pr.name { /\w+/.gen }
end
