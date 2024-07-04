/*********************************************************************
Name    :               IndividualEmailResultTriggerTest
Date    :               29 December 2017
Author  :               Anjerico Caburnay
Description :           Test Class of IndividualEmailResultTriggerTriggerHandler for et4ae5__IndividualEmailResult__c Object
Current Test Coverage : 
History :       
*********************************************************************/

@isTest
private class IndividualEmailResultTriggerHandlerTest {
  private static testMethod void testEmailSendDate() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.PersonAccountTrigger__c = true;
    ts1.IndividualEmailResultTrigger__c = true;
    insert ts1;

    system.debug('TriggerSettings__c: ' + ts1);

    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    List<Account> accList = new List<Account>();
    for (integer x = 0; x < 10; x++) {
      Account acct = TestDataBuilder.createAccount();
      acct.recordTypeId = recordTypeId;
      accList.add(acct);
    }

    insert accList;
    system.debug('Account List: ' + accList);

    List<Contact> conList = new List<Contact>(
      [SELECT ID FROM Contact WHERE AccountId IN :accList]
    );

    //insert triggersend object insert here
    et4ae5__Automated_Send__c triggerSend = new et4ae5__Automated_Send__c();
    triggerSend.Name = 'Test Trigger Send';
    triggerSend.et4ae5__EmailName__c = 'Test Trigger Send';
    triggerSend.et4ae5__FromName__c = 'Test name';
    triggerSend.et4ae5__FromEmail__c = 'test@email.com';
    triggerSend.et4ae5__Subject__c = 'test Send';
    insert triggerSend;

    List<et4ae5__IndividualEmailResult__c> emailList = new List<et4ae5__IndividualEmailResult__c>();
    for (integer y = 0; y < 10; y++) {
      et4ae5__IndividualEmailResult__c em = new et4ae5__IndividualEmailResult__c();
      em.Name = 'Test' + y;
      em.et4ae5__DateSent__c = system.today();
      em.et4ae5__Contact__c = conList[y].Id;
      em.et4ae5__TriggeredSendDefinition__c = triggerSend.Id;
      emailList.add(em);
    }

    system.debug('Email List: ' + emailList);
    insert emailList;
  }

  private static testMethod void testEmailBounced() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.PersonAccountTrigger__c = true;
    ts1.IndividualEmailResultTrigger__c = true;
    insert ts1;

    system.debug('TriggerSettings__c: ' + ts1);

    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    List<Account> accList = new List<Account>();
    for (integer x = 0; x < 10; x++) {
      Account acct = TestDataBuilder.createAccount();
      acct.recordTypeId = recordTypeId;
      accList.add(acct);
    }

    insert accList;
    system.debug('Account List: ' + accList);

    List<Contact> conList = new List<Contact>(
      [SELECT ID FROM Contact WHERE AccountId IN :accList]
    );

    //insert triggersend object insert here
    et4ae5__Automated_Send__c triggerSend = new et4ae5__Automated_Send__c();
    triggerSend.Name = 'Test Trigger Send';
    triggerSend.et4ae5__EmailName__c = 'Test Trigger Send';
    triggerSend.et4ae5__FromName__c = 'Test name';
    triggerSend.et4ae5__FromEmail__c = 'test@email.com';
    triggerSend.et4ae5__Subject__c = 'test Send';
    insert triggerSend;

    List<et4ae5__IndividualEmailResult__c> emailList = new List<et4ae5__IndividualEmailResult__c>();
    for (integer y = 0; y < 10; y++) {
      et4ae5__IndividualEmailResult__c em = new et4ae5__IndividualEmailResult__c();
      em.Name = 'Test' + y;
      em.et4ae5__DateSent__c = system.today();
      em.et4ae5__Contact__c = conList[y].Id;
      em.et4ae5__TriggeredSendDefinition__c = triggerSend.Id;
      em.et4ae5__HardBounce__c = true;
      em.et4ae5__DateBounced__c = system.today();
      emailList.add(em);
    }

    system.debug('Email List: ' + emailList);
    insert emailList;
  }
}
