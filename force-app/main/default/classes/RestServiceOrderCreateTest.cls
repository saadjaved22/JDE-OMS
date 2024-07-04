@isTest
public class RestServiceOrderCreateTest {
  @TestSetup
  static void makeData() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    List<API_Endpoint__c> endpointList = [
      SELECT id
      FROM API_Endpoint__c
      WHERE Name LIKE 'Create Reservation API Base Endpoint'
      LIMIT 1
    ];
    if (endpointList.size() == 0) {
      API_Endpoint__c endpoint = new API_Endpoint__c();
      endpoint.Name = 'Create Reservation API Base Endpoint';
      endpoint.Base_URL__c = 'https://jdecoffee.com';
      insert endpoint;
    }
    List<API_Endpoint__c> failedEndpointList = [
      SELECT id
      FROM API_Endpoint__c
      WHERE Name LIKE 'Reservation Failed API Endpoint'
      LIMIT 1
    ];
    if (failedEndpointList.size() == 0) {
      API_Endpoint__c endpoint = new API_Endpoint__c();
      endpoint.Name = 'Reservation Failed API Endpoint';
      endpoint.Base_URL__c = 'https://jdecoffee.com';
      insert endpoint;
    }

    req.requestURI = '/salesorder/create/v1/LOR/NL/LTEST10009709'; //Request URL
    req.httpMethod = 'POST'; //HTTP Request Type
    RestContext.request = req;
    RestContext.response = res;

    List<SalesChannel> sCList = [
      SELECT id
      FROM SalesChannel
      WHERE ExternalChannelNumber LIKE 'LDE_NL'
      LIMIT 1
    ];
    if (sCList.size() == 0) {
      SalesChannel salesChannel = new SalesChannel(
        ExternalChannelNumber = 'LDE_NL',
        SalesChannelName = 'LDE_NL'
      );
      insert salesChannel;
    }

    List<LocationGroup> locationGroups = [
      SELECT ID
      FROM LocationGroup
      WHERE ExternalReference LIKE 'NL'
      LIMIT 1
    ];
    if (locationGroups.size() == 0) {
      LocationGroup locationGroup = new LocationGroup(
        ExternalReference = 'NL',
        LocationGroupName = 'NL'
      );
      insert locationGroup;
    }

    List<Product2> deliveryMethodProducts = [
      SELECT ID
      FROM Product2
      WHERE StockKeepingUnit LIKE 'Home_NL'
      LIMIT 1
    ];
    Product2 prodObj;
    if (deliveryMethodProducts.size() == 0) {
      prodObj = new Product2();
      prodObj.Name = 'Home delivery';
      prodObj.StockKeepingUnit = 'Home_NL';
      insert prodObj;
    } else {
      prodObj = deliveryMethodProducts[0];
    }

