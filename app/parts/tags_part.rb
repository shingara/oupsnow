class TagsPart < Merb::PartController

  def index(taggable)
    if taggable[:type] == 'Projects'
      @project = Project.get(taggable[:type_id])
      @tags = @project.ticket_tag_counts
    elsif taggable[:type] == 'Tickets'
      @project = Project.get(taggable[:project_id])
      @tags = Ticket.get(taggable[:type_id]).tag_counts
    elsif taggable[:type] == 'Milestones'
      @project = Project.get(taggable[:project_id])
      @tags = Milestone.get(taggable[:type_id]).tag_counts
    else
      raise NoMethodError
    end
    render
  end

end
