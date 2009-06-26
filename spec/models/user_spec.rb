require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe User do

  it "should be valid" do
    User.make.should be_valid
  end

  it 'should not valid if global_admin is false but no user global_admin' do
    User.all.destroy!
    User.gen(:admin, :global_admin => false).should_not be_valid
  end

  it 'should valid with global_admin false because already user global_admin' do
    User.all.destroy!
    User.gen!(:admin)
    User.make(:global_admin => false).should be_valid
  end

  it 'should not put himself like global_admin false if you are the alone global_admin' do
    User.all.destroy!
    User.gen!(:admin)
    u = User.first
    u.global_admin = false
    u.should_not be_valid
  end

end
