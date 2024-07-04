/*********************************************************************
Name    :               BrewerRegistrationTriggerHandlerTest
Date    :               12 July 2017
Author  :               Anjerico Caburnay
Description :           Test Class of  for Brewer_Registration__c Object
Current Test Coverage : 100% 
History :       
*********************************************************************/

@isTest
private class BrewerRegistrationTriggerHandlerTest {
  private static testMethod void insertRecord() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.BrewerRegistrationTrigger__c = true;
    insert ts1;

    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    List<Account> accList = new List<Account>();
    for (integer x = 0; x < 10; x++) {
      Account acct = TestDataBuilder.createAccount();
      acct.recordTypeId = recordTypeId;
      acct.Opt_in_Request_Date__c = Date.Today();
      accList.add(acct);
    }

    insert accList;

    List<Brewer_Registration__c> brewerList = new List<Brewer_Registration__c>();
    for (integer y = 0; y < 10; y++) {
      Brewer_Registration__c brw = new Brewer_Registration__c(
        Serial_Number__c = '123' + y,
        Customer__c = accList[y].Id
      );
      brewerList.add(brw);
    }

    insert brewerList;
  }
}
