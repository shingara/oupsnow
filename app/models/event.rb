class Event

  include Mongoid::Document
  include Mongoid::Timestamps
  # TODO: need test about created_at/updated_at needed


  ### PROPERTY ###

  field :user_name, :type => String
  field :event_type, :type => String
  field :event_title, :type => String

  # dependencies in other collection
  belongs_to_related :user
  index :user_id
  belongs_to_related :project
  index :project_id
  belongs_to_related :eventable, :polymorphic => true #, :dependent => :destroy
  # TODO: :dependent don't exist on MongoID try to implement it
  index :eventable_id

  before_save :update_event_title
  before_save :update_user_name

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
