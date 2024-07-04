@isTest(SeeAllData=true)
public with sharing class RestServiceShipmentTest {
  @isTest
  static void testShipment() {
    Test.setMock(HttpCalloutMock.class, new SplunkAPIMock());
    Map<String, Object> results = RestServiceTestUtilities.setupTestData();
    FulfillmentOrder fOrder = RestServiceTestUtilities.setupFulfillmentOrderData(
      ((OrderSummary) results.get('orderSummary')).Id,
      ((Account) results.get('account')).Id
    );
    List<RestServiceShipment.orderItemWrapper> shippingOrderItems = new List<RestServiceShipment.orderItemWrapper>();
    RestServiceShipment.orderItemWrapper shippingOrderItem = new RestServiceShipment.orderItemWrapper();
    shippingOrderItem.aggregatedLineID = '1';
    shippingOrderItem.sku = ((Product2) results.get('product'))
      .StockKeepingUnit;
    shippingOrderItem.shippedQuantity = '1';
    shippingOrderItem.declinedQuantity = '0';
    shippingOrderItems.add(shippingOrderItem);
    Test.startTest();
    RestServiceShipment.createShipment(
      ((Order) results.get('order')).OrderReferenceNumber,
      fOrder.Fulfillment_Order_Id__c,
      'TRACKING1234',
      '2342341242123423',
      shippingOrderItems
    );

    RestServiceShipment.createShipment(
      ((Order) results.get('order')).OrderReferenceNumber,
      fOrder.Fulfillment_Order_Id__c,
      'TRACKING1234',
      '2342341242123423',
      shippingOrderItems
    );
    Test.stopTest();
  }
}
