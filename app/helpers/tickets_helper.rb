module TicketsHelper

  def update_field(prop)
    "#{property_update(prop)} is change from '#{prop[1]}' to '#{prop[2]}'"
  end

  def sort_by(property)
    if params[:sort_by] == property
      {:sort_by => property, :order => (params[:order] == 'asc' ? 'desc' : 'asc')}
    else
      {:sort_by => property, :order => 'asc'}
    end
  end

  def property_update(prop)
    case prop[0]
    when :state
      "Status"
    when :tag_list
      "Tag"
    when :user_assigned
      "Responsible"
    when :title
      "Title"
    when :priority
      "Priority"
    when :milestone
      "Milestone"
    else
      prop[0]
    end
  end

end
