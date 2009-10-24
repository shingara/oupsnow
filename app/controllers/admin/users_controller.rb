module Admin
  class UsersController < ApplicationController

    before_filter :ensure_authenticated
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

    def update_all
      params[:user_admin].each do |k, v|
        f = User.find(k)
        f.global_admin = (v == "1".to_s)
        f.save
      end
      flash[:notice] = 'All users updated'
      redirect_to admin_users_url
    end
  
  end # Users
end # Admin
