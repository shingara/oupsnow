require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Admin::StatesController do

  integrate_views

  before do
    State.make
  end

  describe 'with user admin' do
    before do
      login_admin
    end

    describe 'index' do
      before do
        get :index
      end

      it { response.should be_success }
      it { assigns(:states).should == State.all }
    end

    describe 'create' do
      before do
        post :create, :state => { :name => 'foo' }
      end

      it { response.should redirect_to(admin_states_url) }
      it { flash[:notice].should == "State was successfully created" }
    end

    describe 'destroy' do
      before do
        delete :destroy, :id => State.make.id
      end

      it { response.should redirect_to(admin_states_url) }
    end

    describe 'new' do
      before do
        get :new
      end

      it { response.should be_success }
    end
  end
end
