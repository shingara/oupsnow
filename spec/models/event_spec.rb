require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Event do

  it "should be valid" do
    Event.make.should be_valid
  end

  describe 'update event_title' do
    it 'should update event_title' do
      project = make_project
      event = Event.new(:user => User.make,
                        :eventable => project,
                        :event_type => :created,
                        :project => project)
      event.event_title.should be_blank
      event.save!
      event.event_title.should == event.eventable.title
    end
  end

end
