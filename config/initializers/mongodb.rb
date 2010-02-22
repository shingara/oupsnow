File.open(File.join(RAILS_ROOT, 'config/database.yml'), 'r') do |f|
  @settings = YAML.load(f)[RAILS_ENV]
end

Mongoid.configure do |config|
  name = @settings["database"]
  host = @settings["host"]
  config.master = Mongo::Connection.new.db(name,
                                          :logger => STDOUT)
end
