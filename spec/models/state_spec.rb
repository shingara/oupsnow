require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe State do

  describe 'validations' do

    it "should be valid" do
      Factory(:state).should be_valid
    end

    it 'should not valid without name' do
      Factory.build(:state, {:name => ''}).should_not be_valid
    end

    it 'should have unique name' do
      w = /\w+/.gen
      Factory.build(:state, {:name => w}).save.should be_true
      Factory.build(:state, {:name => w}).should_not be_valid
    end
  end

  describe 'self#update_all_closed' do
    before do
      @closed = Factory(:state, :closed => true)
      @opened = Factory(:state, :closed => false)
    end
    it 'should change closed status of state' do
      State.update_all_closed([@closed.id, @opened.id])
      State.find(@opened.id).closed.should be_true
    end

    it 'no change closed status because no needed' do
      State.update_all_closed([@closed.id])
      State.find(@opened.id).closed.should be_false
    end

    it 'can change several closed status' do
      State.update_all_closed([@opened.id])
      State.find(@opened.id).closed.should be_true
      State.find(@closed.id).closed.should be_false
    end
  end

end
