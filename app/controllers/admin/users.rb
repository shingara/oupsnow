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

    def update_all(user_admin)
      user_admin.each do |k, v|
        f = User.get(k)
        f.global_admin = (v == "1".to_s)
        f.save
      end
      redirect resource(:admin, :users), :message => 'All users updated'
    end
  
  end # Users
end # Admin
