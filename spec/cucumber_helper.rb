$main = self

module Merb
  module Test
    module Helpers
      module MongoMapper
        module ClassMethods
          def use_transactional_fixtures
            $main.Before do
              ::MongoMapper.connection.drop_database(::MongoMapper.database.name)
            end
          end
        end
      end
    end

    module World
      module Base
        extend Helpers::MongoMapper::ClassMethods
      end
    end
  end
end
