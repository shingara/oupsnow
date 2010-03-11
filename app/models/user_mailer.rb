class UserMailer < ActionMailer::Base

  helper :tickets

  def ticket_update(project, ticket_update, watcher)
    recipients watcher.email
    root_ticket = ticket_update._root_document
    subject "[#{project.name} ##{root_ticket.num}] #{root_ticket.title}"
    body :ticket_update => ticket_update,
      :project => project,
      :root_ticket => root_ticket
  end

end
