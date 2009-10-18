require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe TicketUpdate do

  describe '#add_update' do
    it 'should add properties if old and new different' do
      tu = TicketUpdate.new
      tu.add_update(:user, 'shingara', 'cyril')
      tu.properties_update.should == [[:user, 'shingara', 'cyril']]
    end

    it 'should not add properties if old and new same' do
      tu = TicketUpdate.new
      tu.add_update(:user, 'shingara', 'shingara')
      tu.properties_update.should be_empty
    end
  end

  describe '#add_tag_update' do
    it 'should add tag properties if old difference of new' do
      tu = TicketUpdate.new
      tu.add_tag_update('jour,nuit', 'jour,nuit,ok')
      tu.properties_update.should == [[:tag_list, 'jour,nuit', 'jour,nuit,ok']]
    end

    it 'should add tag properties if old difference of new but save in order' do
      tu = TicketUpdate.new
      tu.add_tag_update('nuit,jour', 'jour,ok,nuit')
      tu.properties_update.should == [[:tag_list, 'jour,nuit', 'jour,nuit,ok']]
    end

    it 'should add tag properties if old difference of new without withespace' do
      tu = TicketUpdate.new
      tu.add_tag_update(' nuit , jour ', ' jour , nuit , ok ')
      tu.properties_update.should == [[:tag_list, 'jour,nuit', 'jour,nuit,ok']]
    end

    it 'should not add tag properties if no difference between old and new' do
      tu = TicketUpdate.new
      tu.add_tag_update('jour,nuit', 'jour,nuit')
      tu.properties_update.should be_empty
    end

    it 'should not add tag properties if no difference between old and new because not same order' do
      tu = TicketUpdate.new
      tu.add_tag_update('jour,nuit', 'nuit,jour')
      tu.properties_update.should be_empty
    end

    it 'should not add tag properties if no difference between old and new because bad order alphabetical' do
      tu = TicketUpdate.new
      tu.add_tag_update('nuit,jour', 'nuit,jour')
      tu.properties_update.should be_empty
    end

    it 'should not add tag properties if no difference between old and new because not some space between' do
      tu = TicketUpdate.new
      tu.add_tag_update('jour,nuit', '  nuit  ,   jour  ')
      tu.properties_update.should be_empty
    end
  end

end
