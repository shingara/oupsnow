require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe User do

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

  it 'should not valid if same email' do
    u = User.make
    User.make_unsaved(:email => u.email).should_not be_valid
  end

  it 'should not valid if no email' do
    User.make_unsaved(:email => '').should_not be_valid
  end

  describe 'self#update_all_global_admin' do
    before do
      @admin = User.make(:global_admin => true)
      @dev = User.make(:global_admin => false)
    end
    it 'should change project admin flag to User' do
      User.update_all_global_admin([@dev.id, @admin.id])
      User.find(@dev.id).global_admin.should be_true
    end

    it 'no change if no change needed' do
      User.update_all_global_admin([@admin.id])
      User.find(@dev.id).global_admin.should be_false
    end

    it 'can change several Users' do
      User.update_all_global_admin([@dev.id])
      User.find(@dev.id).global_admin.should be_true
      User.find(@admin.id).global_admin.should be_false
    end
  end

  describe '#admin?' do
    before do
      @project = make_project
      @user = User.make
    end
    it 'should true if user is admin of this project' do
      @project.project_members.build(:user => @user, :function => Function.make(:project_admin => true))
      @project.save! && @user.reload
      @user.should be_admin(@project)
    end

    it 'should false if user is not admin of this project but member of this project' do
      @project.project_members.build(:user => @user, :function => Function.make(:project_admin => false))
      @project.save! && @user.reload
      @user.should_not be_admin(@project)
    end
    it 'should false if user is not member of this project' do
      @user.should_not be_admin(@project)
    end
  end

  it 'should not change his email' do
    user = User.make
    user.email = 'new@yahoo.com'
    user.should_not be_valid
    user.errors.on('email').should_not be_empty
  end

  it 'should change login of watcher if change is login'
  it 'should delete watcher embedded when user is destroy'


end
