require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Ticket do

  TAG_LIST = 'bar,foo,ko,ok'

  def valid_ticket
    Ticket.gen(:project_id => Project.first.id,
              :member_create_id => Project.first.members.first.user_id)
  end

  it "should be valid" do
    Ticket.make.should be_valid
  end

  describe 'validation' do

    it 'should not be valid if no same project between ticket and milestone' do
      project = make_project
      project_2 = make_project
      milestone = Milestone.make(:project => project_2)
      Ticket.make_unsaved(:project => project,
                  :milestone => milestone).should_not be_valid
    end

    it 'shoud not have same num in same project' do
      project = make_project
      t1 = Ticket.make(:project => project,
                  :num => 1)
      t = Ticket.make_unsaved(:project => project,
                          :num => 1)
      t.should_not be_valid
    end
  end

  describe '#create' do
    it 'should generate Event of ticket creation' do
      lambda do
        t = Ticket.make
        t.write_create_event
      end.should change(Event, :count)
    end
  end

  describe 'Ticket#paginate_by_search' do

    before :each  do
      @state = State.make
      @state_2 = State.make
      @first_tag = /\w+/.generate
      @second_tag = /\w+/.generate
      @third_tag = /\w+/.generate
      @first_ticket = Ticket.make(:state => @state,
                                 :tag_list => @first_tag)

      @second_ticket = Ticket.make(:state => @state,
                                   :title => 'foo',
                                 :tag_list => "#{@second_tag},#{@third_tag}")
      @third_ticket = Ticket.make(:state => @state_2,
                                 :tag_list => @first_tag)
      @four_ticket = Ticket.make(:state => @state_2,
                                 :tag_list => @second_tag)
      second_project = @second_ticket.project
      second_user = User.make
      second_project.project_members.build(:user => second_user,
                                          :function => Function.make)
      second_project.save!
      make_ticket_update(@second_ticket, {:description => '',
                         :state => @state,
                         :tag_list => "#{@second_tag},#{@third_tag}",
                         :user_assigned_id => second_user.id})

      third_project = @third_ticket.project
      third_user = User.make
      third_project.project_members.build(:user => third_user,
                                          :function => Function.make)
      third_project.save!
      make_ticket_update(@third_ticket, {:description => '',
                         :state => @state_2,
                         :tag_list => @first_tag,
                         :user_assigned_id => third_user.id})

      four_project = @four_ticket.project
      user_four = User.make
      four_project.project_members.build(:user => user_four,
                                          :function => Function.make)
      four_project.save!
      make_ticket_update(@four_ticket, {:description => 'bar',
                         :state => @state_2,
                         :tag_list => @second_tag,
                         :user_assigned_id => user_four.id})
      @second_ticket = Ticket.find(@second_ticket.id)
      @four_ticket = Ticket.find(@four_ticket.id)
      @third_ticket = Ticket.find(@third_ticket.id)
      @ticket_with_first_state = [@first_ticket,@second_ticket]
      @ticket_with_second_state = [@third_ticket, @four_ticket]
    end

    it 'should return all if no q value' do
      Ticket.paginate_by_search('',
                                :page => 1,
                                :per_page => (Ticket.count + 1)
                               ).size.should == Ticket.count
    end

    it 'should return all ticket with state information' do
      Ticket.paginate_by_search("state:#{@state.name}",
                                :page => 1,
                                  :per_page => 10).sort_by(&:title).should == @ticket_with_first_state.sort_by(&:title)
    end

    it 'should return no ticket if no ticket with state' do
      Ticket.paginate_by_search("state:a_bad_state",
                                :page => 1,
                                :per_page => 10).should be_empty
    end

    it 'should return all ticket with last state define in query if several state' do
      Ticket.paginate_by_search("state:#{@state.name} state:#{@state_2.name}",
                                :page => 1,
                                :per_page => 10).sort_by(&:title).should == @ticket_with_second_state.sort_by(&:title)
    end

    it 'should return all ticket with tag define by tagged:xxx in query' do
      Ticket.paginate_by_search("tagged:#{@first_tag}",
                                :page => 1,
                                  :per_page => 10).sort_by(&:title).should == [@first_ticket, @third_ticket].sort_by(&:title)
    end

    it 'should return no ticket with tag define by tagged:xxx in query but no ticket tagged with that' do
      Ticket.paginate_by_search("tagged:a_very_bad_tag",
                                :page => 1,
                                  :per_page => 10).should be_empty
    end

    it 'should return all ticket with all tags define by tagged:xxx in query' do
      Ticket.paginate_by_search("tagged:#{@second_tag} tagged:#{@third_tag}",
                                :page => 1,
                                  :per_page => 10).sort_by(&:title).should == [@second_ticket, @four_ticket].sort_by(&:title)
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

    it 'should search in keywords if no prefix in search' do
      Ticket.paginate_by_search("#{@first_tag}",
                                      :page => 1,
                                      :per_page => 10).should == [@first_ticket, @third_ticket]
     Ticket.paginate_by_search("foo #{@third_tag}",
                                      :page => 1,
                                      :per_page => 10).should == [@second_ticket]

     Ticket.paginate_by_search("bar #{@second_tag}",
                                      :page => 1,
                                      :per_page => 10).should == [@four_ticket]

      Ticket.paginate_by_search("#{@first_tag} #{@third_tag}",
                                      :page => 1,
                                      :per_page => 10).should be_empty
    end

    it 'should order by responsabile' do
      Ticket.paginate_by_search('',:order => 'user_assigned_name',
                                :page => 1,
                                :per_page => 10).should == (@ticket_with_first_state | @ticket_with_second_state).sort_by(&:user_assigned_name)
      Ticket.paginate_by_search('',:order => 'user_assigned_name asc',
                                :page => 1,
                                :per_page => 10).should == (@ticket_with_first_state | @ticket_with_second_state).sort_by(&:user_assigned_name)

      Ticket.paginate_by_search('',:order => 'user_assigned_name desc',
                                :page => 1,
                                :per_page => 10).should == (@ticket_with_first_state | @ticket_with_second_state).sort_by(&:user_assigned_name).reverse
    end

    it 'should order by state_name' do
      Ticket.paginate_by_search(@first_tag,:order => 'state_name',
                                :page => 1,
                                :per_page => 10).should == [@first_ticket, @third_ticket].sort_by(&:state_name)
      Ticket.paginate_by_search(@first_tag,:order => 'state_name asc',
                                :page => 1,
                                :per_page => 10).should == [@first_ticket, @third_ticket].sort_by(&:state_name)

      Ticket.paginate_by_search(@first_tag,:order => 'state_name desc',
                                :page => 1,
                                :per_page => 10).should ==[@first_ticket, @third_ticket].sort_by(&:state_name).reverse
    end
  end

  describe '#generate_update' do

    def generate_ticket(ticket)
      @t = Ticket.make(:project => Project.first || make_project,
                       :tag_list => TAG_LIST,
                       :user_creator => Project.first.project_members.first.user)
      @old_description = @t.description
      @t.generate_update(@t.attributes.merge(ticket),
                         Project.first.project_members.first.user)
      @t = Ticket.find(@t.id)
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

    describe 'change only description' do
      before(:each) do
        generate_ticket({:description => 'yahoo',
                        'tag_list' => TAG_LIST})
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

    end

    describe 'change state with description' do
      before(:each) do
        state = State.first(:conditions => {:name => 'check'}) || State.make(:name => 'check')
        generate_ticket({:description => 'yahoo',
                        :state_id => state.id,
                        :tag_list => TAG_LIST})
      end

      it 'should update state of ticket' do
        @t.state_id.should == State.first({:name => 'check'})._id
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

      it 'should have properties_update with state change' do
        @t.ticket_updates[0].properties_update.should be_include([:state,
                                                                 'new',
                                                                 'check'])
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
        @ticket = Ticket.make
        @ticket.write_create_event
        @ticket.generate_update({:description => 'new title'}, User.first)
      end

      it 'should destroy ticket' do
        lambda do
          @ticket.destroy
        end.should change(Ticket, :count).by(-1)
      end

      it 'should destroy all Event about this ticket' do
        lambda do
          @ticket.destroy
        end.should change(Event, :count).by(-2)
        # there are 2 events. One after creation one after update
      end

    end

  end

  describe 'self#get_by_permalink' do
    before do
      @pr = make_project
      @t1 = Ticket.make(:project => @pr)
      @t2 = Ticket.make(:project => @pr)
    end

    it 'should get ticket with this project_id and permlink in string' do
      Ticket.get_by_permalink(@pr._id.to_s, @t1.num.to_s).should == @t1
    end

    it 'should get ticket with this project_id and permalink' do
      Ticket.get_by_permalink(@pr._id, @t1.num).should == @t1
    end

    it 'should return nil because no ticket with this bad permalink but good project_id' do
      Ticket.get_by_permalink(@pr._id, (@t2.num + 10)).should be_nil
    end

    it 'should return nil because no ticket with existing permalink but bad project_id' do
      Ticket.get_by_permalink(@t1._id, @t1.num).should be_nil
    end
    it 'should return nil because no ticket with bad permalink and project_id' do
      Ticket.get_by_permalink(@t1._id, (@t2.num + 10)).should be_nil
    end
  end

  describe '#get_update' do
    it 'should get ticket_update with num if exist' do
      @ticket = make_ticket
      ticket_update = make_ticket_update(@ticket)
      ticket_update2 = make_ticket_update(@ticket)
      ticket_update3 = make_ticket_update(@ticket)
      Ticket.find(@ticket.id).get_update(2).should == ticket_update2
    end

    it 'should get nil no of ticket_update with this num' do
      @ticket = make_ticket
      ticket_update = make_ticket_update(@ticket)
      ticket_update2 = make_ticket_update(@ticket)
      ticket_update3 = make_ticket_update(@ticket)
      Ticket.find(@ticket.id).get_update(4).should be_nil
    end
  end

  describe 'self#new_by_params' do
    before do
      @state = State.make
      @project = make_project
      @user = User.make
    end

    def new_by_params(args={})
      Ticket.new_by_params({:title => 'new issue',
                           :description => "it's a big issue",
                           :state_id => @state._id}.merge(args),
                           @project,
                           @user)
    end

    it 'should create ticket complete' do
      ticket = new_by_params
      ticket.description.should == "it's a big issue"
      ticket.state_id.should == @state._id
      ticket.title.should == 'new issue'
      ticket.project_id = @project._id
      ticket.user_creator = @user
      ticket.should be_new_record
    end

    it 'should create ticket complete with no data' do
      ticket = new_by_params
      ticket.description.should == "it's a big issue"
      ticket.state_id.should == @state._id
      ticket.title.should == 'new issue'
      ticket.project_id = @project._id
      ticket.user_creator = @user
      ticket.should be_new_record
    end

    it 'should not define Milestone if params[:milestone_id] is empty' do
      ticket = new_by_params(:milestone_id => '')
      ticket.milestone_id.should be_nil
    end
  end

  describe 'Callback' do
    describe '#update_project_tag_count' do
      it 'should update project_tag_counts after save' do
        @project = make_project
        @project.tag_counts.should be_empty
        make_ticket(:project => @project, :tag_list => 'foo,bar')
        @project = Project.find(@project._id)
        @project.tag_counts.should == {'foo' => 1, 'bar' => 1}
      end
    end

    describe '#update_state_name' do
      it 'should update state_name after each state change' do
        @ticket = make_ticket
        @ticket.state_name.should == 'new'
        new_state = State.make
        @ticket.state_id = new_state.id
        @ticket.save!
        @ticket = Ticket.find(@ticket.id)
        @ticket.state_name.should == new_state.name
        new_state = State.make
        @ticket.state = new_state
        @ticket.save!
        @ticket = Ticket.find(@ticket.id)
        @ticket.state_name.should == new_state.name
      end
    end

    describe '#update_milestone_name' do
      it 'should update milestone_name if milestone define' do
        @ticket = make_ticket
        @ticket.milestone_name.should_not be_blank
        new_milestone = Milestone.make(:project => @ticket.project)
        @ticket.milestone = new_milestone
        @ticket.save!
        @ticket.milestone_name.should == new_milestone.name

        @ticket = Ticket.find(@ticket.id)
        @ticket.milestone_id = nil
        @ticket.save!
        @ticket.milestone_name.should be_blank

        @ticket = Ticket.find(@ticket.id)
        other_milestone = Milestone.make(:project => @ticket.project)
        @ticket.milestone_id = other_milestone.id
        @ticket.save!
        @ticket.milestone_name.should == other_milestone.name

        @ticket = Ticket.find(@ticket.id)
        @ticket.milestone = nil
        @ticket.save!
        @ticket.milestone_name.should be_blank
      end
    end

    describe '#update_user_assigned_name' do
      it 'should update user_assigned_name if user_assigned define' do
        @ticket = make_ticket
        @ticket.user_assigned_name.should be_blank
        new_user = User.make
        @ticket.project.project_members << ProjectMember.make(:user => new_user,
                                                  :function => Function.make)
        @ticket.project.save!
        @ticket.user_assigned = new_user
        @ticket.save!
        @ticket.user_assigned_name.should == new_user.login

        @ticket = Ticket.find(@ticket.id)
        @ticket.user_assigned_id = nil
        @ticket.save!
        @ticket.user_assigned_name.should be_blank

        @ticket = Ticket.find(@ticket.id)
        other_user = User.make
        @ticket.project.project_members << ProjectMember.make(:user => other_user,
                                                  :function => Function.make)
        @ticket.project.save!
        @ticket.user_assigned_id = other_user.id
        @ticket.save!
        @ticket.user_assigned_name.should == other_user.login

        @ticket = Ticket.find(@ticket.id)
        @ticket.user_assigned = nil
        @ticket.save!
        @ticket.user_assigned_name.should be_blank
      end
    end

    describe '#update _keywords' do
      it 'should update _keywords before save' do
        @ticket = make_ticket
        @ticket._keywords.should_not be_empty
        @ticket._keywords.uniq!.should be_nil
        keys = [@ticket.title.split(/\W+/),
          @ticket.description.split(/\W+/),
          @ticket.tag_list.split(',')].flatten.uniq.sort
        @ticket._keywords.should == keys
        desc = make_ticket_update(@ticket, :tag_list => @ticket.tag_list).description
        @ticket._keywords.should == (keys + desc.split(/\W+/)).flatten.uniq.sort
      end
    end
  end

end
