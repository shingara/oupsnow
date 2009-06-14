include DataMapper::Sweatshop::Unique

User.fixture {{
  :login => /\w+/.gen,
  :email => "#{/\w+/.gen}.#{/\w+/.gen}@gmail.com",
  :password => "tintinpouet",
  :password_confirmation => 'tintinpouet',
  :global_admin => false,
}}

User.fixture(:admin) {{
  :login => 'admin',
  :email => "#{/\w+/.gen}.#{/\w+/.gen}@gmail.com",
  :password => "tintinpouet",
  :password_confirmation => 'tintinpouet',
  :global_admin => true,
}}

Function.fixture {{
  :name => /\w+/.gen,
  :project_admin => false,
}}

Function.fixture(:admin) {{
  :name => 'Admin',
  :project_admin => true,
}}

Project.fixture {{
  :name => /\w+/.gen,
  :description => (0..3).of { /[:paragraph:]/.generate }.join("\n"),
  :members => [:function_id => (Function.admin ? Function.admin.id : Function.gen(:admin).id), 
    :user_id => (User.first(:login => 'admin') ? User.first(:login => 'admin').id : User.gen(:admin).id)]
}}

Member.fixture {
  user =  User.first(:login.not => 'admin') ? User.first(:login.not => 'admin') : User.gen!
  project =  Project.first ? Project.first : Project.gen!
  not_project_id = []
  while project.has_member?(user)
    not_project_id << project.id
    project =  Project.first(:id.not => not_project_id) ? Project.first(:id.not => not_project_id) : Project.gen!
  end
  {
  :user_id => user.id,
  :project_id => project.id,
  :function_id => (Function.first ? Function.first.id : Function.gen.id),
}
}

Ticket.fixture {{
  :title => /\w+/.gen,
  :description => (0..3).of { /[:paragraph:]/.generate }.join("\n"),
  :tag_list => (1..2).of { /\w+/.generate }.join(','),
  :project_id => (Project.first ? Project.first.id : Project.gen.id),
  :member_create_id => User.first ? User.first.id : User.gen.id,
  :state_id => State.first ? State.first.id : State.gen.id,
}}

State.fixture {{
  :name => /\w+/.gen,
}}

Priority.fixture {{
  :name => /\w+/.gen,
}}

Milestone.fixture {{
  :name => /\w+/.gen,
  :description => (0..3).of { /[:paragraph:]/.generate }.join("\n"),
  :expected_at => Time.now
}}

Event.fixture {{
  :eventable_class => 'Ticket',
  :eventable_id => (Ticket.first ? Ticket.first.id : Ticket.gen.id),
  :event_type => :created,
  :user_id => User.first ? User.first.id : User.gen.id,
  :project_id => (Project.first ? Project.first.id : Project.gen.id)
}}
