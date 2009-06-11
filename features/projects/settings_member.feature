Feature: Changing function of project's member
  To Change a function of project's member
  An A admin project user
  Must define all function member by member

  Scenario:
    Given I have one admin user "shingara" with password "tintinpouet"
    And I have a project "yahoo"
    And "shingara" not admin on project "yahoo"
    And I have user "clown" with function "admin" on project "yahoo" and no other user
    And I have user "zapata" with function "developper" on project "yahoo"
    When logged with "shingara" with password "tintinpouet"
    And I follow "yahoo"
    And I follow "Settings"
    Then I should see "Member on project"
    And I should see 1 "tr" tag with content "clown" 
    And I should see 1 "tr" tag with content "zapata" 
    When I select "admin" from "member_function" of "zapata" from "yahoo" project
    And transaction commit
    And I press "Update all"
    Then the member "zapata" has function "admin" in project "yahoo"
    When I select "developper" from "member_function" of "zapata" from "yahoo" project
    And I press "Update all"
    Then the member "zapata" has function "developper" in project "yahoo"
    When I select "developper" from "member_function" of "clown" from "yahoo" project
    When I select "admin" from "member_function" of "zapata" from "yahoo" project
    And I press "Update all"
    Then the member "zapata" has function "admin" in project "yahoo"
    Then the member "clown" has function "developper" in project "yahoo"
    When I select "developper" from "member_function" of "clown" from "yahoo" project
    When I select "developper" from "member_function" of "zapata" from "yahoo" project
    And I press "Update all"
    Then the member "zapata" has function "admin" in project "yahoo"
    And the member "clown" has function "developper" in project "yahoo"
    And I should see "You can't have no admin in a project"
