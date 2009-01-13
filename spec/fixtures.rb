include DataMapper::Sweatshop::Unique

User.fixture {{
  :login => /\w+/.gen,
  :email => "#{/\w+/.gen}.#{/\w+/.gen}@gmail.com",
  :password => "tintinpouet",
  :password_confirmation => 'tintinpouet'
}}

Function.fixture {{
  :name => /\w+/.gen
}}

Function.fixture(:admin) {{
  :name => 'Admin'
}}

admin = User.gen(:login => 'admin')
admin_function = Function.gen(:admin)

Project.fixture {{
  :name => /\w+/.gen,
  :description => (0..3).of { /[:paragraph:]/.generate }.join("\n"),
  :members => [:function => Function.first(:name => 'Admin'), :user => User.first(:login => 'admin')]
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


State.gen(:name => 'new')

