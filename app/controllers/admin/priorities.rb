module Admin
  class Priorities < Application
    # provides :xml, :yaml, :js

    before :ensure_authenticated
    before :need_admin
  
    def index
      @priorities = Priority.all
      @title = "Administration : Priorities"
      display @priorities
    end
  
    def new
      only_provides :html
      @priority = Priority.new
      @title = "Administration : new priority"
      display @priority
    end
  
    def create(priority)
      @priority = Priority.new(priority)
      if @priority.save
        redirect resource(:admin, :priorities), :message => {:notice => "Priority was successfully created"}
      else
        message[:error] = "Priority failed to be created"
        render :new
      end
    end
  
  end # Priorities
end # Admin
