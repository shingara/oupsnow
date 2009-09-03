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

    it 'should destroy all Member of this project' do
      lambda do
        @project.destroy
      end.should change(Member, :count)
      Member.first(:project_id => @project.id).should be_nil
    end


    it 'should destroy all Ticket related to this project' do
      @project.tickets.should_not be_empty
      lambda do
        @project.destroy
      end.should change(Ticket, :count).by(-1)
      Ticket.first(:project_id => @project.id).should be_nil
    end

    it 'should destroy all Event related to this project' do
      @project.events.should_not be_empty
      lambda do
        @project.destroy
      end.should change(Event, :count)
      Event.first(:project_id => @project.id).should be_nil
    end

    it 'should destroy all Milestone related to this project' do
      @project.milestones.should_not be_empty
      lambda do
        @project.destroy
      end.should change(Milestone, :count)
      Milestone.first(:project_id => @project.id).should be_nil
    end
  end

  describe '#has_member?' do
    it 'should return true if has member' do
      user = User.gen
      project = Project.gen
      project.add_member(user, Function.first)
      project.has_member?(user).should be_true
    end

    it 'should return false if has not this member' do
      user = User.gen
      project = Project.gen
      project.has_member?(user).should_not be_true
    end
  end

end
