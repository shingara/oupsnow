Feature: Changing function of project's member
  To Change a function of project's member
  An A admin project user
  Must define all function member by member

  Scenario: Setting project with global_admin user
    Given I have one admin user "shingara@gmail.com" with password "tintinpouet" and login "shingara"
    And I have a project "yahoo"
    And "shingara" not admin on project "yahoo"
    And I have user "clown" with function "admin" on project "yahoo" and no other user
    And I have user "zapata" with function "reporter" on project "yahoo"
    When logged with "shingara@gmail.com" with password "tintinpouet"
    And I follow "yahoo"
    And I follow "Settings"
    Then I should see "Member on project"
    And I should see 1 "tr" tag with content "clown"
    And I should see 1 "tr" tag with content "zapata"
    When I select "admin" from "member_function" of "zapata" from "yahoo" project
    And I press "Update all"
    Then the member "zapata" has function "admin" in project "yahoo"
    When I select "reporter" from "member_function" of "zapata" from "yahoo" project
    And I press "Update all"
    Then the member "zapata" has function "reporter" in project "yahoo"
    When I select "reporter" from "member_function" of "clown" from "yahoo" project
    When I select "admin" from "member_function" of "zapata" from "yahoo" project
    And I press "Update all"
    Then the member "zapata" has function "admin" in project "yahoo"
    Then the member "clown" has function "reporter" in project "yahoo"
    When I select "reporter" from "member_function" of "clown" from "yahoo" project
    When I select "reporter" from "member_function" of "zapata" from "yahoo" project
    And I press "Update all"
    Then the member "zapata" has function "admin" in project "yahoo"
    And the member "clown" has function "reporter" in project "yahoo"
    And I should see "You can't have no admin in a project"

  Scenario: Setting project with project_admin user
    Given I have one user "shingara@gmail.com" with password "tintinpouet" and login "shingara"
    And I have a project "yahoo" without members
    And "shingara@gmail.com" is project admin of "yahoo" project
    And I have user "clown" with function "admin" on project "yahoo"
    And I have user "zapata" with function "reporter" on project "yahoo"
    When logged with "shingara@gmail.com" with password "tintinpouet"
    And I follow "yahoo"
    And I follow "Settings"
    Then I should see "Member on project"
    And I should see 1 "tr" tag with content "clown"
    And I should see 1 "tr" tag with content "zapata"
    When I select "admin" from "member_function" of "zapata" from "yahoo" project
    And I press "Update all"
    Then the member "zapata" has function "admin" in project "yahoo"
    When I select "reporter" from "member_function" of "zapata" from "yahoo" project
    And I press "Update all"
    Then the member "zapata" has function "reporter" in project "yahoo"
    When I select "reporter" from "member_function" of "clown" from "yahoo" project
    And I select "admin" from "member_function" of "zapata" from "yahoo" project
    And I press "Update all"
    Then the member "zapata" has function "admin" in project "yahoo"
    And the member "clown" has function "reporter" in project "yahoo"
    When I select "reporter" from "member_function" of "clown" from "yahoo" project
    And I select "reporter" from "member_function" of "zapata" from "yahoo" project
    And I press "Update all"
    Then the member "zapata" has function "reporter" in project "yahoo"
    And the member "clown" has function "reporter" in project "yahoo"
    When I select "admin" from "member_function" of "clown" from "yahoo" project
    And I select "reporter" from "member_function" of "zapata" from "yahoo" project
    And I select "reporter" from "member_function" of "shingara" from "yahoo" project
    And I press "Update all"
    Then the member "zapata" has function "reporter" in project "yahoo"
    And the member "clown" has function "admin" in project "yahoo"
    And I should see "You can't update your own function to become a non admin"

  Scenario: Add member in project with admin user
    Given I have one user "shingara@gmail.com" with password "tintinpouet" and login "shingara"
    And I have a project "yahoo" without members
    And "shingara@gmail.com" is project admin of "yahoo" project
    And I have user "clown" with function "admin" on project "yahoo"
    And I have user "jungle" not in project "yahoo"
    And I have user "zapata" with function "reporter" on project "yahoo"
    When logged with "shingara@gmail.com" with password "tintinpouet"
    And I follow "yahoo"
    And I follow "Settings"
    Then I should see "Member on project"
    When I follow "Add member"
    And I select "jungle" from "project_member_user_id"
    And I press "Create"
    Then I should see 1 "tr" tag with content "jungle"



