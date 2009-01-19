module Admin
  class Priorities < Application
    # provides :xml, :yaml, :js
  
    def index
      @priorities = Priority.all
      display @priorities
    end
  
    def new
      only_provides :html
      @priority = Priority.new
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
