class Redmine::JournalDetail
  include DataMapper::Resource

  property :id, Serial
  property :journal_id, Integer
  property :property, String
  property :prop_key, String
  property :old_value, String
  property :value, String

  def propertie_update
    case prop_key
    when 'status_id'
      [:state_id, State.first(:name => Redmine::Status.get(old_value).name).id,
        State.first(:name => Redmine::Status.get(value).name).id]
    when 'assigned_to_id'
      [:member_assigned_to_id, 
        old_value ? User.first(:login => Redmine::User.get(old_value).login).id : nil,
        value ? User.first(:login => Redmine::User.get(value).login).id : nil]

    when 'priority_id'
      [:priority_id,
        Priority.first(:name => Redmine::Enumeration.get(old_value).name).id,
        Priority.first(:name => Redmine::Enumeration.get(value).name).id]
    when 'fixed_version_id'
      [:milestone_id,
        old_value ? Milestone.first(:name => Redmine::Version.get(old_value).name).id : nil,
        value ? Milestone.first(:name => Redmine::Version.get(value).name).id : nil]
    when 'subject'
      [:title, old_value, value]
    else
      nil
    end
  end

  def self.repository_name
    :redmine
  end

  def self.default_storage_name
    'journal_detail'
  end
end
