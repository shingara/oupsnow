class Users < Application
  # provides :xml, :yaml, :js

  before :ensure_authenticated, :exclude => [:new, :create]
  before :only_own_account, :only => [:edit, :update]

  params_accessible :user => [:login, :firstname, :lastname, :email, :password, :password_confirmation]

  def new
    only_provides :html
    @user = User.new
    display @user
  end

  def edit(id)
    only_provides :html
    @user = session.user
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

  def update(id, user)
    @user = User.get(id)
    raise NotFound unless @user
    if @user.update_attributes(user)
       redirect resource(:projects)
    else
      display @user, :edit
    end
  end

  def destroy(id)
    @user = User.get(id)
    raise NotFound unless @user
    if @user.destroy
      redirect resource(:users)
    else
      raise InternalServerError
    end
  end

  private

  def only_own_account
    @user = User.get(params[:id])
    unless @user == session.user
      raise Unauthenticated
    end
  end

end # Users
