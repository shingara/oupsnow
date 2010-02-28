module OupsNow

  class Populate < Thor


    desc 'generate_users', 'generate some users'
    def generate_users(nb_min=4, nb_max=nb_min)
      dependencies
      puts 'generate users'
      log_progress(nb_min, nb_max) do
        User.make
      end
    end

    desc 'generate_project_member', 'generate several project_member'
    def generate_project_member(project, nb_min=4, nb_max=nb_min)
      dependencies
      puts 'generate project member'
      user_ids = User.all.map(&:id)
      function_ids = Function.all.map(&:id)
      log_progress(nb_min,nb_max) {
        user = User.find(user_ids.rand)
        unless project.has_member?(user)
          project.project_members << ProjectMember.make(:user => user,
                                                        :function => Function.find(function_ids.rand))
        end
      }
      project.save!
    end

    desc 'generate_milestone', 'generate several milestone'
    def generate_milestone(project, nb_min=1, nb_max=nb_min)
      dependencies
      puts 'generate milestone'
      log_progress(nb_min,nb_max) {
        Milestone.make(:project => project)
      }
    end

    desc 'generate_tickets_update', 'generate some ticket update'
    def generate_tickets_update(ticket, nb_min=20, nb_max=nb_min)
      dependencies
      puts 'generate ticket update'
      state_ids = State.all.map(&:id)
      log_progress(nb_min,nb_max) {
        make_ticket_update(ticket, { :state_id => rand(2) == 0 ? ticket.state_id : State.find(state_ids.rand).id,
                           :tag_list => rand(2) == 0 ? ticket.tag_list : (0..3).of { /\w+/.gen }.join(','),
                           :user_assigned_id => rand(2) == 0 ? ticket.user_assigned_id : ticket.project.project_members.first.user_id,
                           :milestone_id => rand(2) == 0 ? ticket.milestone_id : ticket.project.milestones[rand(ticket.project.milestones.size)].id,
                           :description =>rand(2) == 0 ? "" : (0..3).of { /[:paragraph:]/.generate }.join("\n"),
                           :project => ticket.project,
        }, ticket.project.project_members.rand.user)
        ticket.save!
      }
    end

    desc 'generate_tickets', 'generate tickets'
    def generate_tickets(project=nil, nb_min=20, nb_max=nb_min)
      dependencies
      puts 'generate ticket'
      project_ids = Project.all.map(&:id)
      user_ids = User.all.map(&:id)
      log_progress(nb_min.to_i,nb_max.to_i) {
        project = Project.find(project_ids.rand) if project.blank? || project == 'nil'
        ticket = make_ticket(:project => project,
                    :user_creator => User.find(user_ids.rand))
        generate_tickets_update(ticket, 0, 10)
      }
    end


    desc 'generate_project', 'generate some project'
    def generate_project(nb=3)
      dependencies
      puts 'generate project'
      log_progress(1, nb) {
        pr = make_project
        generate_project_member(pr, 4, 10)
        pr.reload
        generate_milestone(pr, 1, 3)
        pr.reload
        generate_tickets(pr, 20, 40)
      }
    end

    desc 'generate_some_data', 'generate some data'
    def generate_some_data
      dependencies
      generate_users(50,100)
      generate_project(4)
      generate_tickets(nil,4000,10000)

      puts "Nb total in database"
      MongoMapper.database.collections.each do |coll|
        puts "#{coll.name} : #{coll.count} items"
      end
    end

    private

    def dependencies
      unless @dependencies
        require 'mongo_mapper'
        require 'machinist'
        require 'machinist/mongo_mapper'
        require 'randexp'
        require 'config/boot'
        require File.join(Rails.root, '/config/environment')
        require 'spec/blueprints'
      end
      @dependencies = true
    end

    def log_progress(min,max)
      progress = 1
      (min.to_i..max.to_i).of {
        yield
        STDOUT.print '.'
        if progress > 10
          STDOUT.flush
          progress = 1
        else
          progress += 1
        end
      }
      STDOUT.print "\n"
      STDOUT.flush
    end
  end
end
