class Attachment
  include MongoMapper::EmbeddedDocument
  
  key :created_at, DateTime
  key :filename, String

end
