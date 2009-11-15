require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Function do

  it "should have dm-sweatshop valid" do
    Function.make.should be_valid
  end

  describe 'self#update_project_admin' do
    before do
      @admin = Function.make(:admin)
      @dev = Function.make(:project_admin => false)
    end
    it 'should change project admin flag to function' do
      Function.update_project_admin([@dev.id, @admin.id])
      Function.find(@dev.id).project_admin.should be_true
    end

    it 'no change if no change needed' do
      Function.update_project_admin([@admin.id])
      Function.find(@dev.id).project_admin.should be_false
    end

    it 'can change several functions' do
      Function.update_project_admin([@dev.id])
      Function.find(@dev.id).project_admin.should be_true
      Function.find(@admin.id).project_admin.should be_false
    end
  end

end
