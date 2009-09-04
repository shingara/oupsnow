require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Priority do

  it "should have factory valid" do
    Priority.make.should be_valid
  end

  describe 'validation' do

    it 'should not valid if no name' do
      Priority.make_unsaved(:name => '').should_not be_valid
    end

    it 'should not valid if name already use' do
      name = Priority.make.name
      Priority.make_unsaved(:name => name).should_not be_valid
    end
  end

end
