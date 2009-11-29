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
      @milestone = Milestone.make
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
  end

end
