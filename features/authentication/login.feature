Feature: Login
  To ensure the safety of the application
  A regular user of the system
  Must authenticate before using the app

  Scenario Outline: Success Login
    Given I have one user "<mail>" with password "<password>" and login "<login>"
    When I go to login
    And I fill in "user_email" with "<mail>"
    And I fill in "user_password" with "<password>"
    And I press "Log In"
    Then the request should be success
    And I should see an notice message
    And I should not see "Administration"

    Examples:
    | mail                     | password       | login    |
    | shingara@gmail.com       | tintinpouet    | shingara |


  Scenario Outline: Failed Login
    Given I am not authenticated
    When I go to login
    And I fill in "user_email" with "<mail>"
    And I fill in "user_password" with "<password>"
    And I press "Log In"
    #Then the login request should fail
    Then I should see an alert message

    Examples:
      | mail           | password       |
      | not_an_address | nil            |
      | not@not        | 123455         |
      | 123@abc.com    | wrong_paasword |
