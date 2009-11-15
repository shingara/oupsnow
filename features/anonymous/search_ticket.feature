Feature: Search Ticket
  To can search ticket by project
  An anonymous user
  Must search ticket

  Scenario:
    Given I have a project "yahoo"
    And 3 tickets with state "new" and tag "feature" on project "yahoo"
    And 1 tickets with state "fixed" on project "yahoo"
    And 1 tickets with state "fixed" and tag "bug, feature" on project "yahoo"
    And 1 tickets with state "fixed" and tag "feature" on project "yahoo"
    When I go to the homepage
    And I follow "yahoo"
    And I follow "Tickets"
    Then I should see 3 "td" tag with content "new"
    Then I should see 3 "td" tag with content "fixed"
    And I fill in "q" with "state:new"
    And I submit "ticket_search"
    Then I should see 3 "td" tag with content "new"
    And I should not see "td" tag with content "fixed"
    When I fill in "q" with "state:fixed"
    And I submit "ticket_search"
    Then I should see 3 "td" tag with content "fixed"
    And I should not see "td" tag with content "new"
    When I fill in "q" with "state:fixed state:new"
    And I submit "ticket_search"
    # The filter active is only last about state
    Then I should not see "td" tag with content "fixed"
    And I should see 3 "td" tag with content "new"
    When I fill in "q" with "tagged:feature"
    And I submit "ticket_search"
    Then I should see 3 "td" tag with content "new"
    And I should see 2 "td" tag with content "fixed"
    When I fill in "q" with "state:new tagged:feature"
    And I submit "ticket_search"
    Then I should see 3 "td" tag with content "new"
    And I should not see "td" tag with content "fixed"
    When I fill in "q" with "state:fixed tagged:feature tagged:bug"
    And I submit "ticket_search"
    Then I should not see "td" tag with content "new"
    And I should see 1 "td" tag with content "fixed"
