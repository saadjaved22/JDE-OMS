/*********************************************************************
Name    :       UserPasswordChangeDate 
Date    :       14 August 2020
Author  :       Anlene Sanmocte
Description:    To get Last Password Change Date from User Object with a community user
History :       
*********************************************************************/

@IsTest
public class UserPasswordChangeDateTest {
  private static testMethod void testUserPasswordChangeDate() {
    TriggerSettings__c ts1 = new TriggerSettings__c();

    Map<String, Schema.RecordTypeInfo> recordTypeInfo = Account.SObjectType.getDescribe()
      .getRecordTypeInfosByName();
    String recordTypeId = recordTypeInfo.get('Person Account')
      .getRecordTypeId();
    Profile profId = [
      SELECT Id, name
      FROM Profile
      WHERE NAME = 'DE External Identity User'
      LIMIT 1
    ];

    Account acct = new Account();
    acct.lastName = 'Test Account';
    acct.recordTypeId = recordTypeId;
    acct.firstName = 'Test Name';
    acct.lastName = 'Test Account';

    insert acct;

    Contact con = [
      SELECT Id, FirstName, LastName
      FROM Contact
      WHERE AccountId = :acct.Id
    ];

    User usr = new User(
      Alias = 'tstUsr',
      Email = 'tstUsr@email.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test Account',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profId.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'tstUsr@email.com',
      contactId = con.Id,
      isActive = true
      //LastPasswordChangeDate = DateTime.newInstance(2020, 08, 18)
    );

    insert usr;

    System.setPassword(usr.Id, 'Test@1234');

    Test.startTest();

    DateTime passChangeDate = UserPasswordChangeDate.checkLastPasswordChangeDate(
      usr.Id
    );
    DateTime nullPassChangeDate = UserPasswordChangeDate.checkLastPasswordChangeDate(
      null
    );

    Test.stopTest();
  }
}
