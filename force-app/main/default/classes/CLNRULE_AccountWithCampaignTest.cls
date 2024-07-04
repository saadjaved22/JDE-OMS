/*********************************************************************
Name    :               CLNRULE_AccountWithCampaignTest
Date    :               
Author  :               
Description :           Test Class of CLNRULE_AccountWithCampaign
Current Test Coverage : 
History :       
*********************************************************************/

@isTest
private class CLNRULE_AccountWithCampaignTest {
  public static testMethod void testScenario1() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.PersonAccountTrigger__c = true;
    insert ts1;
    Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
    settings.Days_for_Consumer_Deletes_Account__c = 14;
    settings.Days_for_Consumer_Withdraws__c = 14;
    insert settings;

    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    Account accRec = new Account();
    accRec.LastName = 'Test Class';
    accRec.RecordTypeId = recordTypeId;
    accRec.Brand__c = 'Douwe Egberts';
    accRec.Type__c = 'Loyalty';
    accRec.Country__c = 'NL';
    accRec.PersonEmail = 'testclassNL@salesforce.com';
    accRec.External_Id__c = 'testclassNL@salesforce.comNLDouweEgberts';
    accRec.Deletion_Flag__c = false;
    accRec.Account_Registration_Status__c = 'Deactivated';
    accRec.Consent_Status__c = 'Withdrawn';
    accRec.Consent_Withdrawn_Date__c = date.today();
    accRec.To_be_Deleted_Date__c = date.today();
    insert accRec;
    Contact conRec = [
      SELECT Id, AccountId
      FROM Contact
      WHERE Account.Name = 'Test Class'
      LIMIT 1
    ];
    List<CampaignMember> camMemberList = new List<CampaignMember>();
    campaign camp = new Campaign(
      Name = 'TestCampaign',
      EndDate = date.today().addMonths(-4)
    );
    Database.insert(camp, false);
    for (integer i = 0; i < 10; i++) {
      camMemberList.add(
        new CampaignMember(CampaignId = camp.Id, Status = 'Sent')
      );
    }
    Database.insert(camMemberList, false);
    Test.startTest();
    CLNRULE_AccountWithCampaign testBatch = new CLNRULE_AccountWithCampaign();
    DataBase.executeBatch(testBatch);
    System.assertEquals(
      accRec.Deletion_Flag__c = true,
      accRec.Deletion_Flag__c = true
    );
    Test.stopTest();
  }

  public static testMethod void testScenario2() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.PersonAccountTrigger__c = true;
    insert ts1;
    Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
    settings.Days_for_Consumer_Deletes_Account__c = 14;
    settings.Days_for_Consumer_Withdraws__c = 14;
    insert settings;

    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    Account accRec = new Account();
    accRec.LastName = 'Test Class';
    accRec.RecordTypeId = recordTypeId;
    accRec.Brand__c = 'Douwe Egberts';
    accRec.Type__c = 'Loyalty';
    accRec.Country__c = 'NL';
    accRec.PersonEmail = 'testclassNL@salesforce.com';
    accRec.External_Id__c = 'testclassNL@salesforce.comNLDouweEgberts';
    accRec.Deletion_Flag__c = false;
    accRec.Account_Registration_Status__c = 'Deactivated';
    accRec.Consent_Status__c = 'Withdrawn';
    accRec.Account_Deletion_Date__c = date.today();
    accRec.To_be_Deleted_Date__c = date.today();
    insert accRec;
    Contact conRec = [
      SELECT Id, AccountId
      FROM Contact
      WHERE Account.Name = 'Test Class'
      LIMIT 1
    ];
    List<CampaignMember> camMemberList = new List<CampaignMember>();
    campaign camp = new Campaign(
      Name = 'TestCampaign',
      EndDate = date.today().addMonths(-4)
    );
    Database.insert(camp, false);
    for (integer i = 0; i < 10; i++) {
      camMemberList.add(
        new CampaignMember(
          ContactId = conRec.Id,
          CampaignId = camp.Id,
          Status = 'Sent'
        )
      );
    }
    Database.insert(camMemberList, false);
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    Test.startTest();
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    //accRec.Deletion_Flag__c = True;
    //accRec.Deletion_Reason__c = Label.DelReason_Consent_Withdrawn;
    //accRec.To_be_Deleted_Date__c = Date.valueOf(accRec.Consent_Withdrawn_Date__c).addDays(Integer.valueOf(settings.Days_for_Consumer_Deletes_Account__c));
    //Database.update(accRec, false);
    CLNRULE_AccountWithCampaign testBatch = new CLNRULE_AccountWithCampaign();
    DataBase.executeBatch(testBatch);
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    System.assertEquals(
      accRec.Deletion_Flag__c = true,
      accRec.Deletion_Flag__c = true
    );
    Test.stopTest();
  }

  public static testMethod void testScenario3() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.PersonAccountTrigger__c = true;
    insert ts1;
    Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
    settings.Days_for_Consumer_Deletes_Account__c = 14;
    settings.Days_for_Consumer_Withdraws__c = 14;
    settings.Days_for_Request_to_be_Forgotten__c = 14;
    insert settings;

    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    Account accRec = new Account();
    accRec.LastName = 'Test Class';
    accRec.RecordTypeId = recordTypeId;
    accRec.Brand__c = 'Douwe Egberts';
    accRec.Type__c = 'Loyalty';
    accRec.Country__c = 'NL';
    accRec.PersonEmail = 'testclassNL@salesforce.com';
    accRec.External_Id__c = 'testclassNL@salesforce.comNLDouweEgberts';
    accRec.Deletion_Flag__c = false;
    accRec.Account_Registration_Status__c = 'Deactivated';
    accRec.Request_to_be_Forgotten__c = true;
    accRec.Consent_Status__c = 'Withdrawn';
    accRec.Consent_Withdrawn_Date__c = date.today();
    accRec.To_be_Deleted_Date__c = date.today();
    insert accRec;
    Contact conRec = [
      SELECT Id, AccountId
      FROM Contact
      WHERE Account.Name = 'Test Class'
      LIMIT 1
    ];
    List<CampaignMember> camMemberList = new List<CampaignMember>();
    campaign camp = new Campaign(
      Name = 'TestCampaign',
      EndDate = date.today().addMonths(-2)
    );
    Database.insert(camp, false);
    for (integer i = 0; i < 10; i++) {
      camMemberList.add(
        new CampaignMember(
          ContactId = conRec.Id,
          CampaignId = camp.Id,
          Status = 'Sent'
        )
      );
    }
    Database.insert(camMemberList, false);
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    Test.startTest();
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    //accRec.Deletion_Flag__c = True;
    //accRec.Deletion_Reason__c = Label.DelReason_Consent_Withdrawn;
    //accRec.To_be_Deleted_Date__c = Date.valueOf(accRec.Consent_Withdrawn_Date__c).addDays(Integer.valueOf(settings.Days_for_Consumer_Deletes_Account__c));
    //Database.update(accRec, false);
    CLNRULE_AccountWithCampaign testBatch = new CLNRULE_AccountWithCampaign();
    DataBase.executeBatch(testBatch);
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    System.assertEquals(
      accRec.Deletion_Flag__c = true,
      accRec.Deletion_Flag__c = true
    );
    Test.stopTest();
  }

  public static testMethod void testScenario4() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.PersonAccountTrigger__c = true;
    insert ts1;
    Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
    settings.Days_for_Consumer_Deletes_Account__c = 14;
    settings.Days_for_Consumer_Withdraws__c = 14;
    settings.Days_for_Request_to_be_Forgotten__c = 14;
    insert settings;

    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    Account accRec = new Account();
    accRec.LastName = 'Test Class';
    accRec.RecordTypeId = recordTypeId;
    accRec.Brand__c = 'Douwe Egberts';
    accRec.Type__c = 'Loyalty';
    accRec.Country__c = 'NL';
    accRec.PersonEmail = 'testclassNL@salesforce.com';
    accRec.External_Id__c = 'testclassNL@salesforce.comNLDouweEgberts';
    accRec.Deletion_Flag__c = false;
    accRec.Account_Registration_Status__c = null;
    accRec.Request_to_be_Forgotten__c = true;
    accRec.Consent_Status__c = 'Withdrawn';
    accRec.Consent_Withdrawn_Date__c = date.today();
    accRec.To_be_Deleted_Date__c = date.today();
    insert accRec;
    Contact conRec = [
      SELECT Id, AccountId
      FROM Contact
      WHERE Account.Name = 'Test Class'
      LIMIT 1
    ];
    List<CampaignMember> camMemberList = new List<CampaignMember>();
    campaign camp = new Campaign(
      Name = 'TestCampaign',
      EndDate = date.today().addMonths(-2)
    );
    Database.insert(camp, false);
    for (integer i = 0; i < 10; i++) {
      camMemberList.add(
        new CampaignMember(
          ContactId = conRec.Id,
          CampaignId = camp.Id,
          Status = 'Sent'
        )
      );
    }
    Database.insert(camMemberList, false);
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    Test.startTest();
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    //accRec.Deletion_Flag__c = True;
    //accRec.Deletion_Reason__c = Label.DelReason_Consent_Withdrawn;
    //accRec.To_be_Deleted_Date__c = Date.valueOf(accRec.Consent_Withdrawn_Date__c).addDays(Integer.valueOf(settings.Days_for_Consumer_Deletes_Account__c));
    //Database.update(accRec, false);
    CLNRULE_AccountWithCampaign testBatch = new CLNRULE_AccountWithCampaign();
    DataBase.executeBatch(testBatch);
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    System.assertEquals(
      accRec.Deletion_Flag__c = true,
      accRec.Deletion_Flag__c = true
    );
    Test.stopTest();
  }

  public static testMethod void testScenario5() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.PersonAccountTrigger__c = true;
    insert ts1;
    Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
    settings.Days_for_Consumer_Deletes_Account__c = 14;
    settings.Days_for_Consumer_Withdraws__c = 14;
    settings.Days_for_Request_to_be_Forgotten__c = 14;
    insert settings;

    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    Account accRec = new Account();
    accRec.LastName = 'Test Class';
    accRec.RecordTypeId = recordTypeId;
    accRec.Brand__c = 'Douwe Egberts';
    accRec.Type__c = 'Loyalty';
    accRec.Country__c = 'NL';
    accRec.PersonEmail = 'testclassNL@salesforce.com';
    accRec.External_Id__c = 'testclassNL@salesforce.comNLDouweEgberts';
    accRec.Deletion_Flag__c = false;
    accRec.Account_Registration_Status__c = 'Deactivated';
    accRec.Request_to_be_Forgotten__c = true;
    accRec.Consent_Status__c = null;
    accRec.Consent_Withdrawn_Date__c = date.today();
    accRec.To_be_Deleted_Date__c = date.today();
    insert accRec;
    Contact conRec = [
      SELECT Id, AccountId
      FROM Contact
      WHERE Account.Name = 'Test Class'
      LIMIT 1
    ];
    List<CampaignMember> camMemberList = new List<CampaignMember>();
    campaign camp = new Campaign(
      Name = 'TestCampaign',
      EndDate = date.today().addMonths(-4)
    );
    Database.insert(camp, false);
    for (integer i = 0; i < 10; i++) {
      camMemberList.add(
        new CampaignMember(
          ContactId = conRec.Id,
          CampaignId = camp.Id,
          Status = 'Sent'
        )
      );
    }
    Database.insert(camMemberList, false);
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    Test.startTest();
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    //accRec.Deletion_Flag__c = True;
    //accRec.Deletion_Reason__c = Label.DelReason_Consent_Withdrawn;
    //accRec.To_be_Deleted_Date__c = Date.valueOf(accRec.Consent_Withdrawn_Date__c).addDays(Integer.valueOf(settings.Days_for_Consumer_Deletes_Account__c));
    //Database.update(accRec, false);
    CLNRULE_AccountWithCampaign testBatch = new CLNRULE_AccountWithCampaign();
    DataBase.executeBatch(testBatch);
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    System.assertEquals(
      accRec.Deletion_Flag__c = true,
      accRec.Deletion_Flag__c = true
    );
    Test.stopTest();
  }

  public static testMethod void testScenario6() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.PersonAccountTrigger__c = true;
    insert ts1;
    Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
    settings.Days_for_Consumer_Deletes_Account__c = 14;
    settings.Days_for_Consumer_Withdraws__c = 14;
    settings.Days_for_Request_to_be_Forgotten__c = 14;
    insert settings;

    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    Account accRec = new Account();
    accRec.LastName = 'Test Class';
    accRec.RecordTypeId = recordTypeId;
    accRec.Brand__c = 'Douwe Egberts';
    accRec.Type__c = 'Loyalty';
    accRec.Country__c = 'NL';
    accRec.PersonEmail = 'testclassNL@salesforce.com';
    accRec.External_Id__c = 'testclassNL@salesforce.comNLDouweEgberts';
    accRec.Deletion_Flag__c = false;
    accRec.Account_Registration_Status__c = 'Active';
    accRec.Request_to_be_Forgotten__c = true;
    accRec.Consent_Status__c = 'Active';
    accRec.Consent_Withdrawn_Date__c = date.today();
    accRec.To_be_Deleted_Date__c = date.today();
    insert accRec;
    Contact conRec = [
      SELECT Id, AccountId
      FROM Contact
      WHERE Account.Name = 'Test Class'
      LIMIT 1
    ];
    List<CampaignMember> camMemberList = new List<CampaignMember>();
    campaign camp = new Campaign(
      Name = 'TestCampaign',
      EndDate = date.today().addMonths(-4)
    );
    Database.insert(camp, false);
    for (integer i = 0; i < 10; i++) {
      camMemberList.add(
        new CampaignMember(
          ContactId = conRec.Id,
          CampaignId = camp.Id,
          Status = 'Sent'
        )
      );
    }
    Database.insert(camMemberList, false);
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    Test.startTest();
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    //accRec.Deletion_Flag__c = True;
    //accRec.Deletion_Reason__c = Label.DelReason_Consent_Withdrawn;
    //accRec.To_be_Deleted_Date__c = Date.valueOf(accRec.Consent_Withdrawn_Date__c).addDays(Integer.valueOf(settings.Days_for_Consumer_Deletes_Account__c));
    //Database.update(accRec, false);
    CLNRULE_AccountWithCampaign testBatch = new CLNRULE_AccountWithCampaign();
    DataBase.executeBatch(testBatch);
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    System.assertEquals(
      accRec.Deletion_Flag__c = true,
      accRec.Deletion_Flag__c = true
    );
    Test.stopTest();
  }

  public static testMethod void testScenario7() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.PersonAccountTrigger__c = true;
    insert ts1;
    Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
    settings.Days_for_Consumer_Deletes_Account__c = 14;
    settings.Days_for_Consumer_Withdraws__c = 14;
    settings.Days_for_Request_to_be_Forgotten__c = 14;
    insert settings;

    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    Account accRec = new Account();
    accRec.LastName = 'Test Class';
    accRec.RecordTypeId = recordTypeId;
    accRec.Brand__c = 'Douwe Egberts';
    accRec.Type__c = 'Loyalty';
    accRec.Country__c = 'NL';
    accRec.PersonEmail = 'testclassNL@salesforce.com';
    accRec.External_Id__c = 'testclassNL@salesforce.comNLDouweEgberts';
    accRec.Deletion_Flag__c = false;
    accRec.Account_Registration_Status__c = 'Deactivated';
    accRec.Request_to_be_Forgotten__c = true;
    accRec.Consent_Status__c = null;
    accRec.To_be_Deleted_Date__c = date.today();
    insert accRec;
    Contact conRec = [
      SELECT Id, AccountId
      FROM Contact
      WHERE Account.Name = 'Test Class'
      LIMIT 1
    ];
    List<CampaignMember> camMemberList = new List<CampaignMember>();
    campaign camp = new Campaign(
      Name = 'TestCampaign',
      EndDate = date.today().addMonths(-4)
    );
    Database.insert(camp, false);
    for (integer i = 0; i < 10; i++) {
      camMemberList.add(
        new CampaignMember(
          ContactId = conRec.Id,
          CampaignId = camp.Id,
          Status = 'Sent'
        )
      );
    }
    Database.insert(camMemberList, false);
    Test.startTest();
    //(accRec.Deletion_Flag__c == false && accRec.Request_to_be_Forgotten__c == True && accRec.Account_Registration_Status__c != 'Active' && accRec.Consent_Status__c == Null && campMem.Campaign.EndDate < date.today().addMonths(-3)
    CLNRULE_AccountWithCampaign testBatch = new CLNRULE_AccountWithCampaign();
    DataBase.executeBatch(testBatch);
    System.debug('Deletion Flag: ' + accRec.Deletion_Flag__c);
    System.debug(
      'Registration Status: ' + accRec.Account_Registration_Status__c
    );
    System.debug('Consent Status: ' + accRec.Consent_Status__c);
    System.debug('Withdrawn Date: ' + accRec.Consent_Withdrawn_Date__c);
    System.debug('Campaign End Date: ' + camp.EndDate);
    System.assertEquals(
      accRec.Deletion_Flag__c = true,
      accRec.Deletion_Flag__c = true
    );
    Test.stopTest();
  }
}
