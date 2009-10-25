module Admin
  class PrioritiesController < ApplicationController

    before_filter :authenticate_user!
    before_filter :need_admin
  
    def index
      @priorities = Priority.all
      @title = "Administration : Priorities"
    end
  
    def new
      @priority = Priority.new
      @title = "Administration : new priority"
    end
  
    def create
      @priority = Priority.new(params[:priority])
      if @priority.save
        flash[:notice] = "Priority was successfully created"
        redirect_to admin_priorities_url
      else
        flash[:error] = "Priority failed to be created"
        render :new
      end
    end
  
  end # Priorities
end # Admin
