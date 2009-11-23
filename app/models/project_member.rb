class ProjectMember

  include MongoMapper::EmbeddedDocument

  # TODO: need test about required user_name and function_name
  key :user_name, String, :required => true
  key :function_name, String, :required => true
  key :project_admin, Boolean
  key :user_id, ObjectId
  key :function_id, ObjectId

  # Update field is made on master document

  belongs_to :user
  belongs_to :function

  validates_presence_of :function_id
  validates_presence_of :user_id

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

  def to_param
    user_name
  end

end
