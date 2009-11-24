class Event

  include MongoMapper::Document

  ### PROPERTY ###

  key :user_name, String
  key :event_type, String
  key :event_title, String

  ### Association ###

  key :user_id, ObjectId
  key :project_id, ObjectId
  ensure_index :project_id

  # Polymorphic event
  key :eventable_type, String
  key :eventable_id, ObjectId

  belongs_to :user
  belongs_to :project
  belongs_to :eventable, :polymorphic => true, :dependent => :destroy

  before_save :update_event_title
  before_save :update_user_name

  # TODO: need test about created_at/updated_at needed
  timestamps!

  ##
  # get the class eventable in string pluralize
  def eventable_pluralize
    eventable_type.pluralize.downcase
  end

  private

  def update_event_title
    self.event_title = eventable.title
  end

  def update_user_name
    self.user_name = user.login
  end


end
