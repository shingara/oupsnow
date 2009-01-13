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

  def create_default_user
    unless User.first(:login => 'shingara')
      User.create( :login => 'shingara',
                  :email => 'cyril.mougel@gmail.com',
                  :password => 'tintinpouet',
                  :password_confirmation => 'tintinpouet') or raise "can't create user"
    end
  end

  def create_default_admin
    unless User.first(:login => 'admin')
      User.gen(:login => 'admin')
    end
    unless User.first(:login => 'admin').admin_on_one_project?
      Project.gen
    end
  end

  def login
    create_default_user
    request('/login', {:method => 'PUT',
            :params => { :login => 'shingara',
              :password => 'tintinpouet'}})
    User.first(:login => 'shingara')
  end

  def login_admin
    create_default_admin
    request('/login', {:method => 'PUT',
            :params => {:login => 'admin', :password => 'tintinpouet'}})
  end
end
