require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe User do

  before :each do
    User.collection.clear()
  end

  it "should be valid if admin global" do
    User.make(:admin).should be_valid
  end
  
  it 'should not valid if global_admin is false but no user global_admin' do
    u = User.make(:admin)
    u.global_admin = false
    u.should_not be_valid
  end

  it 'should valid with global_admin false because already user global_admin' do
    User.make(:admin)
    User.make(:global_admin => false).should be_valid
  end

  it 'should not put himself like global_admin false if you are the alone global_admin' do
    User.make(:admin)
    u = User.first
    u.global_admin = false
    u.should_not be_valid
  end

  it 'should first user can be create and define like global_admin' do
    u = User.new(:login => 'shingara',
             :email => 'cyril.mougel@gmail.com',
             :password => 'tintinpouet',
             :password_confirmation => 'tintinpouet')
    u.save.should be_true
    u.global_admin.should be_true
  end

  it 'should not valid if same login' do
    u = User.make
    User.make_unsaved(:login => u.login).should_not be_valid
  end

end
