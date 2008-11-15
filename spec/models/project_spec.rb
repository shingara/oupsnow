require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Project do

  it "should have valid" do
    Factory.build(:project, :name => 'new_project').should be_valid
  end

  it "should invalid without name" do
    project = Factory.build(:project, :name => nil)
    project.should_not be_valid
    project.errors.on(:name).first.should == "Name must not be blank"
  end

  it "should have name uniq" do
    project_1 = Factory(:project)
    project_2 = Factory.build(:project)
    project_2.should_not be_valid
    project_2.errors.length.should == 1
    project_2.errors.on(:name).first.should == "Name is already taken"
  end

end
