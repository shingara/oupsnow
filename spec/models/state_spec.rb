require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe State do

  it "should be valid" do
    State.make.should be_valid
  end

  describe 'validations' do

    it 'should not valid without name' do
      State.make_unsaved({:name => ''}).should_not be_valid
    end

    it 'should have unique name' do
      w = /\w+/.gen
      State.make_unsaved({:name => w}).save.should be_true
      State.make_unsaved({:name => w}).should_not be_valid
    end
  end

end
