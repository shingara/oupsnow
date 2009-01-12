require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Ticket do

  TAG_LIST = 'bar,foo,ko,ok'

  before :all do
    Project.gen
    State.gen(:name => 'new')
  end

  it "should be valid" do
    Ticket.gen(:project_id => Project.first.id).should be_valid
  end

  describe '#generate_update' do

    def generate_ticket(ticket)
      @t = Ticket.gen(:project_id => Project.first.id,
                     :tag_list => TAG_LIST)
      @old_description = @t.description
      @old_title = @t.title
      @t.generate_update(@t.attributes.merge(ticket))
      @t.reload
    end

    describe 'no change' do
      before(:each) do
        generate_ticket({:description => '', :tag_list => TAG_LIST})
      end

      it 'should not create ticket_update if no change' do
        @t.ticket_updates.should_not have(1).items
      end
    end

    describe 'change only description' do
      before(:each) do
        generate_ticket({:description => 'new description', 
                        :tag_list => TAG_LIST})
      end

      it 'should not update ticket' do
        @t.description.should_not == 'new description'
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
                        :tag_list => TAG_LIST})
      end

      it 'should update title ticket' do
        @t.title.should == 'new title'
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
                        :tag_list => TAG_LIST})
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
                        :tag_list => TAG_LIST})
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
        @t.ticket_updates[0].properties_update.should == [[:title, @old_title, 'new title'],[:state_id, State.first(:name => 'new').id, State.first(:name => 'check').id]]
      end
    end

    describe 'about tag change' do
      it 'should not see change if only space' do
        generate_ticket({:tag_list => TAG_LIST.split(',').map{|t| t + ' '}.join(','), :description => ''})
        @t.ticket_updates.should be_empty
      end

      it 'should no see change if order change' do
        generate_ticket({:tag_list => TAG_LIST.split(',').map{|t| t + ' '}.reverse.join(','), :description => ''})
        @t.ticket_updates.should be_empty
      end
    end
    
  end


end
