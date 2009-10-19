require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe ProjectMember do
  before(:each) do
    @project = make_project
  end

  it 'should have blueprint valid' do
    @project.project_members << ProjectMember.make
    @project.should be_valid
  end

  it 'should need a user' do
    @project.project_members << ProjectMember.make(:user => nil)
    @project.should be_valid
  end

  it 'should need a function' do
    @project.project_members << ProjectMember.make(:function => nil)
    @project.should be_valid
  end

  it 'should have a user_name with user' do
    user = User.make
    @project.project_members << ProjectMember.make(:user => user)
    @project.save!
    @project.project_members.last.user_name.should == user.login
  end

  it 'should have a function_name with user' do
    function = Function.make(:project_admin => false)
    @project.project_members << ProjectMember.make(:function => function)
    @project.save!
    @project.project_members.last.function_name.should == function.name
    @project.project_members.last.project_admin.should_not be_true
  end

  it 'should be project_admin if function is project_admin' do
    function = Function.make(:project_admin => true)
    @project.project_members << ProjectMember.make(:function => function)
    @project.save!
    @project.project_members.last.function_name.should == function.name
    @project.project_members.last.project_admin.should be_true
  end
end
