require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Function do

  it "should have dm-sweatshop valid" do
    Function.make.should be_valid
  end

end
