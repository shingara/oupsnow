# Edit this Gemfile to bundle your application's dependencies.
# This preamble is the current preamble for Rails 3 apps; edit as needed.
source :gemcutter
git "git://github.com/rails/rack.git"
git "http://github.com/merbjedi/mongomapper.git", :branch => 'rails3'

gem "rails", "3.0.0.beta"
gem "railties"

git "git://github.com/indirect/rails3-generators.git"
gem "rails3-generators"

gem 'mongo', '0.18.3'
gem 'mongo_ext', '0.18.3'
gem "mongo_mapper"
gem 'RedCloth', '4.2.2', :require => 'redcloth'
gem 'haml'
gem 'warden'
gem 'devise', '1.1.pre3'
gem 'will_paginate', '3.0.pre'

group :test do
  gem 'machinist_mongo', :require => 'machinist/mongo_mapper'
  gem 'webrat'
  gem 'randexp'
  gem "rspec-rails", ">= 2.0.0.a9"
end
