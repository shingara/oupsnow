class Watcher
  include MongoMapper::EmbeddedDocument

  key :user_id, ObjectId, :required => true
  key :email, String, :required => true
  key :login, String, :required => true

  belongs_to :user
end
