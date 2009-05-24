require 'cucumber/rake/task'

cucumber_options = lambda do |t|
  # if you want to pass some custom options to cucumber, pass them here
  if File.exist? Merb.root / 'bin' / 'cucumber'
    t.binary = Merb.root / 'bin' / 'cucumber'
  end
  t.fork = true

  t.cucumber_opts = ''
  require_list = Array(FileList[File.join(File.dirname(__FILE__),"../../features/**/*.rb")])
  require_list.each do |step_file|
    t.cucumber_opts << '--require'
    t.cucumber_opts << step_file
  end
end

Cucumber::Rake::Task.new(:features, &cucumber_options)
Cucumber::Rake::FeatureTask.new(:feature, &cucumber_options)
namespace :merb_cucumber do 
  task :test_env do
    Merb.start_environment(:environment => "test", :adapter => 'runner')
  end
end


dependencies = ['merb_cucumber:test_env', 'db:automigrate']
task :features => dependencies
task :feature  => dependencies

