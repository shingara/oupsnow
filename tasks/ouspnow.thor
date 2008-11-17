$: << File.join("doc")
require 'rubygems'
require 'rdoc/rdoc'
require 'fileutils'
require 'erb'

module OupsNow
  class Populate < Thor

    desc 'generate_some_data', 'generate some data'
    def generate_some_data
      require 'merb-core'
      Merb.start_environment(
        :environment => ENV['MERB_ENV'] || 'development')
      require 'spec/fixtures'
      3.of{Project.gen}
    end
  end
end
