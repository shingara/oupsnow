class Event

  include Mongoid::Document
  include Mongoid::Timestamps

  ### PROPERTY ###

  field :user_name, :type => String
  field :event_type, :type => String
  field :event_title, :type => String

  ### Association ###

  field :user_id, :type => BSON::ObjectID
  field :project_id, :type => BSON::ObjectID
  index :project_id

  # Polymorphic event
  field :eventable_type, :type => String
  field :eventable_id, :type => BSON::ObjectID

  belongs_to_related :user
  belongs_to_related :project
  belongs_to_related :eventable, :polymorphic => true, :dependent => :destroy

  before_save :update_event_title
  before_save :update_user_name

  # TODO: need test about created_at/updated_at needed
  #timestamps!

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
