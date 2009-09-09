class ProjectMember

  include MongoMapper::EmbeddedDocument

  key :user_name, String
  key :function_name, String
  key :project_admin, Boolean
  key :user_id, String
  key :function_id, String

  belongs_to :user
  belongs_to :function

  def self.change_functions(member_function)
    return true if member_function.empty?
    project = nil
    previous_function = {}
    complete = true
    member_function.keys.each do |member_id|
      member = Member.get!(member_id.to_i)
      previous_function[member.id] = member.function.id
      if project != member.project && !project.nil?
        complete = false
        break
      else
        project = member.project

        member.function = Function.get!(member_function[member_id].to_i)
        member.save
      end
    end
    project_have_admin = project.have_one_admin
    if project_have_admin.is_a?(Array) && !project_have_admin.first
      complete = false
    end
    unless complete
      previous_function.each do |k,v|
        m = Member.get!(k)
        m.function_id = v
        m.save!
      end
      false
    else
      true
    end
  end

end
