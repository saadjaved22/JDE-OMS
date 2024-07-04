@isTest
public class HighcoRequestTest {
  private static testMethod void testHighcoDelete() {
    BoomiMock mock = new BoomiMock();
    Test.setMock(HttpCalloutMock.class, mock);

    BoomiAPI__c sett = new BoomiAPI__c();
    sett.Partner_Key__c = 'dd';
    sett.Endpoint_URL__c = 'http://';
    sett.Token__c = 'x';
    insert sett;

    List<Account> insertAccs = new List<Account>();
    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    Account accRec = new Account();
    accRec.RecordTypeId = recordTypeId;
    accRec.LastName = 'testing 123xdaa';
    accRec.Consent_Status__c = 'Withdrawn';
    accRec.PersonEmail = 'aa@bb.nl';
    insertAccs.add(accRec);
    insert insertAccs;

    accRec.Consent_Status__c = 'Withdrawn';
    accRec.HighCO_synced__c = true;
    update insertAccs;

    Account accrec2 = [
      SELECT PersonEmail
      FROM Account
      WHERE LastName = 'testing 123xdaa'
    ];

    HighcoRequest.deleteUser(accrec2.PersonEmail);
  }
}
