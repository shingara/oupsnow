require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe "resource(:members)" do
  before :each do
    Project.destroy_all
    Function.destroy_all
    create_default_admin
    make_project
    Function.make(:name => 'Developper')
  end

  describe "GET" do

    describe 'with user admin' do
      before(:each) do
        login_admin
        @response = request(url(:project_settings_project_members, Project.first))
      end
      
      it "responds successfully" do
        @response.should be_successful
      end

      it "contains a list of members" do
        @response.should have_xpath("//table/tbody/tr/td")
      end
    end

    describe 'with user logged' do
      before :each do
        login
        @response = request(url(:project_settings_project_members, Project.first))
      end

      it 'should render 401' do
        @response.status.should == 401
      end
    end
    
  end
  
  describe "a successful POST" do

    describe 'with logged admin' do
      it 'should create member' do
        login_admin
        need_developper_function
        u_admin = User.first(:conditions => {:login => 'admin'})
        project = u_admin.projects.first
        pms = Project.find(project.id).project_members.size
        @response = request(url(:project_settings_project_members, project), :method => "POST", 
                            :params => { :project_member => { :user_id => User.make.id }})
        @response.should redirect_to(url(:project_settings_project_members, project), :message => {:notice => "Email send to shingara.gmail"})
        (pms + 1).should == Project.find(project.id).project_members.size
      end
    end
    
  end
end

describe "resource(:members, :new)" do
  before(:each) do
    login_admin
    @response = request(resource(Project.first, :settings, :project_members, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@member)" do

  before :each do
    Project.destroy_all
    Function.destroy_all
    create_default_admin
    make_project
    Function.make(:name => 'Developper')
  end
  
  describe "GET" do
    before(:each) do
      login_admin
      @response = request(resource(Project.first, :settings, Project.first.project_members.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
end

describe 'update_all' do
  describe 'like an admin' do
    def made_request(member_function)
      @response = request(resource(@project,
                                   :settings,
                                   :project_members,
                                   :update_all),
                            :method => "PUT",
                            :params => {'member_function' => member_function})
    end

    before(:each) do
      login_admin
      @project = Project.first
      @project.project_members.should_not have(3).items
      @project.project_members << ProjectMember.make
      @project.project_members << ProjectMember.new(:user => User.find_by_login('admin'),
                                                    :function => Function.make)
      @project.save!
      @project.project_members.should have(3).items
    end

    it 'should redirect to project setting member without message because no change in update' do
      member_function = {}
      @project.project_members.each do |member|
        member_function[member.id] = member.function_id
      end
      made_request(member_function)
      @response.should redirect(url(:project_settings_project_members, @project),
                                :message => {:notice => ""})
    end

    it 'should redirect to project setting member with message no change yourself because you change just youself' do
      member_function = {}
      @project.project_members.each do |member|
        if member.id != User.find_by_login('admin').id
          member_function[member.id] = member.function_id
        else
          member_function[member.id] = Function.make.id 
        end
      end
      made_request(member_function)
      @response.should redirect(url(:project_settings_project_members, @project),
                                :message => {:notice => ""})
    end
  end
end
