/**
 * @author piotr.tugeman@emark.com
 */
@isTest
private class LoyaltySelector_Test {
  @testSetup
  static void beforeEachTest() {
    // 3 accounts:
    List<Account> testAccounts = new List<Account>();

    Account account1 = new AccountBuilder()
      .setLastName('TestName_1')
      .setEmail('test_1@a.a')
      .setCountry('NL')
      .setBrand('Jacobs')
      .build();

    Account account2 = new AccountBuilder()
      .setLastName('TestName_2')
      .setEmail('test_2@a.a')
      .setCountry('NL')
      .setBrand('Tassimo')
      .build();

    Account account3 = new AccountBuilder()
      .setLastName('TestName_3')
      .setEmail('test_3@a.a')
      .setCountry('NL')
      .setBrand('Tassimo')
      .build();

    testAccounts.add(account1);
    testAccounts.add(account2);
    testAccounts.add(account3);

    Test.startTest();
    insert testAccounts;

    //3 loyalties (2,1,0 per account):
    List<Loyalty__c> loyalties = new List<Loyalty__c>();

    Loyalty__c loyalty1 = new Loyalty__c();
    loyalty1.Loyalty_Consumer__c = account1.Id;
    loyalty1.External_Id__c = account1.External_Id__c;

    Loyalty__c loyalty2 = new Loyalty__c();
    loyalty2.Loyalty_Consumer__c = account1.Id;
    //External id not equal account.ExternalId - to add more than one Loyalty per account
    loyalty2.External_Id__c = 'externalIdNotFromAccount';

    Loyalty__c loyalty3 = new Loyalty__c();
    loyalty3.Loyalty_Consumer__c = account2.Id;
    loyalty3.External_Id__c = account2.External_Id__c;

    loyalties.add(loyalty1);
    loyalties.add(loyalty2);
    loyalties.add(loyalty3);

    insert loyalties;

    //3 loyalty transactions (2,1,0 per loyalty)
    List<Loyalty_Transaction__c> transactions = new List<Loyalty_Transaction__c>();

    Loyalty_Transaction__c trans1 = new Loyalty_Transaction__c();
    trans1.Loyalty__c = loyalty1.Id;
    trans1.Loyalty_Consumer__c = account1.Id;
    trans1.Loyalty_Transaction_Type__c = 'Compensation';
    trans1.Transaction_Amount__c = 1;

    Loyalty_Transaction__c trans2 = new Loyalty_Transaction__c();
    trans2.Loyalty__c = loyalty1.Id;
    trans2.Loyalty_Consumer__c = account1.Id;
    trans2.Loyalty_Transaction_Type__c = 'Correction';
    trans2.Transaction_Amount__c = 10;

    Loyalty_Transaction__c trans3 = new Loyalty_Transaction__c();
    trans3.Loyalty__c = loyalty2.Id;
    trans3.Loyalty_Consumer__c = account1.Id;
    trans3.Loyalty_Transaction_Type__c = 'Redeem';
    trans3.Transaction_Amount__c = 100;

    transactions.add(trans1);
    transactions.add(trans2);
    transactions.add(trans3);

    insert transactions;

    Test.stopTest();
  }

  @isTest
  static void test_getLoyalties_return_all() {
    // setup
    Account account1 = AccountSelector.getAccountByExternalId(
      'test_1@a.aNLJacobs'
    );

    // under test:
    List<Loyalty__c> loyalties = LoyaltySelector.getLoyalties(account1.Id);

    // assertions
    System.assert(null != loyalties, 'List should be returned.');
    System.assertEquals(
      2,
      loyalties.size(),
      'There should be exactly two Loyalties for this account'
    );
  }

