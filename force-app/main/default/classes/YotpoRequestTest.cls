@isTest
public with sharing class YotpoRequestTest {
  @testSetup
  static void testSetup() {
    //Insert YotpoAPI__c Settings
    List<YotpoAPI__c> yotpoList = new List<YotpoAPI__c>();
    YotpoAPI__c yotpoSettings = new YotpoAPI__c();

    yotpoSettings.Name = 'test';
    yotpoSettings.Brand__c = 'Tassimo';
    yotpoSettings.Client_Id__c = 'test';
    yotpoSettings.Client_Secret__c = 'test';
    yotpoSettings.Country__c = 'DE';
    yotpoSettings.Language__c = 'German';

    yotpoList.add(yotpoSettings);

    insert yotpoList;

    //Insert Accounts Settings
    List<Account> accountList = new List<Account>();

    Account acc = new Account(LastName = 'Yotpo Test Confirmed DE Tassimo');
    acc.Consent_Status__c = 'Confirmed';
    acc.Country__c = 'DE';
    acc.Language__c = 'German';
    acc.Brand__c = 'Tassimo';
    acc.PersonEmail = 'test@example.com';

    accountList.add(acc);

    acc = new Account(LastName = 'Yotpo Test Active DE Tassimo');
    acc.Consent_Status__c = 'Active';
    acc.Country__c = 'DE';
    acc.Language__c = 'German';
    acc.Brand__c = 'Tassimo';
    acc.PersonEmail = 'test@example.com';

    accountList.add(acc);

    acc = new Account(LastName = 'Yotpo Test Confirmed NL Tassimo');
    acc.Consent_Status__c = 'Confirmed';
    acc.Country__c = 'NL';
    acc.Language__c = 'German';
    acc.Brand__c = 'Tassimo';
    acc.PersonEmail = 'test@example.com';

    accountList.add(acc);

    acc = new Account(LastName = 'Yotpo Test Confirmed DE Tassimo No Lang');
    acc.Consent_Status__c = 'Confirmed';
    acc.Country__c = 'DE';
    acc.Brand__c = 'Tassimo';
    acc.PersonEmail = 'test@example.com';

    accountList.add(acc);

    insert accountList;
  }

  @isTest
  public static void getYotpoCredentialsTest() {
    Map<String, YotpoAPI__c> credentialsMap = YotpoRequest.getYotpoCredentials();
  }

  @isTest
  public static void getAccountsMapTest() {
    List<id> accountIds = new List<id>();

    for (Account a : [
      SELECT Id, PersonEmail, Country__c, Brand__c, Language__c
      FROM Account
    ]) {
      accountIds.add(a.Id);
    }

    Map<String, String[]> accountsMap = YotpoRequest.getAccountsMap(accountIds);
  }

  @isTest
  public static void getTokenTest() {
    String key = 'DE_German_Tassimo';
    Map<String, YotpoAPI__c> yotpoCredentialsMap = YotpoRequest.getYotpoCredentials();
    YotpoAPI__c credentials = yotpoCredentialsMap.get(key);

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new YotpoApiMock());
    String access_token = YotpoRequest.getToken(credentials);
    Test.stopTest();
  }

  @isTest
  public static void subscribeUsersTest() {
    List<id> accountIds = new List<id>();

    for (Account a : [
      SELECT Id, PersonEmail, Country__c, Brand__c, Language__c
      FROM Account
    ]) {
      accountIds.add(a.Id);
    }

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new YotpoApiMock());
    YotpoRequest.subscribeUsers(accountIds);
    Test.stopTest();
  }

  @isTest
  public static void unsubscribeUsersTest() {
    List<id> accountIds = new List<id>();

    for (Account a : [
      SELECT Id, PersonEmail, Country__c, Brand__c, Language__c
      FROM Account
    ]) {
      accountIds.add(a.Id);
    }

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new YotpoApiMock());
    YotpoRequest.unsubscribeUsers(accountIds);
    Test.stopTest();
  }
}
