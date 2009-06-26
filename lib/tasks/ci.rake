namespace :ci do
  desc "Start all build to ci"
  task :build => ['spec', 'features']
end
