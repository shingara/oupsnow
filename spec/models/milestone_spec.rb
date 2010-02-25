require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Milestone do

  it "should have dm-sweatshop valid" do
    Milestone.make.should be_valid
  end

  describe 'validation' do
    it 'should not valid if no project_id' do
      Milestone.make_unsaved(:project => nil).should_not be_valid
    end

    it 'should not valid if no name' do
      project = make_project
      Milestone.make_unsaved(:name => '', :project => project).should_not be_valid
    end
  end

  describe 'callback' do
    before do
      @project = make_project
      @milestone = Milestone.make(:project => @project)
      @project.reload
    end
    describe '#nb_tickets_open' do
      it 'should change with ticket change' do
        @milestone.nb_tickets_open.should == 0
        new_ticket = make_ticket(:project => @milestone.project, :state => State.make(:closed => false))
        @milestone = Milestone.find(@milestone.id)
        @milestone.nb_tickets_open.should == 1
        other_ticket = make_ticket(:project => @milestone.project, :state => State.make(:closed => false))
        @milestone = Milestone.find(@milestone.id)
        @milestone.nb_tickets_open.should == 2

        make_ticket_update(new_ticket, :state_id => State.make(:closed => true).id)
        @milestone = Milestone.find(@milestone.id)
        @milestone.nb_tickets_open.should == 1
      end
    end
    describe '#nb_tickets_closed' do
      it 'should change with ticket change' do
        @milestone.nb_tickets_closed.should == 0
        new_ticket = make_ticket(:project => @milestone.project,
                                 :state => State.make(:closed => true))
        @milestone = Milestone.find(@milestone.id)
        @milestone.nb_tickets_closed.should == 1
        other_ticket = make_ticket(:project => @milestone.project,
                                   :state => State.make(:closed => true))
        @milestone = Milestone.find(@milestone.id)
        @milestone.nb_tickets_closed.should == 2

        make_ticket_update(new_ticket, :state_id => State.make(:closed => false).id)
        @milestone = Milestone.find(@milestone.id)
        @milestone.nb_tickets_closed.should == 1
      end
    end

    describe '#nb_tickets' do
      it 'should change with ticket change' do
        @milestone.nb_tickets.should == 0
        new_ticket = make_ticket(:project => @milestone.project,
                                 :state => State.make(:closed => true))
        @milestone = Milestone.find(@milestone.id)
        @milestone.nb_tickets.should == 1
        other_ticket = make_ticket(:project => @milestone.project,
                                   :state => State.make(:closed => false))
        @milestone = Milestone.find(@milestone.id)
        @milestone.nb_tickets.should == 2
      end
    end

    describe '#check_current_milestone' do
      it 'should update current_milestone of project' do
        @project.current_milestone.should == @milestone
        @project.current_milestone_name.should == @milestone.name
      end
    end

    describe '#current=' do
      it 'should define this milestone like current on his project if true' do
        milestone = Milestone.make(:project => @project)
        milestone_2 = Milestone.make(:project => @project)
        @project.current_milestone.should_not == milestone
        milestone.current = true
        milestone.save
        @project = Project.find(@project.id)
        @project.current_milestone.id.should == milestone.id
        @project.current_milestone_name.should == milestone.name
        milestone_2.current = '1'
        milestone.save
        @project = Project.find(@project.id)
        @project.current_milestone.id.should == milestone_2.id
        @project.current_milestone_name.should == milestone_2.name
      end
    end
  end

end
