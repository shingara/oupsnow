class Admin::UsersController < Admin::BaseController

  before_filter :authenticate_user!
  before_filter :need_admin

  def index
    @users = User.all
    @title = "Administration : Users"
  end

  def show
    @user = User.find(params[:id])
    return return_404 unless @user
    @title = "Administration : user #{@user.login}"
  end

  def destroy
    @user = User.find(params[:id])
    return return_404 unless @user
    if @user.destroy
      redirect_to admin_users_url
    else
      raise InternalServerError
    end
  end

  ##
  # Mass change about global_admin user
  # All key on user_admin params are now global
  # other are no global_admin
  def update_all
    User.update_all_global_admin(params[:user_admin].keys)
    flash[:notice] = 'All users updated'
    redirect_to admin_users_url
  end

end # Users
