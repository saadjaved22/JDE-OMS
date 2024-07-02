@isTest
public class RestServiceCreateReservationTest {
  @testSetup
  static void setupTestData() {
    // Create test data for API_Endpoint__c
    API_Endpoint__c endpoint = new API_Endpoint__c();
    endpoint.Name = 'Create Reservation API Base Endpoint';
    endpoint.Base_URL__c = 'https://example.com/api/';
    insert endpoint;

    // Create test data for OCI_Commerce_API__c
    OCI_Commerce_API__c apiSettings = new OCI_Commerce_API__c();
    insert apiSettings;
  }

  @isTest
  static void testMakeReservation_Success() {
    // Create test data
    RestServiceOrderCreate.orderItemWrapper orderItem = new RestServiceOrderCreate.orderItemWrapper();
    orderItem.type = 'product';
    orderItem.sku = 'SKU001';
    orderItem.quantity = '10';
    RestServiceOrderCreate.orderItemWrapper[] orderItems = new List<RestServiceOrderCreate.orderItemWrapper>{
      orderItem
    };

    // Call the method
    Test.setMock(HttpCalloutMock.class, new ReservationCalloutMock());
    Test.startTest();
    Boolean result = RestServiceCreateReservation.makeReservation(
      'ORD001',
      'LOC001',
      orderItems,
      'Online',
      '123456',
      true
    );
    Test.stopTest();
    // Verify the result
    System.assertEquals(true, result);
  }

  @isTest
  static void testMakeReservation_Failure() {
    // Create test data
    RestServiceOrderCreate.orderItemWrapper orderItem = new RestServiceOrderCreate.orderItemWrapper();
    orderItem.type = 'product';
    orderItem.sku = 'SKU001';
    orderItem.quantity = '10';
    RestServiceOrderCreate.orderItemWrapper[] orderItems = new List<RestServiceOrderCreate.orderItemWrapper>{
      orderItem
    };

    // Call the method
    Test.setMock(HttpCalloutMock.class, new ReservationCalloutApiFailMock());
    Test.startTest();
    Boolean result = RestServiceCreateReservation.makeReservation(
      'ORD002',
      'LOC002',
      orderItems,
      'Online',
      '123456',
      true
    );
    Test.stopTest();
    // Verify the result
    System.assertEquals(false, result);
  }

  @isTest
  static void testMakeReservation_Exception() {
    // Create test data
    RestServiceOrderCreate.orderItemWrapper orderItem = new RestServiceOrderCreate.orderItemWrapper();
    orderItem.type = 'product';
    orderItem.sku = 'SKU001';
    orderItem.quantity = '10';
    RestServiceOrderCreate.orderItemWrapper[] orderItems = new List<RestServiceOrderCreate.orderItemWrapper>{
      orderItem
    };

    // Call the method
    Test.setMock(HttpCalloutMock.class, new ReservationCalloutApiFailMock());
    //No Test start-stop method, so the test method will throw the DML before callout error. And exception will be thrown.
    Boolean result = RestServiceCreateReservation.makeReservation(
      'ORD002',
      'LOC002',
      orderItems,
      'Online',
      '123456',
      true
    );
    // Verify the result
    ProcessException processException = [SELECT Id FROM ProcessException WHERE Category = 'Transfer Reservation'];
    System.assertNotEquals(null, processException, 'Process exception should be inserted.');
    System.assertEquals(false, result, 'Result should be false');
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

  public class ReservationCalloutApiFailMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success": false}');
      res.setStatusCode(200);
      return res;
    }
  }
}
