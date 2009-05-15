Feature: Login admin
  To ensure the safety of the application
  A regular user admin of the system
  Must authenticate and have all admin user

  Scenario:
    Given I have one admin user "shingara" with password "tintinpouet"
    When I go to /login
    And I fill in "login" with "shingara"
    And I fill in "password" with "tintinpouet"
    And I press "Log In"
    Then the login request should success
    And I should see an notice message
    And I should see "Administration" 

