# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'

# Uncomment the next line to use webrat's matchers
#require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  config.before(:each) do
    Project.collection.remove
    Ticket.collection.remove
    Function.collection.remove
    User.collection.remove
    State.collection.remove
    Event.collection.remove
  end
end

def list_mock_project
  [mock(:project, 
        :name => 'oupsnow',
        :description => nil ), 
        mock(:project, 
             :name => 'pictrails',
             :description => 'a gallery in Rails')]
end

require File.dirname(__FILE__) + '/blueprints.rb'

def logout
  @request.session = {}
end

def delete_default_member_from_project(project)
  project.project_members.each do |pm|
    if pm.user_id == User.first(:conditions => {:login => 'shingara'})
      project.project_members.delete(pm)
    end
  end
  project.save
end

def need_a_milestone
  make_project unless Project.first
  pr = Project.first
  Milestone.make(:project => pr) if pr.milestones.empty?
end

def create_default_data
  create_default_user
  need_a_milestone
end

def create_default_user
  create_default_admin
  unless User.first(:conditions => {:login => 'shingara'})
    User.make(:login => 'shingara',
              :password => 'tintinpouet',
              :password_confirmation => 'tintinpouet')
  end
end

def create_default_admin
  user = User.first(:conditions => {:login => 'admin'}) || User.make(:admin)
  Function.make(:admin) unless Function.admin
  make_project unless Project.first
  State.make(:name => 'new') unless State.first(:conditions => {:name => 'new'})
  State.make(:name => 'check') unless State.first(:conditions => {:name => 'check'})
  unless Project.first(:conditions => {'project_members.project_admin' => true})
    pr = Project.first
    pr.project_members << make_project_member
    pr.save
  end

  if Project.first.tickets.empty?
    create_ticket(:project => Project.first,
                  :user_creator => User.first)
  end

  if Ticket.first.ticket_updates.empty?
    t = Ticket.first
    t.generate_update({:description => 'why not',
                      :state_id => State.first.id,
                      :title => t.title}, User.first)
  end
  user
end

def create_ticket(opts={})
  ticket = Ticket.make(opts)
  ticket.write_create_event
end

def login_request(user = nil)
  create_default_user
  logout
  user = User.first(:conditions => {:login => 'shingara'}) unless user
  @mock_warden = OpenStruct.new
  request.env['warden'] = @mock_warden
  @mock_warden.expects(:authenticate!).with(:scope => :user).returns(user)
  @mock_warden.expects(:user).with(:user).returns(user)
  @request.session["warden.user.user.key"] = [User, user.id]


  # if user is admin of this project. He becomes not admin
  Project.all(:conditions => {'project_members.user_id' => user.id,
              'project_members.project_admin' => true}).each do |p|
    p.project_members.each do |m|
      if m.user_id == u.id && m.project_admin
        m.function = (Function.not_admin || Function.make)
      end
    end
    # if no member admin add a user member
    p.valid?
    unless p.have_one_admin
      p.project_members << ProjectMember.new(:user => User.make,
                                             :function => Function.admin)
      puts p.inspect
    end
    p.save!
              end
  user
end

def function_not_admin
  fna = Function.first(:conditions => {:name => {'$ne' => Function::ADMIN}})
  fna = Function.make unless fna
  fna
end

def login_admin
  user = create_default_admin
  need_a_milestone
  logout
  login_request(user)
end

def need_developper_function
  unless Function.first(:name => 'Developper')
    Function.gen(:name => 'Developper')
  end
end
