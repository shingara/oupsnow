require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Member do

  it "should have dm-sweatshop valid" do
    Member.gen.should be_valid
  end

  describe "self#change_functions" do

    it "should render true if no member_function send" do
      Member.change_functions({}).should be_true
    end

    it "should change member function" do
      project = Project.gen
      member = Member.gen!(:project_id => project.id)
      Member.change_functions({member.id => Function.admin.id}).should be_true
      member.reload.function.should == Function.admin
    end

    it "should not change member function if this no admin in project" do
      project = Project.gen
      member_admin = project.members.first
      member_admin.function.should be_project_admin
      member = Member.gen!(:project_id => project.id, :user_id => User.gen.id)
      another_member_admin = Member.gen!(:project_id => project.id, :user_id => User.gen.id)
      another_member_admin.function_id = Function.admin.id
      another_member_admin.save
      project.reload
      Function.gen! unless Function.not_admin # Need a function not admin
      Member.change_functions({
                               another_member_admin.id => Function.not_admin.id,
                               member_admin.id => Function.not_admin.id,
                               member.id => Function.not_admin.id}).should be_false
      member_admin.reload.function.should be_project_admin
      another_member_admin.reload.function.should be_project_admin
      member.reload.function.should_not be_project_admin

    end
  end

end
