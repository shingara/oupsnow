class ConverterError < Exception
end

class BaseConverter
  def self.convert
    raise NotImplementError
  end


  def import_users(&block)
    puts 'Start migration of user'
    users = []
    old_users.each do |old_user|
      users << import_user(old_user, &block)
    end
  rescue ConverterError => e
    puts "Only users : #{users.map {|u| u.login}.join(', ')} are import."
  end

  def import_user(old_user, &block)
    user = block.call(old_user)
    user.password = 'oupsnow'
    user.password_confirmation = 'oupsnow'
    unless user.save!
      raise ConverterError.new ("We can't import all user. the convert stop. The import error is : #{user.errors.map {|k,v| "#{k} #{v}"}.join(', ')}")
    end
  end

  def import_projects(&block)
    puts 'Start migration of project'
    projects = []
    old_projects.each do |old_project|
      projects << import_project(old_project, &block)
    end
  rescue ConverterError => e
    puts "Only project : #{projects.map {|p| p.title}.join(', ')} are import."
  end

  def import_project(old_project, &block)
    project = block.call(old_project)
    unless project.save!
      raise ConverterError.new ("We can't import all projects. the convert stop. The import error is : #{project.errors.map {|k,v| "#{k} #{v}" }.join(', ')}")
    end
  end

  def import_functions(&block)
    puts 'Start migration of function'
    functions = []
    old_functions.each do |old_function|
      functions << import_function(old_function, &block)
    end
  rescue ConverterError => e
    puts "Only function : #{functions.map {|p| p.name}.join(', ')} are import."
  end

  def import_function(old_function, &block)
    function = block.call(old_function)
    unless function.save!
      raise ConverterError.new ("We can't import all functions. the convert stop. The import error is : #{function.errors.map {|k,v| "#{k} #{v}"}.join(', ')}")
    end
  end

  def import_members(&block)
    puts 'Start migration of member'
    members = []
    old_members.each do |old_member|
      members << import_member(old_member, &block)
    end
  rescue ConverterError => e
    puts "Only member : #{members.map {|m| m.user.login}.join(', ')} are import."
  end

  def import_member(old_member, &block)
    member = block.call(old_member)
    unless member.save!
      raise ConverterError.new ("We can't import all projects. the convert stop. The import error is : #{member.errors.map {|k,v| "#{k} #{v}"}.join(', ')}")
    end
  end

  def import_states(&block)
    puts 'Start migration of states'
    states = []
    old_states.each do |old_state|
      states << import_state(old_state, &block)
    end
  rescue ConverterError => e
    puts "Only member : #{states.map {|t| t.name}.join(', ')} are import."
  end

  def import_state(old_state, &block)
    state = block.call(old_state)
    unless state.save!
      raise ConverterError.new ("We can't import all states. the convert stop. The import error is : #{state.errors.map {|k,v| "#{k} #{v}"}.join(', ')}")
    end
  end

  def import_priorities(&block)
    puts 'Start migration of priorities'
    priorities = []
    old_priorities.each do |old_priority|
      priorities << import_priority(old_priority, &block)
    end
  rescue ConverterError => e
    puts "Only priorities : #{priorities.map {|t| t.name}.join(', ')} are import."
  end

  def import_priority(old_priority, &block)
    priority = block.call(old_priority)
    unless priority.save!
      raise ConverterError.new ("We can't import all priorities. the convert stop. The import error is : #{priority.errors.map {|k,v| "#{k} #{v}"}.join(', ')}")
    end
  end

  def import_milestones(&block)
    puts 'Start migration of milestone'
    milestones = []
    old_milestones.each do |old_milestone|
      milestones << import_milestone(old_milestone, &block)
    end
  rescue ConverterError => e
    puts "Only member : #{milestones.map {|t| t.name}.join(', ')} are import."
  end

  def import_milestone(old_milestone, &block)
    milestone = block.call(old_milestone)
    unless milestone.save!
      raise ConverterError.new ("We can't import all milestones. the convert stop. The import error is : #{milestone.errors.map {|k,v| "#{k} #{v}"}.join(', ')}")
    end
    milestone.write_event_create(User.first(:global_admin => true))
  end

  def import_tickets(&block)
    puts 'Start migration of ticket'
    tickets = {}
    old_tickets.each do |old_ticket|
      tickets[old_ticket.id] = import_ticket(old_ticket, &block)
    end
    tickets
  rescue ConverterError => e
    puts "Only member : #{tickets.each_values.map {|t| t.title}.join(', ')} are import."
  end

  def import_ticket(old_ticket, &block)
    ticket = block.call(old_ticket)
    ticket.valid?
    unless ticket.save!
      raise ConverterError.new ("We can't import all tickets. the convert stop. The import error is : #{ticket.errors.map {|k,v| "#{k} #{v}"}.join(', ')}")
    end
    event = ticket.write_create_event
    event.created_at = ticket.created_at
    event.save
    ticket
  end

  def import_ticket_updates(&block)
    puts 'Start migration of ticket update'
    ticket_updates = []
    old_ticket_updates.each do |old_ticket_update|
      ticket_updates << import_ticket_update(old_ticket_update, &block)
    end
  rescue ConverterError => e
    puts "Only member : #{ticket_updates.map {|t| t.title}.join(', ')} are import."
  end

  def import_ticket_update(old_ticket_update, &block)
    ticket_update = block.call(old_ticket_update)
    ticket_update.valid?
    unless ticket_update.save!
      raise ConverterError.new ("We can't import all tickets. the convert stop. The import error is : #{ticket_update.errors.map {|k,v| "#{k} #{v}"}.join(', ')}")
    end
    event = ticket_update.write_event
    event.created_at = ticket_update.created_at
    event.save
  end


  def old_users
    raise NotImplementError
  end

  def old_projects
    raise NotImplementError
  end

  def old_functions
    raise NotImplementError
  end

  def old_members
    raise NotImplementError
  end

  def old_milestones
    raise NotImplementError
  end

  def old_tickets
    raise NotImplementError
  end

  def old_ticket_updates
    raise NotImplementError
  end
end
