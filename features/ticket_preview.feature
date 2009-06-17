Feature: ticket preview
  To View the preview
  A All authenticated user
  Does can see a preview ticket

  Scenario: Can see preview on ticket creation
    Given I have a project "yahoo"
    And I have state "new"
    And I have one user "shingara" with password "tintinpouet"
    And "shingara" not admin on project "yahoo"
    When logged with "shingara" with password "tintinpouet"
    And I follow "yahoo"
    And I follow "Add new ticket"
    And I fill in "ticket_title" with "A big new features"
    And I fill in "ticket[description]" with "A good description"
    And I press "Preview"
    Then I have 0 ticket on project "yahoo"
    And I should see a preview message 
    And I should see a preview message with "A good description"
    When I press "Create"
    Then I have 1 ticket on project "yahoo"
    When I follow "Tickets"
    Then I should see 1 "td" tag with content "A big new features"
