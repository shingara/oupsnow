require 'cucumber/rake/task'

cucumber_options = lambda do |t|
  # if you want to pass some custom options to cucumber, pass them here
  if File.exist? Merb.root / 'bin' / 'cucumber'
    t.binary = Merb.root / 'bin' / 'cucumber'
  end
  t.fork = true

  t.cucumber_opts = '--require features'
end

Cucumber::Rake::Task.new(:features, &cucumber_options)
Cucumber::Rake::FeatureTask.new(:feature, &cucumber_options)
namespace :merb_cucumber do 
  task :env do
    Merb.start_environment(:environment => "cucumber", :adapter => 'runner')
  end
end


dependencies = ['merb_cucumber:env', 'db:drop']
task :features => dependencies
task :feature  => dependencies

