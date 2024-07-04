@isTest
public with sharing class RestServiceReturnOrderTest {
  @isTest(SeeAllData=true)
  static void testReturnOrder() {
    List<API_Endpoint__c> existingEndpoints = [
      SELECT Id
      FROM API_Endpoint__c
      WHERE Name = 'Return API Base URL'
      LIMIT 1
    ];
    if (existingEndpoints.size() == 0) {
      API_Endpoint__c endpoint = new API_Endpoint__c();
      endpoint.Name = 'Return API Base URL';
      endpoint.Base_URL__c = 'https://jdecoffee.com';
      insert endpoint;
    }
    Map<String, Object> results = RestServiceTestUtilities.setupTestData();

    ReturnOrder returnOrder = new ReturnOrder();
    returnOrder.AccountId = ((Account) results.get('account')).Id;
    returnOrder.DestinationLocationId = ((Schema.Location) results.get(
        'location'
      ))
      .Id;
    returnOrder.SourceLocationId = ((Schema.Location) results.get('location'))
      .Id;
    returnOrder.OrderId = ((Order) results.get('order')).id;
    returnOrder.OrderSummaryId = ((OrderSummary) results.get('orderSummary'))
      .Id;
    returnOrder.Status = 'Submitted';
    insert returnOrder;

    ReturnOrderLineItem returnOrderLineItemRecord = new ReturnOrderLineItem(
      reasonForReturn = 'R - Delivery was to late',
      QuantityReceived = 1.0,
      Type = 'Order Product',
      ReturnOrderId = returnOrder.Id
    );
    insert returnOrderLineItemRecord;
    List<RestServiceInvocableAction> ids = new List<RestServiceInvocableAction>();
    RestServiceInvocableAction action = new RestServiceInvocableAction();
    action.Id = returnOrder.Id;
    action.RetryNumber = 0;
    ids.add(action);

    test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new RestServiceReturnOrderCalloutMock()
    );
    RestServiceReturnOrder.getData(ids);
    test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void testReturnOrderFailed() {
    List<API_Endpoint__c> existingEndpoints = [
      SELECT Id
      FROM API_Endpoint__c
      WHERE Name = 'Return API Base URL'
      LIMIT 1
    ];
    if (existingEndpoints.size() == 0) {
      API_Endpoint__c endpoint = new API_Endpoint__c();
      endpoint.Name = 'Return API Base URL';
      endpoint.Base_URL__c = 'https://jdecoffee.com';
      insert endpoint;
    }
    Map<String, Object> results = RestServiceTestUtilities.setupTestData();

    ReturnOrder returnOrder = new ReturnOrder();
    returnOrder.AccountId = ((Account) results.get('account')).Id;
    returnOrder.DestinationLocationId = ((Schema.Location) results.get(
        'location'
      ))
      .Id;
    returnOrder.SourceLocationId = ((Schema.Location) results.get('location'))
      .Id;
    returnOrder.OrderId = ((Order) results.get('order')).id;
    returnOrder.OrderSummaryId = ((OrderSummary) results.get('orderSummary'))
      .Id;
    returnOrder.Status = 'Submitted';
    insert returnOrder;

    ReturnOrderLineItem returnOrderLineItemRecord = new ReturnOrderLineItem(
      reasonForReturn = 'R - Delivery was to late',
      QuantityReceived = 1.0,
      Type = 'Order Product',
      ReturnOrderId = returnOrder.Id
    );
    insert returnOrderLineItemRecord;
    List<RestServiceInvocableAction> ids = new List<RestServiceInvocableAction>();
    RestServiceInvocableAction action = new RestServiceInvocableAction();
    action.Id = returnOrder.Id;
    action.RetryNumber = 0;
    ids.add(action);

    test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new RestServiceReturnOrderFailedCalloutMock()
    );
    RestServiceReturnOrder.getData(ids);
    test.stopTest();
  }

  public class RestServiceReturnOrderCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success": true}');
      res.setStatusCode(200);
      return res;
    }
  }

  public class RestServiceReturnOrderFailedCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success": false}');
      res.setStatusCode(500);
      return res;
    }
  }
}
