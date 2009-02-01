class Redmine::Journal
  include DataMapper::Resource

  property :id, Serial
  property :journalized_id, Integer
  property :journalized_type, String
  property :user_id, Integer
  property :notes, Text
  property :created_on, DateTime

  belongs_to :user
  has n, :journal_details

  def properties_update
    props = []
    journal_details.each do |j|
      pu = j.propertie_update
      props << pu unless pu.nil?
    end
    props
  end

  def self.repository_name
    :redmine
  end

  def self.default_storage_name
    'journal'
  end
end
