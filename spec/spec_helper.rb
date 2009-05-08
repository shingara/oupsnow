require "rubygems"

# Add the local gems dir if found within the app root; any dependencies loaded
# hereafter will try to load from the local gems before loading system gems.
if (local_gem_dir = File.join(File.dirname(__FILE__), '..', 'gems')) && $BUNDLE.nil?
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(local_gem_dir)
end

require "merb-core"
require "spec" # Satisfies Autotest and anyone else not using the Rake tasks

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')
DataMapper.auto_migrate! if ENV['MIGRATION']

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)

  config.after(:each) do
    repository(:default) do
      while repository.adapter.current_transaction
        repository.adapter.current_transaction.rollback
        repository.adapter.pop_transaction
      end
    end
  end

  config.before(:each) do
    repository(:default) do
      transaction = DataMapper::Transaction.new(repository)
      transaction.begin
      repository.adapter.push_transaction(transaction)
    end
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

require File.dirname(__FILE__) + '/fixtures.rb'

Merb::Test.add_helpers do


  def logout
    request('/logout')
  end

  def delete_default_member_from_project(project)
    project.members(:user_id => User.first(:login => 'shingara').id).each {|m| m.destroy}
    project.save
  end

  def need_a_milestone
    Project.gen unless Project.first
    p = Project.first
    Milestone.gen(:project => p) if p.milestones.empty?
  end

  def delete_project_and_user
    #DataMapper.auto_migrate!
    #Project.all.each{|p| p.destroy}
    #User.all.each{|u| u.destroy}
  end

  def create_default_data
    create_default_user
    need_a_milestone
  end

  def create_default_user
    delete_project_and_user
    create_default_admin
    u = User.first(:login => 'shingara',             
                   :email => 'cyril.mougel@gmail.com')
    unless u
      u = User.create( :login => 'shingara',
                      :email => 'cyril.mougel@gmail.com',
                      :password => 'tintinpouet',
                      :password_confirmation => 'tintinpouet') or raise "can't create user"
    end

    
    if Project.first.members(:user_id => u.id).empty?
      Project.first.members.create(:function_id => Function.gen.id,
                                  :user_id => u.id)
    end
  end

  def create_default_admin
    delete_project_and_user
    User.gen(:admin) unless User.first(:login => 'admin')
    Function.gen!(:admin) unless Function.first(:name => 'Admin')
    Project.gen! unless Project.first
    State.gen(:name => 'new') unless State.first(:name => 'new')
    State.gen(:name => 'check') unless State.first(:name => 'check')
    unless Project.first.members('function.name' => 'Admin')
      Project.first.members.create(:function_id => Function.gen(:admin).id,
                                  :user_id => User.first(:login => 'admin').id)
    end

    if Project.first.tickets.empty?
      Ticket.gen(:project_id => Project.first.id,
                 :member_create_id => User.first.id)
    end

    if Ticket.first.ticket_updates.empty?
      Ticket.first.ticket_updates.create(:member_create_id => User.first.id,
                                        :description => 'a good update')
    end
  end

  def login
    create_default_user
    request('/logout')
    request('/login', {:method => 'PUT',
            :params => { :login => 'shingara',
              :password => 'tintinpouet'}})
    u = User.first(:login => 'shingara')
    u.members(:function_id => Function.admin.id).each do |m|
      m.function = Function.first(:name.not => Function::ADMIN)
      m.save
    end
    u
  end

  def login_admin
    create_default_admin
    request('/logout')
    request('/login', {:method => 'PUT',
            :params => {:login => 'admin', :password => 'tintinpouet'}})
  end

  def need_developper_function
    unless Function.first(:name => 'Developper')
      Function.gen(:name => 'Developper')
    end
  end
end
