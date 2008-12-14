require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Ticket do

  it "should be valid" do
    Ticket.gen.should be_valid
  end

end
