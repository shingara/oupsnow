class Priority

  include Mongoid::Document

  field :name, :type => String

  index :name, :unique => true

  validates_presence_of :name
  validates_uniqueness_of :name

  before_destroy :only_without_ticket

  private

  ##
  # Destroy this priority if no association
  def only_without_ticket
    unless tickets.empty?
      raise DestroyException
    end
  end

end
