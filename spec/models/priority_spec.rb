require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Priority do

  it "should have dm-sweatshop valid" do
    Priority.make.should be_valid
  end

end
