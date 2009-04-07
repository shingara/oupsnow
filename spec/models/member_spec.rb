require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Member do

  it "should have dm-sweatshop valid" do
    Member.make.should be_valid
  end

end
