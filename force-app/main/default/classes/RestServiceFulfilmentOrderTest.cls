@isTest(SeeAllData=true)
public with sharing class RestServiceFulfilmentOrderTest {
  @isTest
  static void testFulfilmentOrder() {
    List<API_Endpoint__c> existingEndpoints = [
      SELECT Id
      FROM API_Endpoint__c
      WHERE Name = 'Fulfillment Order API Base Endpoint'
      LIMIT 1
    ];
    if (existingEndpoints.size() == 0) {
      API_Endpoint__c endpoint = new API_Endpoint__c();
      endpoint.Name = 'Fulfillment Order API Base Endpoint';
      endpoint.Base_URL__c = 'https://jdecoffee.com';
      insert endpoint;
    }
    Map<String, Object> results = RestServiceTestUtilities.setupTestData();
    FulfillmentOrder fOrder = RestServiceTestUtilities.setupFulfillmentOrderData(
      ((OrderSummary) results.get('orderSummary')).Id,
      ((Account) results.get('account')).Id
    );
    List<RestServiceInvocableAction> ids = new List<RestServiceInvocableAction>();
    RestServiceInvocableAction action = new RestServiceInvocableAction();
    action.Id = fOrder.Id;
    action.RetryNumber = 0;
    ids.add(action);
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new FulfilmentOrderCalloutMock());
    RestServiceFulfilmentOrder.getData(ids);
    Test.stopTest();
  }

  @isTest
  static void testFulfilmentOrderFailed() {
    List<API_Endpoint__c> existingEndpoints = [
      SELECT Id
      FROM API_Endpoint__c
      WHERE Name = 'Fulfillment Order API Base Endpoint'
      LIMIT 1
    ];
    if (existingEndpoints.size() == 0) {
      API_Endpoint__c endpoint = new API_Endpoint__c();
      endpoint.Name = 'Fulfillment Order API Base Endpoint';
      endpoint.Base_URL__c = 'https://jdecoffee.com';
      insert endpoint;
    }
    Map<String, Object> results = RestServiceTestUtilities.setupTestData();
    FulfillmentOrder fOrder = RestServiceTestUtilities.setupFulfillmentOrderData(
      ((OrderSummary) results.get('orderSummary')).Id,
      ((Account) results.get('account')).Id
    );
    List<RestServiceInvocableAction> ids = new List<RestServiceInvocableAction>();
    RestServiceInvocableAction action = new RestServiceInvocableAction();
    action.Id = fOrder.Id;
    action.RetryNumber = 0;
    ids.add(action);
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new FulfilmentOrderFailedCalloutMock());
    RestServiceFulfilmentOrder.getData(ids);
    Test.stopTest();
  }

  public class FulfilmentOrderCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success": true}');
      res.setStatusCode(200);
      return res;
    }
  }

  public class FulfilmentOrderFailedCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success": false}');
      res.setStatusCode(500);
      return res;
    }
  }
}
