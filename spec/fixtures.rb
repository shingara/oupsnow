include DataMapper::Sweatshop::Unique

User.fixture {{
  :login => /\w+/.gen,
  :email => "#{/\w+/.gen}.#{/\w+/.gen}@gmail.com",
  :password => "tintinpouet",
  :password_confirmation => 'tintinpouet',
  :global_admin => false,
}}

Function.fixture {{
  :name => /\w+/.gen,
  :project_admin => false,
}}

Function.fixture(:admin) {{
  :name => 'Admin',
  :project_admin => true,
}}

admin = User.gen(:login => 'admin', :global_admin => true)
admin_function = Function.gen(:admin)

Project.fixture {{
  :name => /\w+/.gen,
  :description => (0..3).of { /[:paragraph:]/.generate }.join("\n"),
  :members => [:function => Function.admin, :user => User.first(:login => 'admin')]
}}

Member.fixture {{
  :user_id => User.first.id,
  :project_id => Project.first.id,
  :function_id => Function.first.id,
}}
Member.gen

Ticket.fixture {{
  :title => /\w+/.gen,
  :description => (0..3).of { /[:paragraph:]/.generate }.join("\n"),
  :tag_list => (1..2).of { /\w+/.generate }.join(','),
}}

State.fixture {{
  :name => /\w+/.gen,
}}

Priority.fixture {{
  :name => /\w+/.gen,
}}


State.gen(:name => 'new')

