require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe State do

  it "should be valid" do
    State.gen.should be_valid
  end

  it 'should not valid without name' do
    State.gen({:name => ''}).should_not be_valid
  end

  it 'should have unique name' do
    w = /\w+/.gen
    State.gen({:name => w}).save.should be_true
    State.gen({:name => w}).should_not be_valid
  end

end
