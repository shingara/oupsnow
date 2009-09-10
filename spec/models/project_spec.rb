require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Project do

  it "should be valid" do
    make_project.should be_valid
  end

  it "should invalid without name" do
    project = make_project(:name => nil)
    project.should_not be_valid
    project.errors.on(:name).should_not be_blank
  end

  it "should have name uniq" do
    project_1 = make_project
    project_2 = make_project(:name => project_1.name)
    project_2.should_not be_valid
    project_2.errors.length.should == 1
    project_2.errors.on(:name).should_not be_blank
  end

  it "should not valid project without member" do
    make_project(:project_members => []).should_not be_valid
  end

  it "should not valid project without admin member" do
    project_member = make_project_member
    project_member.project_admin = false
    make_project(:project_members => [project_member]).should_not be_valid
  end

  it 'should create an event about creation when a project is create' do
    lambda do
      make_project
    end.should change(Event, :count).by(1)
  end

  it 'should add an event about change if project is update' do
    project = make_project
    lambda do
      project.name = 'new_title'
      project.user_update = project.project_members.first.user
      project.save
    end.should change(Event, :count).by(1)
  end

  describe 'destroy project' do

    before :each do
      @project = make_project
      Ticket.make(:project => @project)
      @project.milestones << Milestone.make
    end

    it 'should destroy himself' do
      lambda do
        @project.destroy
      end.should change(Project, :count).by(-1)
    end

    it 'should destroy all Ticket related to this project' do
      @project.tickets.should_not be_empty
      lambda do
        @project.destroy
      end.should change(Ticket, :count).by(-1)
      Ticket.first(:conditions => {:project_id => @project.id}).should be_nil
    end

    it 'should destroy all Event related to this project' do
      @project.events.should_not be_empty
      lambda do
        @project.destroy
      end.should change(Event, :count)
      Event.first(:conditions => {:project_id => @project.id}).should be_nil
    end

    it 'should destroy all Milestone related to this project' do
      @project.milestones.should_not be_empty
      lambda do
        @project.destroy
      end.should change(Milestone, :count)
      Milestone.first(:conditions => {:project_id => @project.id}).should be_nil
    end
  end

  describe '#has_member?' do
    before do
      @user = User.make
      @project = make_project
      @function = Function.first || Function.make
      @project.add_member(@user, Function.first)
    end

    it 'should return true if has member' do
      @project.has_member?(@user).should be_true
    end

    it 'should return false if has not this member' do
      user = User.make
      @project.has_member?(user).should_not be_true
    end
  end

  describe 'Project#new_with_admin_member' do

    before :each do
      @function = Function.make(:admin)
      @admin_user = User.make(:admin)
      @user = User.make
    end

    it 'should create a project with user like admin function' do
      pr = Project.new_with_admin_member({'name' => 'first project',
                                    'description' => 'so cool'},
                                    @user)
      pr.should be_new
      pr.project_members.should have(1).items
      pr.project_members.first.function_id.should == Function.admin.id
      pr.project_members.first.user_id.should == @user.id
    end
  end

end
