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
                  :password_confirmation => 'oupsnow')
      Function.create(:name => 'Admin')
      Function.create(:name => 'Developper')
      State.create(:name => 'new')
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
      State.create(:name => 'open')
      State.create(:name => 'closed')

    end
  end
end
