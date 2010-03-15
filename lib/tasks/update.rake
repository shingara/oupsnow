namespace :db do
  desc 'Update database with all callback'
  task :update => :environment do
    Milestone.all.map(&:update_tag_counts)
  end
end
