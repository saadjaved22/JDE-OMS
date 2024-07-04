/**
 * @author piotr.tugeman@emark.com
 */
@isTest
private class AccountException_Test {
  @testSetup
  static void beforeEachTest() {
    Account account1 = new AccountBuilder()
      .setLastName('TestName_1')
      .setEmail('test_1@a.a')
      .setCountry('NL')
      .setBrand('Jacobs')
      .build();

    Test.startTest();
    insert account1;
    Test.stopTest();
  }

  @isTest
  static void test_AccountException_sets_message() {
    // setup:
    Account account = AccountSelector.getAllAccountsBusinessRelevantFields()[0];

    // under test:
    AccountException ex = new AccountException(account, 'Random message');

    // assertions:
    System.assert(null != ex, 'Exception should be created.');
    System.assert(
      null != ex.getAccount(),
      'Exception should carry Account data.'
    );
    System.assertEquals(
      account.ID,
      ex.getAccount().ID,
      'Account ID from Exception should be same as Account ID.'
    );
  }

  @isTest
  static void test_AccountException_sets_account() {
    // setup:
    Account account = AccountSelector.getAllAccountsBusinessRelevantFields()[0];
    String exceptionMessage = 'Meaningfull Message';

    // under test:
    AccountException ex = new AccountException(account, exceptionMessage);

    // assertions:
    System.assert(null != ex, 'Exception should be created.');
    System.assertEquals(
      false,
      String.isEmpty(ex.getMessage()),
      'Exception mesage shouldn\'t be empty.'
    );
    System.assertEquals(
      exceptionMessage,
      ex.getMessage(),
      'Exception message should be same as in setup'
    );
  }
}
