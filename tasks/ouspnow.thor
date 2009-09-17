$: << File.join("doc")
require 'rubygems'
require 'rdoc/rdoc'
require 'fileutils'
require 'erb'

# load all thor task from plugins
tasks_path = File.join(File.dirname(__FILE__), "..", "app", "plugins")
thor_files = Dir["#{tasks_path}/*/tasks/*.thor"]
thor_files.each{|thor_file| load thor_file }

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
      State.create(:name => 'resolved', :closed => true)
      State.create(:name => 'hold', :closed => true)
      State.create(:name => 'closed', :closed => true)
      State.create(:name => 'invalid', :closed => true)
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
      require 'spec/blueprints'
      (4..10).of {
        User.make
      }
      3.of{
        pr = make_project
        (1..3).of {
          Milestone.make(:project => pr)
        }
        (4..10).of {
          make_project_member(User.first, Function.first)
        }
        (20..40).of {
          Ticket.make(
            :project => pr,
            :user_creator => pr.project_members.first.user)
        }
        (20..40).of {
          t = pr.tickets[rand(pr.tickets.size)]
          t.generate_update({
            :state_id => rand(2) == 0 ? t.state_id : State.all[rand(State.count)].id,
            :tag_list => rand(2) == 0 ? t.tag_list : (0..3).of { /\w+/.gen }.join(','),
            :user_assigned_id => rand(2) == 0 ? t.user_assigned_id : pr.project_members.first.user_id,
            :milestone_id => rand(2) == 0 ? t.milestone_id : t.project.milestones[rand(pr.milestones.size)].id,
            :description =>rand(2) == 0 ? "" : (0..3).of { /[:paragraph:]/.generate }.join("\n"),
          }, pr.project_members.rand.user)
        }
      }
    end
  end
end
