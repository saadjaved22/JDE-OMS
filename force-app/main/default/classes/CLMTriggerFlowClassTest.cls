@isTest
public class CLMTriggerFlowClassTest {
  @isTest
  static void CLMTriggerFlowClassTest() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.PersonAccountTrigger__c = true;
    ts1.BrewerRegistrationTrigger__c = true;
    insert ts1;

    test.startTest();
    Account account1 = new AccountBuilder()
      .setLastName('TEST')
      .setEmail('test@test.com')
      .setCountry('NL')
      .setBrand('Senseo')
      .build();

    account1.Consent_Status__c = 'Confirmed';
    insert account1;

    Brewer_Registration__C brewer = new Brewer_Registration__C();
    brewer.Customer__c = account1.Id;
    brewer.Brand__c = 'Senseo';
    brewer.Country__c = 'NL';
    brewer.name = 'test';
    insert brewer;
    test.stopTest();
    Brewer_Registration__C brewer_Results1 = [
      SELECT CLM_Welcome_Mail_Sent__c, Send_Welcome_Email__c
      FROM Brewer_Registration__C
      WHERE id = :brewer.Id
    ];
    system.assertEquals(null, brewer_Results1.CLM_Welcome_Mail_Sent__c);
    System.assertEquals(false, brewer_Results1.Send_Welcome_Email__c);
  }
  @isTest
  static void CLMTriggerFlowClassUpdateAccountActiveTest() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.PersonAccountTrigger__c = true;
    ts1.BrewerRegistrationTrigger__c = true;
    insert ts1;

    test.startTest();
    Account account1 = new AccountBuilder()
      .setLastName('TEST')
      .setEmail('test@test.com')
      .setCountry('NL')
      .setBrand('Senseo')
      .build();

    account1.Consent_Status__c = 'Active';
    insert account1;

    Brewer_Registration__C brewer = new Brewer_Registration__C();
    brewer.Customer__c = account1.Id;
    brewer.Brand__c = 'Senseo';
    brewer.Country__c = 'NL';
    brewer.name = 'test';
    insert brewer;
    test.stopTest();
    Brewer_Registration__C brewer_Results = [
      SELECT CLM_Welcome_Mail_Sent__c, Send_Welcome_Email__c
      FROM Brewer_Registration__C
      WHERE id = :brewer.Id
    ];
    system.assertEquals(
      system.today(),
      brewer_Results.CLM_Welcome_Mail_Sent__c
    );
    System.assertEquals(true, brewer_Results.Send_Welcome_Email__c);
  }
  @isTest
  static void CLMTriggerFlowClassUpdateAccountActivationTest() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.PersonAccountTrigger__c = true;
    ts1.BrewerRegistrationTrigger__c = true;
    insert ts1;

    Account account1 = new AccountBuilder()
      .setLastName('TEST')
      .setEmail('test@test.com')
      .setCountry('NL')
      .setBrand('Senseo')
      .build();

    account1.Consent_Status__c = 'Confirmed';
    insert account1;

    Brewer_Registration__C brewer = new Brewer_Registration__C();
    brewer.Customer__c = account1.Id;
    brewer.Contact__c = account1.personcontactid;
    brewer.Brand__c = 'Senseo';
    brewer.Country__c = 'NL';
    brewer.name = 'test';
    insert brewer;

    Brewer_Registration__C brewer1 = new Brewer_Registration__C();
    brewer1.Customer__c = account1.Id;
    brewer1.Contact__c = account1.personcontactid;
    brewer1.Brand__c = 'Senseo';
    brewer1.Country__c = 'NL';
    brewer1.name = 'test';
    insert brewer1;

    Brewer_Registration__C brewer2 = new Brewer_Registration__C();
    brewer2.Customer__c = account1.Id;
    brewer2.Contact__c = account1.personcontactid;
    brewer2.Brand__c = 'Senseo';
    brewer2.Country__c = 'NL';
    brewer2.name = 'test';
    insert brewer2;
    Brewer_Registration__C before_brewer_Results = [
      SELECT CLM_Welcome_Mail_Sent__c, Send_Welcome_Email__c
      FROM Brewer_Registration__C
      WHERE id = :brewer.Id
    ];
    Brewer_Registration__C before_brewer_Results1 = [
      SELECT CLM_Welcome_Mail_Sent__c, Send_Welcome_Email__c
      FROM Brewer_Registration__C
      WHERE id = :brewer1.Id
    ];
    Brewer_Registration__C before_brewer_Results2 = [
      SELECT CLM_Welcome_Mail_Sent__c, Send_Welcome_Email__c
      FROM Brewer_Registration__C
      WHERE id = :brewer2.Id
    ];

    system.assertEquals(null, before_brewer_Results.CLM_Welcome_Mail_Sent__c);
    system.assertEquals(null, before_brewer_Results1.CLM_Welcome_Mail_Sent__c);
    system.assertEquals(null, before_brewer_Results2.CLM_Welcome_Mail_Sent__c);
    System.assertEquals(false, before_brewer_Results.Send_Welcome_Email__c);
    System.assertEquals(false, before_brewer_Results1.Send_Welcome_Email__c);
    System.assertEquals(false, before_brewer_Results2.Send_Welcome_Email__c);
    test.startTest();
    account1.Consent_Status__c = 'Active';
    update account1;
    test.stopTest();
    Brewer_Registration__C brewer_Results = [
      SELECT CLM_Welcome_Mail_Sent__c, Send_Welcome_Email__c
      FROM Brewer_Registration__C
      WHERE id = :brewer.Id
    ];
    Brewer_Registration__C brewer_Results1 = [
      SELECT CLM_Welcome_Mail_Sent__c, Send_Welcome_Email__c
      FROM Brewer_Registration__C
      WHERE id = :brewer1.Id
    ];
    Brewer_Registration__C brewer_Results2 = [
      SELECT CLM_Welcome_Mail_Sent__c, Send_Welcome_Email__c
      FROM Brewer_Registration__C
      WHERE id = :brewer2.Id
    ];

    system.assertEquals(
      system.today(),
      brewer_Results.CLM_Welcome_Mail_Sent__c
    );
    system.assertEquals(
      system.today(),
      brewer_Results1.CLM_Welcome_Mail_Sent__c
    );
    system.assertEquals(
      system.today(),
      brewer_Results2.CLM_Welcome_Mail_Sent__c
    );
    System.assertEquals(true, brewer_Results.Send_Welcome_Email__c);
    System.assertEquals(true, brewer_Results1.Send_Welcome_Email__c);
    System.assertEquals(true, brewer_Results2.Send_Welcome_Email__c);
  }
}
