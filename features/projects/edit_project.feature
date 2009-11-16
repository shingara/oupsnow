Feature: Editing project
  To ensure a project can be edit by user authorized
  An admin user, or project admin or user
  Must or not delete a project

  Scenario Outline: Can update project
    Given I have one <admin> user "shingara@gmail.com" with password "tintinpouet" and login "shingara"
    And I have a project "yahoo"
    And "shingara" <not> admin on project "yahoo"
    When logged with "shingara@gmail.com" with password "tintinpouet"
    And I follow "yahoo"
    And I follow "Settings"
    And I should see "Project"
    Given I follow "Project"
    And I fill in "project_name" with "A good project"
    And I fill in "project_description" with "A good description"
    And I press "Update"
    Then the request should be success
    Then I should see a notice message
    And I should see "Project is update"

    Examples:
    | admin | not |
    | admin |     |
    | admin | not |

  Scenario: Can't update project
    Given I have one user "shingara@gmail.com" with password "tintinpouet" and login "shingara"
    And I have a project "yahoo"
    And "shingara" not admin on project "yahoo"
    When logged with "shingara@gmail.com" with password "tintinpouet"
    And I follow "yahoo"
    Then I should not see "Settings"
