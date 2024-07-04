@IsTest
public with sharing class WS_DE_ChangeEmailTest {
  @IsTest
  static void testchangeEmailSuccess() {
    Account a = new Account(
      FirstName = 'forTest',
      LastName = 'TESTFF',
      personEmail = 'test@testForTest.com'
    );
    insert a;

    String JSONMsg = '{"currentEmail" : "test@testForTest.com", "newEmail":"new@testForTest.com"}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/ChangeAccountEmail/' + a.Id;
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueof(JSONMsg);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    String rep = WS_DE_ChangeEmail.changeAccountEmail();
    System.debug(res.statusCode);
    System.assertEquals('Success', rep);
    System.assertEquals(200, res.statusCode);
    Test.stopTest();
  }
  @IsTest
  static void testNotFound() {
    String JSONMsg = '{"currentEmail" : "test@testForTest.com", "newEmail":"new@testForTest.com"}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/ChangeAccountEmail/' + 'WrongId';
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueof(JSONMsg);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    String rep = WS_DE_ChangeEmail.changeAccountEmail();
    System.debug(res.statusCode);
    System.assertEquals('Not found', rep);
    System.assertEquals(404, res.statusCode);
    Test.stopTest();
  }
  @IsTest
  static void testInvalidEmail() {
    Account a = new Account(
      FirstName = 'forTest',
      LastName = 'TESTFF',
      personEmail = 'test@testForTest.com'
    );
    insert a;

    String JSONMsg = '{"currentEmail" : "test@testForTest.com", "newEmail":"///qs"}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/ChangeAccountEmail/' + a.Id;
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueof(JSONMsg);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    String rep = WS_DE_ChangeEmail.changeAccountEmail();
    System.debug(res.statusCode);
    System.assertEquals(Label.DEInvalidEmailAddress, rep);
    System.assertEquals(400, res.statusCode);
    Test.stopTest();
  }

  @IsTest
  static void testBadRequest() {
    Account a = new Account(
      FirstName = 'forTest',
      LastName = 'TESTFF',
      personEmail = 'test@testForTest.com'
    );
    insert a;

    String JSONMsg = '{"currentEmail" : "otherEmail@testForTest.com", "newEmail": "newEmail@testForTest.com"}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/ChangeAccountEmail/' + a.Id;
    req.httpMethod = 'PATCH';
    req.requestBody = Blob.valueof(JSONMsg);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    String rep = WS_DE_ChangeEmail.changeAccountEmail();
    System.debug(res.statusCode);
    System.assertEquals('Bad request', rep);
    System.assertEquals(400, res.statusCode);
    Test.stopTest();
  }
}