  @isTest
  static void test_getLoyalties_return_one() {
    // setup
    Account account2 = AccountSelector.getAccountByExternalId(
      'test_2@a.aNLTassimo'
    );

    // under test:
    List<Loyalty__c> loyalties = LoyaltySelector.getLoyalties(account2.Id);

    // assertions
    System.assert(null != loyalties, 'List should be returned.');
    System.assertEquals(
      1,
      loyalties.size(),
      'There should be exactly one Loyalty for this account'
    );
  }

  @isTest
  static void test_getLoyalties_return_empty_list() {
    // setup
    Account account3 = AccountSelector.getAccountByExternalId(
      'test_3@a.aNLTassimo'
    );

    // under test:
    List<Loyalty__c> loyalties = LoyaltySelector.getLoyalties(account3.Id);

    // assertions
    System.assert(null != loyalties, 'List should be returned.');
    System.assertEquals(
      0,
      loyalties.size(),
      'There should be no Loyalties for this account'
    );
  }

  @isTest
  static void test_getLoyaltyByExternalId_return_null() {
    // setup:
    String nonexistingExternalId = 'Brand-Country-Name';

    // under test:
    Loyalty__c loyalty = LoyaltySelector.getLoyaltyByExternalId(
      nonexistingExternalId
    );

    //assertion
    System.assertEquals(null, loyalty, 'There should be NO loyalty returned');
  }

  @isTest
  static void test_getLoyaltyByExternalId_return_one() {
    // setup:
    String existingExternalId = 'test_1@a.aNLJacobs';

    // under test:
    Loyalty__c loyalty = LoyaltySelector.getLoyaltyByExternalId(
      existingExternalId
    );

    //assertion
    System.assert(
      null != loyalty,
      'There should be loyalty returned. loyalty:' + loyalty
    );
    System.assertEquals(
      existingExternalId,
      loyalty.External_Id__c,
      'Returned Loyalty External Id should be same as in select'
    );
  }

  @isTest
  static void test_getLoyaltyTransactions_return_all() {
    // setup
    Account account1 = AccountSelector.getAccountByExternalId(
      'test_1@a.aNLJacobs'
    );
    Loyalty__c loyalty1 = LoyaltySelector.getLoyaltyByExternalId(
      account1.External_Id__c
    );

    // under test:
    List<Loyalty_Transaction__c> transactions = LoyaltySelector.getLoyaltyTransactions(
      account1.Id,
      loyalty1.Id
    );

    // assertions
    System.assert(null != transactions, 'List should be returned.');
    System.assertEquals(
      2,
      transactions.size(),
      'There should be exactly two Transactions for this account and loyalty'
    );
  }

  @isTest
  static void test_getLoyaltyTransactions_return_one() {
    // setup
    Account account1 = AccountSelector.getAccountByExternalId(
      'test_1@a.aNLJacobs'
    );
    Loyalty__c loyalty2 = LoyaltySelector.getLoyaltyByExternalId(
      'externalIdNotFromAccount'
    );

    // under test:
    List<Loyalty_Transaction__c> transactions = LoyaltySelector.getLoyaltyTransactions(
      account1.Id,
      loyalty2.Id
    );

    // assertions
    System.assert(null != transactions, 'List should be returned.');
    System.assertEquals(
      1,
      transactions.size(),
      'There should be exactly one Transactions for this account and loyalty'
    );
  }

  @isTest
  static void test_getLoyaltyTransactions_return_empty_list() {
    // setup
    Account account2 = AccountSelector.getAccountByExternalId(
      'test_2@a.aNLTassimo'
    );
    Loyalty__c loyalty3 = LoyaltySelector.getLoyaltyByExternalId(
      account2.External_Id__c
    );

    // under test:
    List<Loyalty_Transaction__c> transactions = LoyaltySelector.getLoyaltyTransactions(
      account2.Id,
      loyalty3.Id
    );

    // assertions
    System.assert(null != transactions, 'List should be returned.');
    System.assertEquals(
      0,
      transactions.size(),
      'There should be no Transactions for this account and loyalty'
    );
  }
}
