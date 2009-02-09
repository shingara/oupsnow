require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Project do

  it "should be valid" do
    Project.gen!.should be_valid
  end

  it "should invalid without name" do
    project = Project.gen(:name => nil)
    project.should_not be_valid
    project.errors.on(:name).first.should == "Name must not be blank"
  end

  it "should have name uniq" do
    project_1 = Project.gen!
    project_2 = Project.gen!(:name => project_1.name)
    project_2.should_not be_valid
    project_2.errors.length.should == 1
    project_2.errors.on(:name).first.should == "Name is already taken"
  end

  it "should not valid project without member" do
    Project.gen!(:members => []).should_not be_valid
  end

  it "should not valid project without admin member" do
    Project.gen!(:members => [:function => (Function.first(:project_admin => false) ? Function.first(:project_admin => false) : Function.gen),
    :user => (User.first(:login => 'admin') ? User.first(:login => 'admin') : User.gen(:admin))]).should_not be_valid
  end

end
