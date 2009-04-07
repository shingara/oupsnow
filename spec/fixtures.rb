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
  :members => [:function => (Function.admin ? Function.admin : Function.gen(:admin)), 
    :user => (User.first(:login => 'admin') ? User.first(:login => 'admin') : User.gen(:admin))]
}}

Member.fixture {{
  :user_id => User.first ? User.gen.id : User.first.id,
  :project_id => (Project.first ? Project.gen.id : Project.first.id),
  :function_id => (Function.first ? Function.gen.id : Function.first.id),
}}

Ticket.fixture {{
  :title => /\w+/.gen,
  :description => (0..3).of { /[:paragraph:]/.generate }.join("\n"),
  :tag_list => (1..2).of { /\w+/.generate }.join(','),
  :project_id => (Project.first ? Project.gen.id : Project.first.id),
  :member_create_id => User.first ? User.gen.id : User.first.id,
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
  :eventable_id => (Ticket.first ? Ticket.gen.id : Ticket.first.id),
  :event_type => :created,
  :user_id => User.first ? User.gen.id : User.first.id,
  :project_id => (Project.first ? Project.gen.id : Project.first.id)
}}
