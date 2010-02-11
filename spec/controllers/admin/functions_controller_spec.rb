require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Admin::FunctionsController do

  integrate_views

  describe 'admin user' do
    before do
      login_admin
    end

    describe 'index' do
      before do
        get :index
      end

      it 'should see several function' do
        assigns(:functions).should == Function.all
      end
    end

    describe 'create' do
      before do
        post :create, :function => {:name => 'foo'}
      end

      it "redirects to resource(:functions)" do
        response.should redirect_to(admin_functions_url)
        flash[:notice].should == "Function was successfully created"
      end
    end

    describe 'new' do
      before do
        get :new
      end

      it {response.should be_success}
    end

    describe 'update_all' do

      before do
        @dev = Function.make(:project_admin => false)
        put :update_all,
          :project_admin => {@dev.id.to_s => 1}
      end
      it 'should success if works' do
        response.should redirect_to(admin_functions_url)
        flash[:notice].should == 'All functions updated'
        @dev.reload.project_admin.should be_true
      end

    end
  end
end
