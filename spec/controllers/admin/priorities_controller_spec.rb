require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Admin::PrioritiesController do

  integrate_views

  before do
    Priority.make
  end

  describe 'with admin user' do
    before do
      login_admin
    end

    describe 'index' do
      before do
        get :index
      end
      it 'should see all priorities' do
        assigns(:priorities).should == Priority.all
      end
    end

    describe 'create' do
      before do
        post :create, :priority => { :name => 'foo' }
      end

      it { response.should redirect_to(admin_priorities_url) }
      it { flash[:notice].should == "Priority was successfully created" }

    end

    describe 'new' do
      before do
        get :new
      end

      it { response.should be_success }
    end
  end
end
