/**
 * @author piotr.tugeman@emark.com
 */
@isTest
private class AccountSelector_Test {
  @testSetup
  static void beforeEachTest() {
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
      .setConsentRegistrationSourceUrl('https://reg.com')
      .setConsentRegistrationDate('2018-09-10T10:32:56Z')
      .setConsentText('My consent text...')
      .setConsentStatus(AccountBuilder.CONSENT_STATUS_REGISTERED)
      .setConsentTextVersion('v1.0')
      .setPrivacyPolicyVersion('p1.0')
      .setConsentRegistrationIPAddress('192.168.0.0')
      .setOptInUrl('https://opt.in.pl')
      .setOptOutUrl('https://opt.out.pl')
      .setConsentConfirmationUrl('https://conf.in.pl')
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
    Test.stopTest();
  }

  @isTest
  static void test_getAllAccountsBusinessRelevantFields_return_everything_needed() {
    // under test:
    List<Account> allAccounts = AccountSelector.getAllAccountsBusinessRelevantFields();

    // assertions:
    System.assert(allAccounts.size() == 3, 'There should be 3 accounts');
    for (Account account : allAccounts) {
      System.assert(
        !String.isEmpty(account.External_ID__c),
        'Account External_Id should exist'
      );
    }
    System.assertNotEquals(
      allAccounts[0].External_Id__c,
      allAccounts[1].External_Id__c,
      'Accounts External_IDs should be different'
    );
    System.assertNotEquals(
      allAccounts[0].External_Id__c,
      allAccounts[2].External_Id__c,
      'Accounts External_IDs should be different'
    );
    System.assertNotEquals(
      allAccounts[1].External_Id__c,
      allAccounts[2].External_Id__c,
      'Accounts External_IDs should be different'
    );
  }

  @isTest
  static void test_getAccountByExternalId_return_updateable_fields() {
    // under test:
    Account account = AccountSelector.getAccountByExternalId(
      'test_2@a.aNLTassimo'
    );

    // assertions:
    System.assert(
      null != account,
      'There should be account with this externalID. Account=' + account
    );
    System.assert(
      String.isNotEmpty(account.External_Id__c),
      'Returned account should have non empty externalID. Account=' + account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Status__c),
      'Returned account should have non empty Consent_Status__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Registration_Source_URL__c),
      'Returned account should have non empty Consent_Registration_Source_URL__c. Account=' +
      account
    );
    System.assert(
      null != account.Consent_Registration_Date__c,
      'Returned account should have non empty Consent_Registration_Date__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Text__c),
      'Returned account should have non empty Consent_Text__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Text_Version__c),
      'Returned account should have non empty Consent_Text_Version__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Privacy_Policy_Version__c),
      'Returned account should have non empty Privacy_Policy_Version__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Registration_IP_Address__c),
      'Returned account should have non empty Consent_Registration_IP_Address__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Opt_in_URL__c),
      'Returned account should have non empty Opt_in_URL__c. Account=' + account
    );
    System.assert(
      String.isNotEmpty(account.Opt_out_URL__c),
      'Returned account should have non empty Opt_out_URL__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Confirmation_URL__c),
      'Returned account should have non empty Consent_Confirmation_URL__c. Account=' +
      account
    );
    System.assert(
      null != account.Sixteen_Years_or_Older__c,
      'Returned account should have non empty Sixteen_Years_or_Older__c. Account=' +
      account
    );

