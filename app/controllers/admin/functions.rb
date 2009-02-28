module Admin
  class Functions < Application
    # provides :xml, :yaml, :js

    before :ensure_authenticated
    before :need_admin
  
    def index
      @functions = Function.all
      @title = "Administration : Functions"
      display @functions
    end
  
    def show(id)
      @function = Function.get(id)
      raise NotFound unless @function
      @title = "Administration : Function #{@function.name}"
      display @function
    end
  
    def new
      only_provides :html
      @function = Function.new
      @title = "Administration : new function"
      display @function
    end
  
    def create(function)
      @function = Function.new(function)
      if @function.save
        redirect resource(:admin, :functions), :message => {:notice => "Function was successfully created"}
      else
        message[:error] = "Function failed to be created"
        render :new
      end
    end
  
    def update_all(project_admin)
      project_admin.each do |k, v|
        f = Function.get(k)
        f.project_admin = (v == "1".to_s)
        f.save
      end
      redirect resource(:admin, :functions), :message => 'All functions updated'
    end
  
    def destroy(id)
      @function = Function.get(id)
      raise NotFound unless @function
      if @function.destroy
        redirect resource(:functions)
      else
        raise InternalServerError
      end
    end
  
  end # Functions
end # Admin
