module Admin
  class Users < Application
    # provides :xml, :yaml, :js

    before :ensure_authenticated
    before :need_admin
  
    def index
      @users = User.all
      @title = "Administration : Users"
      display @users
    end
  
    def show(id)
      @user = User.get(id)
      raise NotFound unless @user
      @title = "Administration : user #{@user.login}"
      display @user
    end
  
    def destroy(id)
      @user = User.get(id)
      raise NotFound unless @user
      if @user.destroy
        redirect resource(:admin, :users)
      else
        raise InternalServerError
      end
    end
  
  end # Users
end # Admin
