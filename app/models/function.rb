##
# Function of user can be have in all project
#
class Function

  include Mongoid::Document

  # TODO: need test validation of required name and uniqueness of name
  field :name, :type => String
  validates_uniqueness_of :name
  validates_presence_of :name
  field :project_admin, :type => Boolean

  has_many_related :project_members


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

    ##
    # Update all function and change information if there are or not
    # project_admin.
    #
    # @params[Array] List of function key are project_admin. Other are no project_admin
    def update_project_admin(functions)
      Function.all.each do |function|
        function.project_admin = functions.include?(function.id.to_s)
        function.save
      end
    end
  end

end
