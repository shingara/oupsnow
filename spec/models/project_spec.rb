require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Project do

  it "should be valid" do
    Project.gen!.should be_valid
  end

  it "should invalid without name" do
    project = Project.gen(:name => nil)
    project.should_not be_valid
    project.errors.on(:name).first.should == "Name must not be blank"
  end

  it "should have name uniq" do
    project_1 = Project.gen!
    project_2 = Project.gen!(:name => project_1.name)
    project_2.should_not be_valid
    project_2.errors.length.should == 1
    project_2.errors.on(:name).first.should == "Name is already taken"
  end

  it "should not valid project without member" do
    Project.gen!(:members => []).should_not be_valid
  end

  it "should not valid project without admin member" do
    Project.gen!(:members => [:function => (Function.first(:project_admin => false) ? Function.first(:project_admin => false) : Function.gen),
    :user => (User.first(:login => 'admin') ? User.first(:login => 'admin') : User.gen(:admin))]).should_not be_valid
  end

  describe 'destroy project' do

    before :each do
      create_default_user
      @project = Project.gen
      create_ticket(:project_id => @project.id)
      @project.milestones << Milestone.create
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
      project.should be_has_member(user)
    end

    it 'should return false if has not this member' do
      user = User.gen
      project = Project.gen
      project.should_not be_has_member(user)
    end
  end

end
