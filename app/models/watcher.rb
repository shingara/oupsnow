class Watcher
  include MongoMapper::EmbeddedDocument

  key :user_id, ObjectId
  key :email, String

  belongs_to :user
end
