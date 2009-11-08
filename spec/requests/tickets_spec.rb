require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "TicketsController" do

  include Rack::Test::Methods

  def app
    ActionController::Dispatcher.new
  end

  def i_am_logged
    request "/users/sign_in", 
      :method => :post,
      :params => {:user => {:email => 'cyril.mougel@gmail.com',
        :password => 'tintinpouet'}}
  end

  describe "GET" do
    before :each do
      create_default_user
    end
    
    it 'should access if you are logged' do
      TicketsController.any_instance.expects(:index).at_most_once
      i_am_logged
      get "/projects/#{Project.first.id}/tickets"
    end

    it 'should access if not logged' do
      TicketsController.any_instance.expects(:index).at_most_once
      get "/projects/#{Project.first.id}/tickets"
    end
  end

  describe "POST" do

    def post_request(project, options = {})
      request("/project/#{project.id}/tickets", :method => "POST", 
              :params => { :ticket => { :title => 'a new ticket',
                :state_id => (State.first || State.make).id},
                :project_id => project.id}.merge(options))
    end

    before :each do
      @project = Project.first || make_project
    end

    it 'should not post if not logged' do
      TicketsController.any_instance.expects(:create).never
      post_request(@project)
    end

    it 'should post if logged' do
      TicketsController.any_instance.expects(:create).at_most_once
      i_am_logged
      post_request(@project)
    end

  end

  describe "/new" do
    before :each do
      @project = Project.first || create_default_admin
      request("/projects/#{@project.id}/tickets/new")
    end
    it 'should not see page if not logged'
    it 'should see page if logged'

  end

#describe "resource(Project.first, @ticket, :edit_main_description)" do
  #def req
    #@response = request(resource(Project.first, Ticket.first, :edit_main_description))
  #end

  #before :each do
    #login
  #end

  #it_should_behave_like "doesn't access to anonymous"
  #it_should_behave_like "doesn't access with user logged"


  #describe 'with admin user logged' do

    #before :each do
      #login_admin
      #req
    #end

    #it "responds successfully" do
      #@response.should be_successful
    #end
  #end
#end

#describe "resource(Project.first, @ticket, :update_main_description)" do
  #def req
    #@response = request(resource(Project.first, Ticket.first, :update_main_description), 
                        #:method => "PUT", 
                        #:params => {:ticket => {:description => 'yahoo',
                                                #:title => Ticket.first.title}})
  #end

  #before :each do
    #login
  #end

  #it_should_behave_like "doesn't access to anonymous"
  #it_should_behave_like "doesn't access with user logged"


  #describe 'with admin user logged' do

    #before :each do
      #login_admin
      #req
    #end

    #it "responds successfully" do
      #@response.should redirect_to(resource(Project.first, Ticket.first))
    #end

    #it "should update ticket description" do
      #Ticket.first.description.should == 'yahoo'
    #end
  #end
#end

#describe "resource(Project.first, @ticket)" do

  #before :each do
    #login
  #end
  
  #describe "GET" do
    #before(:each) do
      #p = make_project
      #t = Ticket.make(:project => p,
                    #:user_creator => p.project_members.first.user)
      #@response = request(resource(p,t))
    #end

    #after :each do
      #Ticket.destroy_all
    #end
  
    #it "responds successfully" do
      #@response.should be_successful
    #end
  #end
  
  #describe "PUT" do

    #def put_request
      #@project = Project.first
      #@ticket = @project.tickets.first
      #@response = request(resource(@project, @ticket), 
                          #:method => "PUT", 
                          #:params => { :ticket => {:description => 'new comment',
                                                    #:state_id => State.first.id} })
    #end

    #describe "with anonymous" do
      #before :each do
        #create_default_admin
        #logout
        #t = Project.first.tickets.first
        #t.ticket_updates = []
        #t.save
        #put_request
      #end

      #it 'should be successful' do
        #@response.status.should == 401
      #end

      #it 'should not change ticket' do
        #@ticket.should == Project.first.tickets.first
      #end

      #it 'should not create ticket update' do
        #Project.first.tickets.first.ticket_updates.should be_empty
      #end
    #end

    #describe "with user logged" do
      #before(:each) do
        #login
        #put_request
      #end

      #after :each do
        #Ticket.destroy_all
      #end
    
      #it "redirect to the article show action" do
        #@response.should redirect_to(resource(@project, @ticket))
      #end
    #end
  #end
  
end

