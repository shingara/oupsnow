Feature: Login admin
  To ensure the safety of the application
  A regular user admin of the system
  Must authenticate and have all admin user

  Scenario:
    Given I have one admin user "shingara@gmail.com" with password "tintinpouet" and login "shingara"
    When I go to login
    And I fill in "user_email" with "shingara@gmail.com"
    And I fill in "user_password" with "tintinpouet"
    And I press "Log In"
    Then the request should be success
    And I should see an success message
    And I should see "Administration"

