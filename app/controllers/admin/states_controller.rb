class Admin::StatesController < Admin::BaseController

  before_filter :authenticate_user!
  before_filter :need_admin

  def index
    @states = State.all
    @title = "Administration : States"
  end

  def new
    @state = State.new
    @title = "Administration : new state"
  end

  def create
    @state = State.new(params[:state])
    if @state.save
      flash[:notice] = 'State was successfully created'
      redirect_to admin_states_url
    else
      flash[:error] = "State failed to be created"
      render :new
    end
  end

  def update_all
    State.update_all_closed(params[:closed].keys)
    flash[:notice] = 'All states updated'
    redirect_to admin_states_url
  end

  def destroy
    @state = State.find(params[:id])
    if @state.destroy
      redirect_to admin_states_url
    else
      raise InternalServerError
    end
  end

end # States