    List<OrderDeliveryMethod> orderDeliveryMethods = [
      SELECT Id
      FROM OrderDeliveryMethod
      WHERE ReferenceNumber LIKE 'Home_NL'
      LIMIT 1
    ];
    if (orderDeliveryMethods.size() == 0) {
      OrderDeliveryMethod orderDeliveryMethod = new OrderDeliveryMethod();
      orderDeliveryMethod.ReferenceNumber = 'Home_NL';
      orderDeliveryMethod.ProductId = prodObj.Id;
      orderDeliveryMethod.Name = 'Home';
      insert orderDeliveryMethod;
    }
    List<OCI_Commerce_API__c> apiSettingsList = [
      SELECT Id
      FROM OCI_Commerce_API__c
      LIMIT 1
    ];
    if (apiSettingsList.size() == 0) {
      OCI_Commerce_API__c APIsettings = new OCI_Commerce_API__c();
      insert APIsettings;
    }
  }

  @isTest
  static void testRestAPI() {
    RestServiceOrderCreate.accountWrapper account = new RestServiceOrderCreate.accountWrapper();
    account.isGuestCheckout = 'true';
    account.externalID = '536245';
    account.firstname = 'Unit';
    account.lastname = 'Test';
    account.emailAddress = 'unit.test@jdecoffee.com';
    RestServiceOrderCreate.salesChannelWrapper salesChannel = new RestServiceOrderCreate.salesChannelWrapper();
    salesChannel.salesChannelID = 'LDE';
    salesChannel.countryCode = 'NL';
    RestServiceOrderCreate.addressWrapper billingAddress = new RestServiceOrderCreate.addressWrapper();
    billingAddress.firstName = 'TestName';
    billingAddress.lastName = 'TestLastName';
    billingAddress.city = 'Abbeville';
    billingAddress.country = 'FR';
    billingAddress.countryCode = 'FR';
    billingAddress.emailAddress = 'unit.test@jdecoffee.com';
    billingAddress.street = '51 Chemin de sur Somme à Lavier';
    billingAddress.postalCode = '80100';
    RestServiceOrderCreate.addressWrapper shippingAddress = new RestServiceOrderCreate.addressWrapper();
    shippingAddress.firstName = 'TestName';
    shippingAddress.lastName = 'TestLastName';
    shippingAddress.city = 'Abbeville';
    shippingAddress.country = 'FR';
    shippingAddress.countryCode = 'FR';
    shippingAddress.emailAddress = 'testing.testt@mintestinaloms.yu';
    shippingAddress.street = '51 Chemin de sur Somme à Lavier';
    shippingAddress.postalCode = '80100';
    List<RestServiceOrderCreate.orderItemWrapper> orderItems = new List<RestServiceOrderCreate.orderItemWrapper>();
    RestServiceOrderCreate.orderItemWrapper orderItem = new RestServiceOrderCreate.orderItemWrapper();
    orderItem.itemID = '626869';
    orderItem.grossUnitPrice = '9.98';
    orderItem.sku = 'TestSKU_4061683';
    orderItem.productName = '2 Tasses lungo';
    orderItem.quantity = '5';
    orderItem.totalLineAmount = '24.96';
    orderItem.type = 'simple';
    orderItem.unitPrice = '8.32';
    orderItem.orderItemTax = new RestServiceOrderCreate.orderItemTaxWrapper();
    orderItem.orderItemTax.amount = '4.99';
    orderItem.orderItemTax.rate = '20';
    List<RestServiceOrderCreate.orderItemAdjustmentWrapper> orderItemAdjustments = new List<RestServiceOrderCreate.orderItemAdjustmentWrapper>();
    RestServiceOrderCreate.orderItemAdjustmentWrapper orderItemAdjustment = new RestServiceOrderCreate.orderItemAdjustmentWrapper();
    orderItemAdjustment.amount = '0';
    orderItemAdjustment.orderItemAdjustmentTax = new RestServiceOrderCreate.orderItemTaxWrapper();
    orderItemAdjustment.orderItemAdjustmentTax.amount = '0';
    orderItemAdjustment.orderItemAdjustmentTax.rate = '20';
    orderItemAdjustments.add(orderItemAdjustment);
    orderItem.orderItemAdjustments = orderItemAdjustments;
    orderItems.add(orderItem);

    RestServiceOrderCreate.orderItemWrapper orderItem2 = new RestServiceOrderCreate.orderItemWrapper();
    orderItem2.itemID = '626869';
    orderItem2.grossUnitPrice = '9.98';
    orderItem2.sku = 'TestSKU_4061683';
    orderItem2.productName = '2 Tasses lungo';
    orderItem2.quantity = '5';
    orderItem2.totalLineAmount = '24.96';
    orderItem2.type = 'simple';
    orderItem2.unitPrice = '8.32';
    orderItem2.orderItemTax = new RestServiceOrderCreate.orderItemTaxWrapper();
    orderItem2.orderItemTax.amount = '4.99';
    orderItem2.orderItemTax.rate = '20';
    List<RestServiceOrderCreate.orderItemAdjustmentWrapper> orderItem2Adjustments = new List<RestServiceOrderCreate.orderItemAdjustmentWrapper>();
    RestServiceOrderCreate.orderItemAdjustmentWrapper orderItem2Adjustment = new RestServiceOrderCreate.orderItemAdjustmentWrapper();
    orderItem2Adjustment.amount = '0';
    orderItem2Adjustment.orderItemAdjustmentTax = new RestServiceOrderCreate.orderItemTaxWrapper();
    orderItem2Adjustment.orderItemAdjustmentTax.amount = '0';
    orderItem2Adjustment.orderItemAdjustmentTax.rate = '20';
    orderItem2Adjustments.add(orderItem2Adjustment);
    orderItem2.orderItemAdjustments = orderItem2Adjustments;
    orderItems.add(orderItem2);
    List<RestServiceOrderCreate.paymentWrapper> payments = new List<RestServiceOrderCreate.paymentWrapper>();
    RestServiceOrderCreate.paymentWrapper payment = new RestServiceOrderCreate.paymentWrapper();
    payment.referenceId = 'BWR42FMJQGNG5S82';
    payment.method = 'adyen_cc';
    payment.cardType = 'Visa';
    payment.amount = '32.93';
    payment.status = 'Processed';
    payments.add(payment);

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new ReservationCalloutMock());

    RestServiceOrderCreate.getData(
      '2023-04-23',
      'ORDERUNITTEST',
      '214596',
      'Unit test',
      '2023-04-14 11:08:48',
      'EUR',
      'home',
      '2.99',
      '2.49',
      '',
      'Test',
      'I12345',
      '12345678978954561',
      '',
      account,
      salesChannel,
      billingAddress,
      shippingAddress,
      orderItems,
      payments
    );
    Test.stopTest();
  }

  @isTest
  static void testRestAPIFailedReservation() {
    RestServiceOrderCreate.accountWrapper account = new RestServiceOrderCreate.accountWrapper();
    account.isGuestCheckout = 'true';
    account.externalID = '536245';
    account.firstname = 'Unit';
    account.lastname = 'Test';
    account.emailAddress = 'unit.test@jdecoffee.com';
    RestServiceOrderCreate.salesChannelWrapper salesChannel = new RestServiceOrderCreate.salesChannelWrapper();
    salesChannel.salesChannelID = 'LDE';
    salesChannel.countryCode = 'NL';
    RestServiceOrderCreate.addressWrapper billingAddress = new RestServiceOrderCreate.addressWrapper();
    billingAddress.firstName = 'TestName';
    billingAddress.lastName = 'TestLastName';
    billingAddress.city = 'Abbeville';
    billingAddress.country = 'FR';
    billingAddress.countryCode = 'FR';
    billingAddress.emailAddress = 'unit.test@jdecoffee.com';
    billingAddress.street = '51 Chemin de sur Somme à Lavier';
    billingAddress.postalCode = '80100';
    RestServiceOrderCreate.addressWrapper shippingAddress = new RestServiceOrderCreate.addressWrapper();
    shippingAddress.firstName = 'TestName';
    shippingAddress.lastName = 'TestLastName';
    shippingAddress.city = 'Abbeville';
    shippingAddress.country = 'FR';
    shippingAddress.countryCode = 'FR';
    shippingAddress.emailAddress = 'testing.testt@mintestinaloms.yu';
    shippingAddress.street = '51 Chemin de sur Somme à Lavier';
    shippingAddress.postalCode = '80100';
    List<RestServiceOrderCreate.orderItemWrapper> orderItems = new List<RestServiceOrderCreate.orderItemWrapper>();
    RestServiceOrderCreate.orderItemWrapper orderItem = new RestServiceOrderCreate.orderItemWrapper();
    orderItem.itemID = '626869';
    orderItem.grossUnitPrice = '9.98';
    orderItem.sku = 'TestSKU_4061683';
    orderItem.productName = '2 Tasses lungo';
    orderItem.quantity = '5';
    orderItem.totalLineAmount = '24.96';
    orderItem.type = 'simple';
    orderItem.unitPrice = '8.32';
    orderItem.orderItemTax = new RestServiceOrderCreate.orderItemTaxWrapper();
    orderItem.orderItemTax.amount = '4.99';
    orderItem.orderItemTax.rate = '20';
    List<RestServiceOrderCreate.orderItemAdjustmentWrapper> orderItemAdjustments = new List<RestServiceOrderCreate.orderItemAdjustmentWrapper>();
    RestServiceOrderCreate.orderItemAdjustmentWrapper orderItemAdjustment = new RestServiceOrderCreate.orderItemAdjustmentWrapper();
    orderItemAdjustment.amount = '0';
    orderItemAdjustment.orderItemAdjustmentTax = new RestServiceOrderCreate.orderItemTaxWrapper();
    orderItemAdjustment.orderItemAdjustmentTax.amount = '0';
    orderItemAdjustment.orderItemAdjustmentTax.rate = '20';
    orderItemAdjustments.add(orderItemAdjustment);
    orderItem.orderItemAdjustments = orderItemAdjustments;
    orderItems.add(orderItem);
    List<RestServiceOrderCreate.paymentWrapper> payments = new List<RestServiceOrderCreate.paymentWrapper>();
    RestServiceOrderCreate.paymentWrapper payment = new RestServiceOrderCreate.paymentWrapper();
    payment.referenceId = 'BWR42FMJQGNG5S82';
    payment.method = 'adyen_cc';
    payment.cardType = 'Visa';
    payment.amount = '32.93';
    payment.status = 'Processed';
    payments.add(payment);

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new ReservationFailedCalloutMock());

    RestServiceOrderCreate.getData(
      '2023-04-23',
      'ORDERUNITTEST',
      '214596',
      'Unit test',
      '2023-04-14 11:08:48',
      'EUR',
      'home',
      '2.99',
      '2.49',
      '',
      'Test',
      'I12345',
      '12345678978954561',
      '',
      account,
      salesChannel,
      billingAddress,
      shippingAddress,
      orderItems,
      payments
    );
    Test.stopTest();
  }

  public class ReservationCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success": true}');
      res.setStatusCode(200);
      return res;
    }
  }
  public class ReservationFailedCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success": false}');
      res.setStatusCode(500);
      return res;
    }
  }
}
