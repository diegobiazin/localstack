Feature: S3 notification
  Everybody wants to execute a lambda

  Scenario: Trigger lambda via S3 notification
    Given A s3 notification
    When I trigger tha lambda
    Then Should execute successfully
