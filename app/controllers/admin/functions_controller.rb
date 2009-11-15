class Admin::FunctionsController < Admin::BaseController

  before_filter :authenticate_user!
  before_filter :need_admin

  def index
    @functions = Function.all
    @title = "Administration : Functions"
  end

  def show
    @function = Function.get(params[:id])
    return_404 unless @function
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

  ##
  # update all function with project_admin define.
  # params[:project_admin] is an Array with all function.id
  # are now project_admin
  def update_all
    Function.update_project_admin(params[:project_admin])
    flash[:notice] = 'All functions updated'
    redirect_to admin_functions_url
  end

  def destroy
    @function = Function.get(params[:id])
    return_404 unless @function
    if @function.destroy
      redirect_to admin_functions_url
    else
      raise InternalServerError
    end
  end

end # Functions
