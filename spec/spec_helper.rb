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

class Unauthorized < Exception

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
              :email => 'cyril.mougel@gmail.com',
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
  user
end


def login_anonymous
  request.env['warden'] = Warden::Proxy.new(request.env, {:default_strategies => [:rememberable, :authenticable],:silence_missing_strategies => true})
  Rack::Request.any_instance.stubs(:request_uri).returns('/projects/new')
end

def login_request(user = nil)
  create_default_user
  user = User.first(:conditions => {:login => 'shingara'}) unless user

  proxy = Warden::Proxy.new(request.env, {:default_strategies => [:rememberable, :authenticable], :silence_missing_strategies => true})
  proxy.set_user(user, :store => true, :scope => :user)
  request.env['warden'] = proxy

  # if user is admin of this project. He becomes not admin
  Project.all(:conditions => {'project_members.user_id' => user.id,
              'project_members.project_admin' => true}).each do |p|
    p.project_members.each do |m|
      if m.user_id == user.id && m.project_admin
        m.function = (Function.not_admin || Function.make)
      end
    end
    # if no member admin add a user member
    p.valid?
    unless p.have_one_admin
      p.project_members << ProjectMember.new(:user => User.make,
                                             :function => Function.admin)
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
  login_request(user)
end

def need_developper_function
  unless Function.first(:name => 'Developper')
    Function.gen(:name => 'Developper')
  end
end
