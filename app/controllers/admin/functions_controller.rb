module Admin
  class FunctionsController < ApplicationController

    before_filter :ensure_authenticated
    before_filter :need_admin
  
    def index
      @functions = Function.all
      @title = "Administration : Functions"
    end
  
    def show
      @function = Function.get(params[:id])
      return return_404 unless @function
      @title = "Administration : Function #{@function.name}"
    end
  
    def new
      @function = Function.new
      @title = "Administration : new function"
    end
  
    def create
      @function = Function.new(params[:function])
      if @function.save
        flash[:notice] = "Function was successfully created"
        redirect_to admin_functions_url
      else
        flash[:error] = "Function failed to be created"
        render :new
      end
    end
  
    def update_all
      params[:project_admin].each do |k, v|
        f = Function.get(k)
        f.project_admin = (v == "1".to_s)
        f.save
      end
      flash[:notice] = 'All functions updated'
      redirect_to admin_functions
    end
  
    def destroy
      @function = Function.get(params[:id])
      return return_404 unless @function
      if @function.destroy
        redirect_to admin_functions_url
      else
        raise InternalServerError
      end
    end
  
  end # Functions
end # Admin
