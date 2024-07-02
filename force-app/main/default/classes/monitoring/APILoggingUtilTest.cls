@isTest
public class APILoggingUtilTest {
  @IsTest(SeeAllData=true)
  // don't want to go through the hassle of creating an order just to get a passable reference...
  // once the test factory is setup, we can use that
  static void TestCreateProcessException() {
    Map<String, Object> results = RestServiceTestUtilities.setupTestData();
    Test.setMock(HttpCalloutMock.class, new SplunkAPIMock());
    String message = 'test message';
    String description = 'test description';
    Order order = [SELECT id FROM Order LIMIT 1];
    String category = 'test category';
    String transactionId = 'TESTTRANSACTIONID';
    // Call the method
    Test.startTest();
    APILoggingUtil.createProcessException(message, description, order, category, transactionId);
    ProcessException pe = [SELECT id, TransactionId__c FROM ProcessException ORDER BY createddate DESC LIMIT 1];
    Test.stopTest();
    System.assertEquals('TESTTRANSACTIONID', pe.TransactionId__c);
  }

  @isTest(SeeAllData=true)
  static void TestCreateProcessException2() {
    Map<String, Object> results = RestServiceTestUtilities.setupTestData();
    Test.setMock(HttpCalloutMock.class, new SplunkAPIMock());
    String message = 'test message';
    String description = 'test description';
    Order order = [SELECT id FROM Order LIMIT 1];
    String category = 'test category';
    String transactionId = 'TESTTRANSACTIONID';
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    // Call the method
    Test.startTest();
    APILoggingUtil.createProcessException(message, description, order, category, transactionId, req, res);
    ProcessException pe = [SELECT id, TransactionId__c FROM ProcessException ORDER BY createddate DESC LIMIT 1];
    Test.stopTest();
    System.assertEquals('TESTTRANSACTIONID', pe.TransactionId__c);
  }

  @isTest(SeeAllData=true)
  static void TestCreateProcessExceptionFO() {
    Map<String, Object> results = RestServiceTestUtilities.setupTestData();
    FulfillmentOrder fOrder = RestServiceTestUtilities.setupFulfillmentOrderData(
      ((OrderSummary) results.get('orderSummary')).Id,
      ((Account) results.get('account')).Id
    );
    Test.setMock(HttpCalloutMock.class, new SplunkAPIMock());
    String message = 'test message';
    String description = 'test description';
    String category = 'test category';
    String transactionId = 'TESTTRANSACTIONID';
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    // Call the method
    Test.startTest();
    APILoggingUtil.createProcessException(message, description, fOrder, category, transactionId, req, res);
    ProcessException pe = [SELECT id, TransactionId__c FROM ProcessException ORDER BY createddate DESC LIMIT 1];
    Test.stopTest();
    System.assertEquals('TESTTRANSACTIONID', pe.TransactionId__c);
  }

  @isTest(SeeAllData=true)
  static void TestCreateProcessExceptionShipment() {
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

    Shipment shipment = [SELECT Id, FulfillmentOrderId FROM Shipment WHERE FulfillmentOrderId = :fOrder.Id LIMIT 1];
    Test.setMock(HttpCalloutMock.class, new SplunkAPIMock());
    String message = 'test message';
    String description = 'test description';
    String category = 'test category';
    String transactionId = 'TESTTRANSACTIONID';
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    // Call the method
    Test.startTest();
    ProcessException processExc = new ProcessException();
    processExc.Status = 'New';
    processExc.Severity = 'Low';
    processExc.AttachedToId = shipment.FulfillmentOrderId;
    processExc.ExternalReference = ((Order) results.get('order')).OrderReferenceNumber;
    processExc.TransactionId__c = transactionId;
    processExc.Priority = 'Low';
    processExc.Category = category;
    processExc.Shipment__c = shipment.Id;
    processExc.Message = message;
    processExc.Description = description;
    insert processExc;
    Test.stopTest();
  }
}
