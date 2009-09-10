class Users < Application
  # provides :xml, :yaml, :js

  before :ensure_authenticated, :exclude => [:new, :create]
  before :only_own_account, :only => [:edit, :update]

  params_accessible :user => [:login, :firstname, :lastname, :email, :password, :password_confirmation]

  def new
    only_provides :html
    @user = User.new
    @title = "New user"
    display @user
  end

  def edit
    only_provides :html
    @user = session.user
    @title = "edit my profile"
    display @user
  end

  def create(user)
    @user = User.new(user)
    if @user.save
      redirect resource(@user, :edit), :message => {:notice => "User was successfully created"}
    else
      message[:error] = "User failed to be created"
      render :new
    end
  end

  def update(login, user)
    @user = User.first(:login => login)
    raise NotFound unless @user
    if @user.update_attributes(user)
       redirect resource(:projects)
    else
      display @user, :edit
    end
  end

  def destroy(login)
    @user = User.first(:login => login)
    raise NotFound unless @user
    if @user.destroy
      redirect resource(:users)
    else
      raise InternalServerError
    end
  end

  private

  def only_own_account
    @user = User.first(:conditions => {:login => params[:login]})
    unless @user == session.user
      raise Unauthenticated
    end
  end

end # Users
