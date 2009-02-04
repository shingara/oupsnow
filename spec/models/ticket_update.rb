require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe TicketUpdate do

  describe '#create' do
    it 'should generate an event' do
      create_default_admin
      lambda do
        t = TicketUpdate.new(:member_create_id => Project.first.members.first.user_id,
                            :description => 'An update')
        t.ticket = Project.first.tickets.first
        t.save
        t.write_event
      end.should change(Event, :count)
    end
  end

end
