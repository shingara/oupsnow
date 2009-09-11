class Event

  include MongoMapper::Document

  ### PROPERTY ###
  
  key :user_name, String
  key :event_type, String
  
  ### Association ###
  
  key :user_id, String
  key :project_id, String

  # Polymorphic event
  key :eventable_type, String
  key :eventable_id, String

  belongs_to :user
  belongs_to :project
  belongs_to :eventable, :polymorphic => true, :dependent => :destroy

  # TODO: need test about created_at/updated_at needed
  timestamps!

  def short_description
    eventable.title
  end


end
