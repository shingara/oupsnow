##
# Function of user can be have in all project
#
class Function

  include MongoMapper::Document

  ADMIN = 'Admin'

  # TODO: need test validation of required name and uniqueness of name
  key :name, String, :required => true, :unique => true
  key :project_admin, Boolean


  # TODO: when a function is delete
  # check all association about this function in all project
  # and delete all id. Change all user with another function
  
  # TODO: test mandatory of On function when you want delete all function by example

  ##
  # All ClassMethod
  class << self
    ##
    # First function define like project_admin
    #
    # TODO: need test like several function. one with no project_admin
    # and another define like project_admin
    #
    # @returns[Function]
    def admin
      Function.first(:conditions => {:project_admin => true})
    end

    ##
    # First function define like no project_admin
    #
    # TODO: need test like several function. one with no project_admin
    # and another define like project_admin
    #
    # @returns[Function]
    def not_admin
      Function.first(:conditions => {:project_admin => false})
    end
  end

end
