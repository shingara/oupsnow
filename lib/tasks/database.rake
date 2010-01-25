namespace :db do
  desc 'empty the database'
  task :drop => :environment do
    MongoMapper.database.collections.each do |coll|
      coll.remove
    end
  end

  task :insert => :environment do
    Backup.new.insert
  end
end
