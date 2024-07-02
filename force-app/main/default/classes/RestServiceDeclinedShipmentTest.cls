@IsTest(SeeAllData=true)
public class RestServiceDeclinedShipmentTest {
  @IsTest
  static void testDeclinedShipment() {
    List<API_Endpoint__c> existingEndpoints = [
      SELECT Id
      FROM API_Endpoint__c
      WHERE Name = 'Declined Shipment API Base Endpoint'
      LIMIT 1
    ];
    if (existingEndpoints.size() == 0) {
      API_Endpoint__c endpoint = new API_Endpoint__c();
      endpoint.Name = 'Declined Shipment API Base Endpoint';
      endpoint.Base_URL__c = 'https://jdecoffee.com';
      insert endpoint;
    }

    Map<String, Object> results = RestServiceTestUtilities.setupTestData();
    FulfillmentOrder fOrder = RestServiceTestUtilities.setupFulfillmentOrderData(
      ((OrderSummary) results.get('orderSummary')).Id,
      ((Account) results.get('account')).Id
    );
    List<RestServiceShipment.orderItemWrapper> shippingOrderItems = new List<RestServiceShipment.orderItemWrapper>();
    RestServiceShipment.orderItemWrapper shippingOrderItem = new RestServiceShipment.orderItemWrapper();
    shippingOrderItem.aggregatedLineID = '1';
    shippingOrderItem.sku = ((Product2) results.get('product')).StockKeepingUnit;
    shippingOrderItem.shippedQuantity = '0';
    shippingOrderItem.declinedQuantity = '1';
    shippingOrderItems.add(shippingOrderItem);
    RestServiceShipment.createShipment(
      ((Order) results.get('order')).OrderReferenceNumber,
      fOrder.Fulfillment_Order_Id__c,
      'TRACKING1234',
      '2342341242123423',
      shippingOrderItems
    );

    DeclinedShipment__c declinedShipment = [
      SELECT Id
      FROM DeclinedShipment__c
      WHERE FulfillmentOrderId__c = :fOrder.Id
      LIMIT 1
    ];
    List<RestServiceInvocableAction> declinedShipmentIds = new List<RestServiceInvocableAction>();
    RestServiceInvocableAction action = new RestServiceInvocableAction();
    action.Id = declinedShipment.Id;
    action.RetryNumber = 0;
    declinedShipmentIds.add(action);
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new DeclinedShipmentCalloutMock());
    RestServiceDeclinedShipment.getData(declinedShipmentIds);
    Test.stopTest();
  }

  @IsTest
  static void testDeclinedShipmentFailedCallout() {
    List<API_Endpoint__c> existingEndpoints = [
      SELECT Id
      FROM API_Endpoint__c
      WHERE Name = 'Declined Shipment API Base Endpoint'
      LIMIT 1
    ];
    if (existingEndpoints.size() == 0) {
      API_Endpoint__c endpoint = new API_Endpoint__c();
      endpoint.Name = 'Declined Shipment API Base Endpoint';
      endpoint.Base_URL__c = 'https://jdecoffee.com';
      insert endpoint;
    }

    Map<String, Object> results = RestServiceTestUtilities.setupTestData();
    FulfillmentOrder fOrder = RestServiceTestUtilities.setupFulfillmentOrderData(
      ((OrderSummary) results.get('orderSummary')).Id,
      ((Account) results.get('account')).Id
    );
    List<RestServiceShipment.orderItemWrapper> shippingOrderItems = new List<RestServiceShipment.orderItemWrapper>();
    RestServiceShipment.orderItemWrapper shippingOrderItem = new RestServiceShipment.orderItemWrapper();
    shippingOrderItem.aggregatedLineID = '1';
    shippingOrderItem.sku = ((Product2) results.get('product')).StockKeepingUnit;
    shippingOrderItem.shippedQuantity = '0';
    shippingOrderItem.declinedQuantity = '1';
    shippingOrderItems.add(shippingOrderItem);
    RestServiceShipment.createShipment(
      ((Order) results.get('order')).OrderReferenceNumber,
      fOrder.Fulfillment_Order_Id__c,
      'TRACKING1234',
      '2342341242123423',
      shippingOrderItems
    );

    DeclinedShipment__c declinedShipment = [
      SELECT Id
      FROM DeclinedShipment__c
      WHERE FulfillmentOrderId__c = :fOrder.Id
      LIMIT 1
    ];
    List<RestServiceInvocableAction> declinedShipmentIds = new List<RestServiceInvocableAction>();
    RestServiceInvocableAction action = new RestServiceInvocableAction();
    action.Id = declinedShipment.Id;
    action.RetryNumber = 0;
    declinedShipmentIds.add(action);
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new DeclinedShipmentFailedCalloutMock());
    RestServiceDeclinedShipment.getData(declinedShipmentIds);
    Test.stopTest();
  }

  public class DeclinedShipmentCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success": true}');
      res.setStatusCode(200);
      return res;
    }
  }

  public class DeclinedShipmentFailedCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success": false}');
      res.setStatusCode(500);
      return res;
    }
  }
}
