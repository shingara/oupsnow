class Watcher
  include Mongoid::Document

  field :user_id, :type =>ObjectId, :required => true
  :validates_presence_of :user_id
  field :email, :type => String, :required => true
  validates_presence_of :email
  field :login, :type => String, :required => true
  validates_presence_of :login

  embedded_in :user
end
