require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe ProjectMember do
  before(:each) do
    @project = make_project
  end

  describe 'validation' do
    it 'should have blueprint valid' do
      @project.project_members << ProjectMember.make
      @project.should be_valid
    end

    it 'should need a user' do
      @project.project_members << ProjectMember.make(:user => nil)
      @project.should_not be_valid
    end

    it 'should need a function' do
      project_member = ProjectMember.make(:function => nil)
      @project.project_members << project_member
      @project.valid?
      p @project.save
      p Project.find(@project.id).project_members
      p project_member.errors.full_messages
      p @project.project_members
      @project.should_not be_valid
    end

    it 'should be project_admin if function is project_admin' do
      function = Function.make(:project_admin => true)
      @project.project_members << ProjectMember.make(:function => function)
      @project.save!
      @project.project_members.last.function_name.should == function.name
      @project.project_members.last.project_admin.should be_true
    end

    it 'should not have several time the same project_member' do
      user = User.make
      @project.project_members << ProjectMember.make(:user => user)
      @project.save!
      nb_members = @project.project_members.size
      @project.project_members << ProjectMember.make(:user => user)
      @project.should_not be_valid
    end
  end

  describe 'callback' do

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
  end

end
