Feature: Search Ticket
  To can search ticket by project
  An anonymous user
  Must search ticket

  Scenario:
    Given I have a project "yahoo"
    And 3 tickets with state "new" on project "yahoo"
    And 3 tickets with state "fixed" on project "yahoo"
    When I go to /
    And I follow "yahoo"
    And I follow "Tickets"
    Then I should see 3 "td" tag with content "new"
    Then I should see 3 "td" tag with content "fixed"
    And I fill in "q" with "state:new"
    And I submit "ticket_search"
    Then I should see 3 "td" tag with content "new"
    And I should not see "td" tag with content "fixed"