    System.assert(
      String.isNotEmpty(account.PersonContactId),
      'Returned account should have non empty PersonContactId. Account=' +
      account
    );
    System.assert(
      null != account.Active_Subscription__c,
      'Returned account should have non empty Active_Subscription__c. Account=' +
      account
    );
  }

  @isTest
  static void test_getAccountByExternalId_return_null() {
    // under test:
    Account account = AccountSelector.getAccountByExternalId('Nonexisting Id');

    // assertions:
    System.assert(
      null == account,
      'There should be no account with this externalID. Account=' + account
    );
  }

  @isTest
  static void test_getAccountByContactId_return_updateable_fields() {
    // setup:
    Account accountWithContactId = [
      SELECT PersonContactId
      FROM Account
      WHERE External_Id__c = 'test_2@a.aNLTassimo'
    ];

    // under test:
    Account account = AccountSelector.getAccountByContactId(
      accountWithContactId.PersonContactID
    );

    // assertions:
    System.assert(
      null != account,
      'There should be account with this Contact ID.'
    );
    System.assert(
      String.isNotEmpty(account.External_Id__c),
      'Returned account should have non empty externalID. Account=' + account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Status__c),
      'Returned account should have non empty Consent_Status__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Registration_Source_URL__c),
      'Returned account should have non empty Consent_Registration_Source_URL__c. Account=' +
      account
    );
    System.assert(
      null != account.Consent_Registration_Date__c,
      'Returned account should have non empty Consent_Registration_Date__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Text__c),
      'Returned account should have non empty Consent_Text__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Text_Version__c),
      'Returned account should have non empty Consent_Text_Version__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Privacy_Policy_Version__c),
      'Returned account should have non empty Privacy_Policy_Version__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Registration_IP_Address__c),
      'Returned account should have non empty Consent_Registration_IP_Address__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Opt_in_URL__c),
      'Returned account should have non empty Opt_in_URL__c. Account=' + account
    );
    System.assert(
      String.isNotEmpty(account.Opt_out_URL__c),
      'Returned account should have non empty Opt_out_URL__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Confirmation_URL__c),
      'Returned account should have non empty Consent_Confirmation_URL__c. Account=' +
      account
    );
    System.assert(
      null != account.Sixteen_Years_or_Older__c,
      'Returned account should have non empty Sixteen_Years_or_Older__c. Account=' +
      account
    );

    System.assert(
      String.isNotEmpty(account.PersonContactId),
      'Returned account should have non empty PersonContactId. Account=' +
      account
    );
    System.assert(
      null != account.Active_Subscription__c,
      'Returned account should have non empty Active_Subscription__c. Account=' +
      account
    );
  }

  @isTest
  static void test_getAccountByContactId_return_null() {
    // under test:
    Account account = AccountSelector.getAccountByContactId(
      'Nonexisting Contact Id'
    );

    // assertions:
    System.assert(
      null == account,
      'There should be no account with this Contact Id. Account=' + account
    );
  }

  @isTest
  static void test_getAccount_return_updateable_fields() {
    // under test:
    Account account = AccountSelector.getAccount('test_2@a.a', 'NL', 'Tassimo');

    // assertions:
    System.assert(
      null != account,
      'There should be account with this data. Account=' + account
    );
    System.assert(
      String.isNotEmpty(account.External_Id__c),
      'Returned account should have non empty externalID. Account=' + account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Status__c),
      'Returned account should have non empty Consent_Status__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Registration_Source_URL__c),
      'Returned account should have non empty Consent_Registration_Source_URL__c. Account=' +
      account
    );
    System.assert(
      null != account.Consent_Registration_Date__c,
      'Returned account should have non empty Consent_Registration_Date__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Text__c),
      'Returned account should have non empty Consent_Text__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Text_Version__c),
      'Returned account should have non empty Consent_Text_Version__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Privacy_Policy_Version__c),
      'Returned account should have non empty Privacy_Policy_Version__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Registration_IP_Address__c),
      'Returned account should have non empty Consent_Registration_IP_Address__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Opt_in_URL__c),
      'Returned account should have non empty Opt_in_URL__c. Account=' + account
    );
    System.assert(
      String.isNotEmpty(account.Opt_out_URL__c),
      'Returned account should have non empty Opt_out_URL__c. Account=' +
      account
    );
    System.assert(
      String.isNotEmpty(account.Consent_Confirmation_URL__c),
      'Returned account should have non empty Consent_Confirmation_URL__c. Account=' +
      account
    );
    System.assert(
      null != account.Sixteen_Years_or_Older__c,
      'Returned account should have non empty Sixteen_Years_or_Older__c. Account=' +
      account
    );

    System.assert(
      String.isNotEmpty(account.PersonContactId),
      'Returned account should have non empty PersonContactId. Account=' +
      account
    );
    System.assert(
      null != account.Active_Subscription__c,
      'Returned account should have non empty Active_Subscription__c. Account=' +
      account
    );
  }

  @isTest
  static void test_getAccountExternalId_return_null() {
    // under test:
    Account account = AccountSelector.getAccountExternalId('Nonexisting Id');

    // assertions:
    System.assert(
      null == account,
      'There should be no account with this Contact Id. Account=' + account
    );
  }

  @isTest
  static void test_getAccountExternalId_return_external_id() {
    // setup:
    Account accountWithId = [
      SELECT Id
      FROM Account
      WHERE External_Id__c = 'test_2@a.aNLTassimo'
    ];

    // under test:
    Account account = AccountSelector.getAccountExternalId(accountWithId.Id);

    // assertions:
    System.assert(
      null != account,
      'There should be account with this data. Account=' + account
    );
    System.assert(
      String.isNotEmpty(account.External_Id__c),
      'Returned account should have non empty externalID. Account=' + account
    );
    System.assertEquals(
      'test_2@a.aNLTassimo',
      account.External_Id__c,
      'Returned account External ID should be same as in SOQL in setup'
    );
  }
}
