@isTest
public class IERRelatedListController_Test {
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
  static void IERRelatedListPageResultWithPageSize1() {
    IERRelatedList__c IERSetting = new IERRelatedList__c();
    IERSetting.Client_ID__c = 'testClientID';
    IERSetting.Client_Secret__c = 'testClientSecret';
    IERSetting.Page_Size__c = 1;
    insert IERSetting;

    Account testAcc2 = new Account();
    testAcc2.Name = 'TESTACCOUNT';
    testAcc2.Id = '0016E00000Y0ySZ';
    Test.setMock(HttpCalloutMock.class, new IERHTTPCalloutMock());
    PageReference pageRef = Page.IERRelatedList;
    Test.setCurrentPage(pageRef);
    test.startTest();
    IERRelatedListController IERCont = new IERRelatedListController(
      new ApexPages.StandardController(testAcc2)
    );
    IERCont.moveToNext();
    IERCont.moveToPrev();
    IERCont.moveToLast();
    test.stopTest();
  }
  @isTest
  static void IERRelatedListPageResultWithPageSize0() {
    IERRelatedList__c IERSetting = new IERRelatedList__c();
    IERSetting.Client_ID__c = 'testClientID';
    IERSetting.Client_Secret__c = 'testClientSecret';
    IERSetting.Page_Size__c = 0;
    insert IERSetting;

    Account testAcc2 = new Account();
    testAcc2.Name = 'TESTACCOUNT';
    testAcc2.Id = '0016E00000Y0ySZ';
    Test.setMock(HttpCalloutMock.class, new IERHTTPCalloutMock());
    PageReference pageRef = Page.IERRelatedList;
    Test.setCurrentPage(pageRef);
    test.startTest();
    IERRelatedListController IERCont = new IERRelatedListController(
      new ApexPages.StandardController(testAcc2)
    );
    test.stopTest();
  }
  @isTest
  static void IERRelatedListPageResultWithPageSize0NotInConsumerDetailPage() {
    IERRelatedList__c IERSetting = new IERRelatedList__c();
    IERSetting.Client_ID__c = 'testClientID';
    IERSetting.Client_Secret__c = 'testClientSecret';
    IERSetting.Page_Size__c = 0;
    insert IERSetting;

    Account testAcc2 = new Account();
    testAcc2.Name = 'TESTACCOUNT';
    Test.setMock(HttpCalloutMock.class, new IERHTTPCalloutMock());
    PageReference pageRef = Page.IERRelatedList;
    Test.setCurrentPage(pageRef);
    test.startTest();
    IERRelatedListController IERCont = new IERRelatedListController(
      new ApexPages.StandardController(testAcc2)
    );
    test.stopTest();
  }
}
