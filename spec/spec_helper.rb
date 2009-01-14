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

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
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

  def delete_project_and_user
    Project.all.each {|p| p.destroy}
    User.all.each {|u| u.destroy}
    Function.all.destroy!
  end

  def create_default_user
    delete_project_and_user
    create_default_admin
    u = User.create( :login => 'shingara',
                :email => 'cyril.mougel@gmail.com',
                :password => 'tintinpouet',
                :password_confirmation => 'tintinpouet') or raise "can't create user"
    Project.first.members.create(:function_id => Function.gen.id,
                                :user_id => u.id)
  end

  def create_default_admin
    delete_project_and_user
    User.gen(:login => 'admin')
    Project.gen
    Project.first.members.create(:function_id => Function.gen(:admin).id,
                                :user_id => User.first(:login => 'admin').id)
    Ticket.gen(:project_id => Project.first.id,
               :member_create_id => User.first.id)
    Ticket.first.ticket_updates.create(:member_create_id => User.first.id,
                                      :description => 'a good update')
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
