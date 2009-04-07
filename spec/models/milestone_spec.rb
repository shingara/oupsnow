require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Milestone do

  it "should have dm-sweatshop valid" do
    Milestone.make.should be_valid
  end

end
