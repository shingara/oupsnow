require 'spec_helper'

describe UserMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include ActionController::UrlWriter

  describe '#ticket_update' do
    before(:all) do
      @ticket = make_ticket
      ticket_update = make_ticket_update(@ticket)
      @email = UserMailer.create_ticket_update(@ticket.project, ticket_update, Watcher.new(:email => 'shingara@gmail.com'))
    end
    it "should be set to be delivered to the email passed in" do
      @email.should deliver_to("shingara@gmail.com")
    end

    it "should contain the user's message in the mail body" do
      @email.should have_text(/#{@ticket.title}/)
    end

    it "should contain a link to ticket" do
      url = url_for(:controller => 'tickets', :action => 'show', :id => @ticket.num, :project_id => @ticket.project.id,
                    :host => ActionMailer::Base.default_url_options[:host])
      @email.should have_text(%r|#{url}|)
    end

    it "should have the correct subject" do
      @email.should have_subject(/\[#{@ticket.project.title} ##{@ticket.num}\]/)
    end

  end
end
