require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Event do

  it "should be valid" do
    Event.make.should be_valid
  end

end
