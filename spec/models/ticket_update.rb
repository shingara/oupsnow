require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe TicketUpdate do

  describe '#create' do
    it 'should generate an event' do
      create_default_admin
      lambda do
        TicketUpdate.create(:member_create_id => Project.first.members.first.user_id,
                            :ticket_id => Project.first.tickets.first,
                            :description => 'An update')
      end.should change(Event, :count)
    end
  end

end
