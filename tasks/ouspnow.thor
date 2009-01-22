$: << File.join("doc")
require 'rubygems'
require 'rdoc/rdoc'
require 'fileutils'
require 'erb'

module OupsNow

  class Bootstrap < Thor

    desc 'first_value', 'create first user and admin function'
    def first_value
      require 'merb-core'
      ::Merb.start_environment(
        :environment => ENV['MERB_ENV'] || 'development')
      User.create(:login => 'admin', 
                  :email => 'admin@admin.com',
                  :password => 'oupsnow',
                  :password_confirmation => 'oupsnow',
                  :global_admin => true)
      Function.create(:name => 'Admin', :project_admin => true)
      Function.create(:name => 'Developper', :project_admin => false)
      State.create(:name => 'new')
      State.create(:name => 'open')
      State.create(:name => 'resolved')
      State.create(:name => 'hold')
      State.create(:name => 'closed')
      State.create(:name => 'invalid')
      Priority.create(:name => 'Low')
      Priority.create(:name => 'Normal')
      Priority.create(:name => 'High')
      Priority.create(:name => 'Urgent')
    end

  end

  class Populate < Thor

    desc 'generate_some_data', 'generate some data'
    def generate_some_data
      require 'merb-core'
      ::Merb.start_environment(
        :environment => ENV['MERB_ENV'] || 'development')
      require 'spec/fixtures'
      3.of{
        p = Project.gen
        (20..40).of {
          Ticket.gen(
            :project_id => p.id,
            :member_create_id => p.members.first.user_id)
        }
      }
    end
  end

  class Converter < Thor

    desc 'convert_from_redmine', 'convert from Redmine'
    def convert_from_redmine
      require 'task/converter/redmine.rb'
    end
  end
end
