module ApplicationHelper

  def sub_menu
  end

  def title_project
    ret = "Oupsnow"
    ret += " : #{@project.name}" if @project && !@project.name.blank?
    ret
  end

  def title_header
    ret = "Oupsnow"
    ret += " - #{@project.name}" if @project && !@project.name.blank?
    ret += " : #{@title}" if @title
    ret
  end


  def admin?(project)
    user_signed_in? && (current_user.global_admin? || current_user.admin?(project))
  end

  def global_admin?
    user_signed_in? && current_user.global_admin?
  end


  def current_or_not(bool)
    bool ? "active" : ""
  end

  def overview_current
    current_or_not(params[:controller] == 'projects' &&
                   params[:action] == 'overview')
  end

  def milestone_current
    current_or_not(params[:controller] == 'milestones')
  end

  def tickets_current
    current_or_not((params[:controller] == 'tickets' && params[:action] != 'new' && params[:action] != 'create' && !@new_ticket) ||
                   params[:controller] == 'ticket_updates')
  end

  def projects_current
    current_or_not(params[:controller] == 'projects' &&
                   params[:action] != 'overview' &&
                   params[:action] != 'edit' &&
                   params[:action] != 'delete')
  end

  def tickets_new_current
    current_or_not((params[:controller] == 'tickets' &&
                    params[:action] == 'new') || (@ticket_new))
  end

  def settings_current
    current_or_not( params[:controller] =~ /settings\/\S+/ ||
                   (params[:controller] == 'projects' && (params[:action] == 'edit' || params[:action] == 'delete')))
  end

  def textilized(text)
    text = "" if text.nil?
    RedCloth.new(text).to_html
  end

  # Generate the tag cloud
  def tag_cloud(tags, classes)
    return if tags.empty?

    max_count = tags.values.sort.reverse.first

    tags.each do |tag, nb|
      if max_count > 1
        index = ((nb / max_count) * (classes.size - 1)).round
      else
        index = 0
      end
      yield tag, classes[index]
    end
  end

  def members_active
    active_or_not(params[:controller] == 'settings/project_members')
  end

  def active_or_not(bool)
    bool ? "active" : ""
  end

  def project_edit_active
    active_or_not(params[:controller] == 'projects' &&
                  params[:action] == 'edit')
  end

  def project_delete_active
    active_or_not(params[:controller] == 'projects' &&
                  params[:action] == 'delete')
  end

end
