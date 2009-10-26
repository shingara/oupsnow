class UsersController < ApplicationController

  before_filter :authenticate_user!, :except => [:new, :create]
  before_filter :only_own_account, :only => [:edit, :update]

  ## TODO: put it on model
  #params_accessible :user => [:login, :firstname, :lastname, :email, :password, :password_confirmation]

  def new
    @user = User.new
    @title = "New user"
  end

  def edit
    @user = current_user
    @title = "edit my profile"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] =  "User was successfully created"
      redirect_to edit_user_url(@user)
    else
      flash[:error] = "User failed to be created"
      render :new
    end
  end

  def update
    @user = User.find(params[:id])
    return return_404 unless @user
    if @user.update_attributes(params[:user])
       redirect_to projects_url
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    return return_404 unless @user
    if @user.destroy
      redirect_to users_url
    else
      raise InternalServerError
    end
  end

  private

  def only_own_account
    @user = User.find(params[:id])
    unless @user == current_user
      return return_401
    end
  end

end # Users
