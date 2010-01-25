class Backup
  def insert
    user_insert
    function_insert
    priorities_insert
    states_insert
    project_insert
    milestone_insert
    tickets_insert
    tickets_update_insert
  end

  # Model now
  # - :encrypted_password
  #   :deleted_at
  #   :_id
  #   :lastname
  #   :password_salt
  #   :firstname
  #   :login
  #   :global_admin
  #   :email
  #
  #   YAML format
  # - :crypted_password => DONE
  #   :email => DONE
  #   :firstname => DONE
  #   :lastname => DONE
  #   :gobal_admin => DONE
  #   :salt => DONE
  #   :id => DONE
  #   :deleted_at => DONE
  #   :login => DONE
  def user_insert
    puts 'update users'
    users.each do |user|
      begin
        User.create!(:deleted_at => user[:deleted_at],
                    :lastname => user[:lastname],
                    :firstname => user[:firstname],
                    :password => 'oupsnowdev',
                    :password_confirmation => 'oupsnowdev',
                    :login => user[:login],
                    :global_admin => user[:global_admin],
                    :email => user[:email])
        print '.'
      rescue MongoMapper::DocumentNotValid => e
        p e
        p user
      end
    end
    print "\n"
    STDOUT.flush
  end

  def function_insert
    puts 'insert function'
    YAML.load_file(Rails.root.join('backup/function.yml')).each do |function|
      Function.create!(:name => function[:name],
                       :project_admin => function[:project_admin])
      print '.'
    end
    print "\n"
    STDOUT.flush
  end

  def priorities_insert
    puts 'insert priorities'
    YAML.load_file(Rails.root.join('backup/prorities.yml')).each do |priority|
      Priority.create!(:name => priority[:name])
      print '.'
    end
    print "\n"
    STDOUT.flush
  end

  def states_insert
    puts 'insert state'
    YAML.load_file(Rails.root.join('backup/state.yml')).each do |state|
      State.create!(:name => state[:name].downcase,
                :closed => state[:closed])
      print '.'
    end
    print "\n"
    STDOUT.flush
  end

  def project_insert
    projects.each do |project|
      project_instance = Project.new(:name => project[:name],
                                :description => project[:description])
      members.select { |member|
        member[:project_id] == project[:id]
      }.each do |member|
        project_instance.add_member(user(member[:user_id]),
                           function(member[:function_id]))
      end
      project_instance.user_creator = User.first(:global_admin => true)
      project_instance.save!
    end
  end

  def milestone_insert
    puts 'insert milestone'
    YAML.load_file(Rails.root.join('backup/milestone.yml')).each do |milestone|
      Milestone.create!(:name => milestone[:name],
                       :description => milestone[:description],
                       :expected_at => milestone[:expected_at],
                       :project_id => project_id(milestone[:project_id]).id)
      print '.'
    end
    print "\n"
    STDOUT.flush
  end

  def tickets_insert
    puts 'insert tickets'
    tickets.each do |ticket|
      project_instance = project_id(ticket[:project_id])
      user_creator_id = ticket[:member_create_id] == 4 ? nil : user(ticket[:member_create_id]).id
      milestone = milestone(ticket[:milestone_id])
      next if user_creator_id.nil?
      ticket_instance = Ticket.create!(:title => ticket[:title],
                     :description => ticket[:description],
                     :num => ticket[:num],
                     :tag_list => ticket[:frozen_tag_list],
                     :user_creator_id => user_creator_id,
                     :project_id => project_instance.id,
                     :state_id => state(ticket[:state_id]).id,
                     :user_assigned_id => ticket[:member_assigned_id] ? user(ticket[:member_assigned_id]).id : nil,
                     :milestone_id => milestone,
                     :priority_id => priority_id(ticket[:priority_id]),
                     :updated_at => ticket[:updated_at])
      # need redefined created_at after created
      ticket_instance.created_at = ticket[:created_at]
      ticket_instance.save!
      event = ticket_instance.write_create_event
      event.created_at = ticket_instance.created_at
      event.save!
      print '.'
    end
    print "\n"
    STDOUT.flush
  end

  def tickets_update_insert
    puts 'insert tickets update'
    YAML.load_file(Rails.root.join('backup/ticket_update.yml')).each do |ticket_update|
      ticket_instance = ticket(ticket_update[:ticket_id])
      next if ticket_instance.nil?
      user_instance =  user(ticket_update[:member_create_id])
      next if ticket_update[:description].blank?
      ticket_update_instance = TicketUpdate.new(:description => ticket_update[:description],
                       :user_id => user_instance.id,
                       :creator_user_name => user_instance.login,
                       :created_at => ticket_update[:created_at])
      ticket_instance.ticket_updates << ticket_update_instance
      ticket_instance.save!

      event = ticket_update_instance.write_event(ticket_instance)
      event.created_at = ticket_update_instance.created_at
      event.save!
      print '.'
    end
    print "\n"
    STDOUT.flush
  end

  def tickets
    @tickets ||= YAML.load_file(Rails.root.join('backup/ticket.yml'))
  end

  def ticket(id)
    tick =  tickets.detect{|t| t[:id] == id}
    Ticket.first(:title => tick[:title],
                :project_id => project_id(tick[:project_id]).id)
  end

  def members
    @members ||= YAML.load_file(Rails.root.join('backup/member.yml'))
  end

  def users
    @users ||= YAML.load_file(Rails.root.join('backup/user.yml').to_s)
  end

  def functions
    @functions ||= YAML.load_file(Rails.root.join('backup/function.yml'))
  end

  def states
    @states ||= YAML.load_file(Rails.root.join('backup/state.yml'))
  end
  def state(id)
    State.first(:name => states.detect{|s| s[:id] == id}[:name].downcase)
  end

  def priorities
    @priorities ||= YAML.load_file(Rails.root.join('backup/prorities.yml'))
  end

  def priority_id(id)
    pi = priorities.detect{|s| s[:id].to_s == id.to_s}
    return nil unless pi
    Priority.first(:name => pi[:name]).id
  end

  def projects
    @projects ||= YAML.load_file(Rails.root.join('backup/project.yml'))
  end

  def milestones
    @milestones ||= YAML.load_file(Rails.root.join('backup/milestone.yml'))
  end

  def milestone(id)
    mi =  milestones.detect{|m| m[:id].to_s == id.to_s}
    return nil unless mi
    Milestone.first(:name => mi[:name],
                    :project_id => project_id(mi[:project_id]).id).id
  end

  def user(id)
    User.first(:login => users.detect{|u| u[:id] == id}[:login])
  end

  def function(id)
    Function.first(:name => functions.detect{|f| f[:id] == id}[:name])
  end

  def project_id(id)
    Project.first(:name => projects.detect{|f| f[:id] == id}[:name])
  end

end
