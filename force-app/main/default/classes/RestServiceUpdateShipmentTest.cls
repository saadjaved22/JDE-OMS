@IsTest(SeeAllData=true)
public class RestServiceUpdateShipmentTest {
  @IsTest
  static void testUpdateShipment() {
    List<API_Endpoint__c> existingEndpoints = [
      SELECT Id
      FROM API_Endpoint__c
      WHERE Name = 'Update Shipment API Base Endpoint'
      LIMIT 1
    ];
    if (existingEndpoints.size() == 0) {
      API_Endpoint__c endpoint = new API_Endpoint__c();
      endpoint.Name = 'Update Shipment API Base Endpoint';
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
    shippingOrderItem.shippedQuantity = '1';
    shippingOrderItem.declinedQuantity = '0';
    shippingOrderItems.add(shippingOrderItem);
    RestServiceShipment.createShipment(
      ((Order) results.get('order')).OrderReferenceNumber,
      fOrder.Fulfillment_Order_Id__c,
      'TRACKING1234',
      '2342341242123423',
      shippingOrderItems
    );

    Shipment shipment = [SELECT Id FROM Shipment WHERE FulfillmentOrderId = :fOrder.Id LIMIT 1];
    List<RestServiceInvocableAction> ids = new List<RestServiceInvocableAction>();
    RestServiceInvocableAction action = new RestServiceInvocableAction();
    action.Id = shipment.Id;
    action.RetryNumber = 0;
    ids.add(action);
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new UpdateShipmentCalloutMock());
    RestServiceUpdateShipment.getData(ids);
    Test.stopTest();
  }

  @IsTest
  static void testUpdateShipmentFailed() {
    List<API_Endpoint__c> existingEndpoints = [
      SELECT Id
      FROM API_Endpoint__c
      WHERE Name = 'Update Shipment API Base Endpoint'
      LIMIT 1
    ];
    if (existingEndpoints.size() == 0) {
      API_Endpoint__c endpoint = new API_Endpoint__c();
      endpoint.Name = 'Update Shipment API Base Endpoint';
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
    shippingOrderItem.shippedQuantity = '1';
    shippingOrderItem.declinedQuantity = '0';
    shippingOrderItems.add(shippingOrderItem);
    RestServiceShipment.createShipment(
      ((Order) results.get('order')).OrderReferenceNumber,
      fOrder.Fulfillment_Order_Id__c,
      'TRACKING1234',
      '2342341242123423',
      shippingOrderItems
    );

    Shipment shipment = [SELECT Id FROM Shipment WHERE FulfillmentOrderId = :fOrder.Id LIMIT 1];
    List<RestServiceInvocableAction> ids = new List<RestServiceInvocableAction>();
    RestServiceInvocableAction action = new RestServiceInvocableAction();
    action.Id = shipment.Id;
    action.RetryNumber = 0;
    ids.add(action);
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new UpdateShipmentFailedCalloutMock());
    RestServiceUpdateShipment.getData(ids);
    Test.stopTest();
  }

  public class UpdateShipmentCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success": true}');
      res.setStatusCode(200);
      return res;
    }
  }

  public class UpdateShipmentFailedCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success": false}');
      res.setStatusCode(500);
      return res;
    }
  }
}
