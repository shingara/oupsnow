class Function

  include MongoMapper::Document

  ADMIN = 'Admin'

  key :name, String #:nullable => false, :unique => true
  key :project_admin, Boolean

  before_destroy :delete_all_members

  def delete_all_members
    members.each {|m| m.destroy}
  end

  def self.admin
    Function.first(:project_admin => true)
  end

  def self.not_admin
    Function.first(:project_admin => false)
  end

end
