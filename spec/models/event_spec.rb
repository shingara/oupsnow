require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Event do

  it "should be valid" do
    Factory(:event).should be_valid
  end

  describe 'update event_title' do
    it 'should update event_title' do
      project = make_project
      event = Event.new(:user => Factory(:user),
                        :eventable => project,
                        :event_type => :created,
                        :project => project)
      event.event_title.should be_blank
      event.save!
      event.event_title.should == event.eventable.title
    end
  end

  describe 'update event_user' do
    it 'should update event_user' do
      project = make_project
      user = Factory(:user)
      event = Event.new(:user => user,
                        :eventable => project,
                        :event_type => :created,
                        :project => project)
      event.user_name.should be_blank
      event.save!
      event.user_name.should == user.login
    end
  end

end
