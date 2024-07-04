@isTest
public class lightningIERController_Test {
  @isTest
  static void testCallout() {
    Test.setMock(HttpCalloutMock.class, new IERHTTPCalloutMock());
    string accessToken = IERRelatedListHelper.getMarketingCloudOAuthToken(
      'testClientID',
      'testClientSecret'
    );
    string responseXML = IERRelatedListHelper.performMCAction(
      accessToken,
      'testOnly'
    );
    IERRelatedListHelper.XMLParserResult parserResult = new IERRelatedListHelper.XMLParserResult();
    parserResult = IERRelatedListHelper.XMLParser(responseXML);
  }
  @isTest
  static void lightningIER() {
    IERRelatedList__c IERSetting = new IERRelatedList__c();
    IERSetting.Client_ID__c = 'testClientID';
    IERSetting.Client_Secret__c = 'testClientSecret';
    insert IERSetting;

    String RecTypeId = [
      SELECT Id
      FROM RecordType
      WHERE Name = 'Person Account' AND SobjectType = 'Account'
    ]
    .Id;
    Account Accnt = new Account(
      RecordTypeID = RecTypeId,
      FirstName = 'Test FName',
      LastName = 'Test LName'
    );

    insert Accnt;
    Test.setMock(HttpCalloutMock.class, new IERHTTPCalloutMock());
    test.startTest();
    lightningIERController.lightningIER(Accnt.Id);
    test.stopTest();
  }
}
