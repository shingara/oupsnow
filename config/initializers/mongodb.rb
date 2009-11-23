db_config = YAML::load(File.read(RAILS_ROOT + "/config/database.yml"))

if db_config[Rails.env] && db_config[Rails.env]['adapter'] == 'mongodb'
  mongo = db_config[Rails.env]
  MongoMapper.connection = Mongo::Connection.new(mongo['hostname'],
                                                 mongo['port'] || 27017,
                                                :logger => Rails.logger)
  MongoMapper.database = mongo['database']
  MongoMapper.ensure_indexes!
end
