@isTest
public class VoucherTriggerHandlerTest {
  private static testMethod void insertRecord() {
    TriggerSettings__c ts1 = new TriggerSettings__c();
    ts1.VoucherTrigger__c = true;
    insert ts1;

    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    Account accRec = new Account();
    accRec.RecordTypeId = recordTypeId;
    accRec.LastName = 'testing 123';
    insert accRec;

    Voucher__c vouchRec = new Voucher__c();
    vouchRec.Customer__c = accRec.Id;
    vouchRec.Name = accRec.LastName;
    System.debug('voucherRec laman: ' + vouchRec);
    insert vouchRec;

    Test.startTest();
    vouchRec.Contact__c = accRec.PersonContactId;
    update vouchRec;
    Test.stopTest();
  }
}
