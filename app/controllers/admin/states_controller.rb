module Admin
  class StatesController < ApplicationController
    
    before_filter :ensure_authenticated
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
      params[:closed].each do |k, v|
        s = State.get(k)
        s.closed = (v == "1".to_s)
        s.save
      end
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
end # Admin
