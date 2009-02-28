class TagsPart < Merb::PartController

  def index(taggable)
    if taggable[:type] == 'Projects'
      @tags = Project.get(taggable[:type_id]).ticket_tag_counts
    elsif taggable[:type] == 'Tickets'
      @tags = Ticket.get(taggable[:type_id]).tag_counts
    else
      raise NoMethodError
    end
    render
  end

end
