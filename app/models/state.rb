class State

  include MongoMapper::Document

  key :name, String, :required => true, :unique => true #, :nullable => false, :unique => true
  key :closed, Boolean, :default => false

  def self.closed
    all(:closed => true)
  end

end
