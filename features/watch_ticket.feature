Feature: Watching or not ticket
  To watch ticket
  A different user
  Does watch or not

  Scenario: An anonymous can't see watch link
    Given I have a project "yahoo"
    And I have state "new"
    And I have one user "shingara@gmail.com" with password "tintinpouet" and login "shingara"
    And I create 3 tickets on project "yahoo"
    When I go to the homepage
    And I follow "yahoo"
    And I follow "tickets"
    And I follow "#1"
    Then I should not see "watch this ticket"
    And I should not see "unwatch this ticket"

  Scenario: A user logger watch and unwatch to ticket
    Given I have a project "yahoo"
    And I have state "new"
    And I have one user "shingara@gmail.com" with password "tintinpouet" and login "shingara"
    And I create 3 tickets on project "yahoo"
    When logged with "shingara@gmail.com" with password "tintinpouet"
    And I go to the homepage
    And I follow "yahoo"
    And I follow "tickets"
    And I follow "#1"
    Then I should not see "shingara" within ".block#watchers"
    And I press "watch this ticket"
    Then I should see "shingara@gmail.com" within ".block#watchers"
    And I press "unwatch this ticket"
    Then I should not see "shingara" within ".block#watchers"
