class Attachment
  include DataMapper::Resource
  include DataMapper::Constraints
  include Paperclip::Resource
  
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime

  has_attached_file :content,
    :style => {:thumb => "33x33>"}

  belongs_to :ticket
  belongs_to :ticket_update

end
