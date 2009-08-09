require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Ticket do

  TAG_LIST = 'bar,foo,ko,ok'

  before :all do
    create_default_admin
  end

  def valid_ticket
    Ticket.gen(:project_id => Project.first.id,
              :member_create_id => Project.first.members.first.user_id)
  end

  it "should be valid" do
    valid_ticket.should be_valid
  end

  it 'should have good dm-sweatshop' do
    Ticket.gen.should be_valid
  end

  it 'should not be valid if no same project between ticket and milestone' do
    project = Project.gen!
    project_2 = Project.gen!
    milestone = Milestone.gen(:project_id => project_2.id)
    Ticket.make(:project_id => project.id,
                  :milestone_id => milestone.id).should_not be_valid
  end

  describe '#create' do
    it 'should generate Event of ticket creation' do
      lambda do
        t = valid_ticket
        t.write_create_event
      end.should change(Event, :count)
    end
  end

  describe 'Ticket#paginate_by_search' do

    before :each  do
      @state = State.gen!
      @state_2 = State.gen!
      @first_tag = /\w+/.generate
      @second_tag = /\w+/.generate
      @third_tag = /\w+/.generate
      @first_ticket = Ticket.gen!(:state_id => @state.id,
                                 :tag_list => @first_tag)
      @second_ticket = Ticket.gen!(:state_id => @state.id,
                                 :tag_list => "#{@second_tag},#{@third_tag}")
      @third_ticket = Ticket.gen!(:state_id => @state_2.id,
                                 :tag_list => @first_tag)
      @four_ticket = Ticket.gen!(:state_id => @state_2.id,
                                 :tag_list => @second_tag)
      @ticket_with_first_state = [@first_ticket,@second_ticket]
      @ticket_with_second_state = [@third_ticket, @four_ticket]
    end

    it 'should return all if no q value' do
      Ticket.paginate_by_search('', :page => 1, :per_page => (Ticket.count + 1)).size.should == Ticket.count
    end

    it 'should return all ticket with state information' do
      Ticket.paginate_by_search("state:#{@state.name}", 
                                :page => 1, 
                                  :per_page => 10).should == @ticket_with_first_state
    end

    it 'should return no ticket if no ticket with state' do
      Ticket.paginate_by_search("state:a_bad_state", 
                                :page => 1, 
                                :per_page => 10).should be_empty
    end

    it 'should return all ticket with last state define in query if several state' do
      Ticket.paginate_by_search("state:#{@state.name} state:#{@state_2.name}", 
                                :page => 1, 
                                  :per_page => 10).should == @ticket_with_second_state
    end

    it 'should return all ticket with tag define by tagged:xxx in query' do
      Ticket.paginate_by_search("tagged:#{@first_tag}",
                                :page => 1,
                                  :per_page => 10).should == [@first_ticket, @third_ticket]
    end

    it 'should return no ticket with tag define by tagged:xxx in query but no ticket tagged with that' do
      Ticket.paginate_by_search("tagged:a_very_bad_tag",
                                :page => 1,
                                  :per_page => 10).should be_empty
    end

    it 'should return all ticket with all tags define by tagged:xxx in query' do
      Ticket.paginate_by_search("tagged:#{@second_tag} tagged:#{@third_tag}",
                                :page => 1,
                                  :per_page => 10).should == [@second_ticket]
    end

    it 'should return all ticket with all tags define by tagged:xxx and state:xxx in query' do
      Ticket.paginate_by_search("tagged:#{@second_tag} tagged:#{@third_tag} state:#{@state.name}",
                                :page => 1,
                                  :per_page => 10).should == [@second_ticket]
    end

    it 'should return no ticket with all tags define by tagged:xxx and state:xxx in query because no ticket have all tag_name and this state' do
      Ticket.paginate_by_search("tagged:#{@second_tag} tagged:#{@third_tag} state:a bad_state",
                                :page => 1,
                                  :per_page => 10).should be_empty
    end
  end

  describe '#generate_update' do

    def generate_ticket(ticket)
      @t = Ticket.gen(:project_id => Project.first.id,
                     'tag_list' => TAG_LIST,
                     :member_create_id => Project.first.members.first.user_id)
      @old_title = @t.title
      @old_description = @t.description
      @t.generate_update(@t.attributes.merge(ticket), Project.first.members.first.user)
      @t.reload
    end

    describe 'no change' do
      before(:each) do
        generate_ticket({:description => '', 'tag_list' => TAG_LIST})
      end

      it 'should not create ticket_update if no change' do
        @t.ticket_updates.should_not have(1).items
      end
    end

    describe 'change only description' do
      before(:each) do
        generate_ticket({:description => 'new description', 
                        'tag_list' => TAG_LIST})
      end

      it 'should not update ticket' do
        @t.description.should_not == 'new description'
        @t.description.should == @old_description
      end

      it 'should generate ticket update' do
        @t.ticket_updates.should have(1).items
      end

      it 'should generate ticket update with some description' do
        @t.ticket_updates[0].description.should == 'new description'
      end

      it 'should not have properties_update' do
        @t.ticket_updates[0].properties_update.should be_empty
      end
    end

    describe 'change only title' do
      before(:each) do
        generate_ticket({:title => 'new title', :description => '', 
                        'tag_list' => TAG_LIST})
      end

      it 'should update title ticket' do
        @t.title.should == 'new title'
      end

      it 'should not change description of ticket' do
        @t.description.should == @old_description
      end

      it 'should generate ticket update' do
        @t.ticket_updates.should have(1).items
      end

      it 'should generate ticket update without description' do
        @t.ticket_updates[0].description.should be_nil
      end

      it 'should have properties_update about title' do
        @t.ticket_updates[0].properties_update.should == [[:title, @old_title, 'new title']]
      end
    end

    describe 'change title with description' do
      before(:each) do
        generate_ticket({:title => 'new title', 
                        :description => 'yahoo',
                        'tag_list' => TAG_LIST})
      end

      it 'should update title ticket' do
        @t.title.should == 'new title'
      end

      it 'should not update description ticket' do
        @t.description.should_not == 'yahoo'
      end

      it 'should generate ticket update' do
        @t.ticket_updates.should have(1).items
      end

      it 'should generate ticket update with description' do
        @t.ticket_updates[0].description.should == 'yahoo'
      end

      it 'should have properties_update about title' do
        @t.ticket_updates[0].properties_update.should == [[:title, @old_title, 'new title']]
      end
    end

    describe 'change title, state with description' do
      before(:each) do
        State.all(:name => 'check').each{|s| s.destroy}
        generate_ticket({:title => 'new title', 
                        :description => 'yahoo', 
                        :state_id => State.gen(:name => 'check').id,
                        'tag_list' => TAG_LIST})
      end

      it 'should update title ticket' do
        @t.title.should == 'new title'
      end

      it 'should update state of ticket' do
        @t.state_id.should == State.first(:name => 'check').id
      end

      it 'should not update description ticket' do
        @t.description.should_not == 'yahoo'
      end

      it 'should generate ticket update' do
        @t.ticket_updates.should have(1).items
      end

      it 'should generate ticket update with description' do
        @t.ticket_updates[0].description.should == 'yahoo'
      end

      it 'should have properties_update about title' do
        @t.ticket_updates[0].properties_update.should be_include([:title, @old_title, 'new title'])
         @t.ticket_updates[0].properties_update.should be_include([:state_id, State.first(:name => 'new').id, State.first(:name => 'check').id])
      end
    end

    describe 'about tag change' do
      it 'should not see change if only space' do
        generate_ticket({'tag_list' => TAG_LIST.split(',').map{|t| t + ' '}.join(','), :description => ''})
        @t.ticket_updates.should be_empty
      end

      it 'should no see change if order change' do
        generate_ticket({'tag_list' => TAG_LIST.split(',').map{|t| t + ' '}.reverse.join(','), :description => ''})
        @t.ticket_updates.should be_empty
      end
    end

    describe 'destroy' do
      before :each do
        @ticket = Ticket.gen
        @ticket.write_create_event
        @ticket.generate_update({:title => 'new title'}, User.first)
      end

      it 'should destroy ticket' do
        lambda do
          @ticket.destroy
        end.should change(Ticket, :count).by(-1)
      end

      it 'should destroy all Event about this ticket' do
        lambda do
          @ticket.destroy
        end.should change(Event, :count).by(-1)
      end

      it 'should destroy all TicketUpdate about this ticket' do
        lambda do
          @ticket.destroy
        end.should change(TicketUpdate, :count)
      end

      it 'should destroy all tagging about this ticket' do
        lambda do
          @ticket.destroy
        end.should change(Tagging, :count)
      end
    end
    
  end


end
