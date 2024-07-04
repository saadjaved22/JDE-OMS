@isTest
public class OCICommerceAPITest {
  @testSetup
  static void setup() {
    List<OCI_Stock__c> stockTestData = OCITestDataFactory.createOCIStockTestData(
      5
    );
  }

  @isTest
  static void TestGetAvailabilityDelta() {
    OCI_Commerce_API__c apiSettingsTestData = OCITestDataFactory.createOCICommerceAPITestData(
      'Test Delta Token',
      null
    );
    Test.setMock(HttpCalloutMock.class, new OCICommerceAPIMock());

    // Call the method
    Test.startTest();
    OCICommerceAPI.getAvailabilityUpdate();
    Test.stopTest();

    // Verify that the API settings have been updated
    OCI_Commerce_API__c apiSettings = [
      SELECT deltaToken__c, exportID__c
      FROM OCI_Commerce_API__c
      LIMIT 1
    ];
    System.assertEquals('testtoken', apiSettings.deltaToken__c);
    System.assertEquals(null, apiSettings.exportID__c);
  }

  @isTest
  static void TestRequestAvailabilityExport() {
    OCI_Commerce_API__c apiSettingsTestData = OCITestDataFactory.createOCICommerceAPITestData(
      null,
      null
    );
    Test.setMock(HttpCalloutMock.class, new OCICommerceAPIMock());

    // Call the method
    Test.startTest();
    OCICommerceAPI.getAvailabilityUpdate();
    Test.stopTest();

    // Verify that the API settings have been updated
    OCI_Commerce_API__c apiSettings = [
      SELECT deltaToken__c, exportID__c
      FROM OCI_Commerce_API__c
      LIMIT 1
    ];
    System.assertEquals(null, apiSettings.deltaToken__c);
    System.assertEquals('export-id', apiSettings.exportID__c);
  }

  @isTest
  static void TestGetAvailabilityExport() {
    OCI_Commerce_API__c apiSettingsTestData = OCITestDataFactory.createOCICommerceAPITestData(
      null,
      'export-id'
    );
    Test.setMock(HttpCalloutMock.class, new OCICommerceAPIMock());

    // Call the method
    Test.startTest();
    OCICommerceAPI.getAvailabilityUpdate();
    Test.stopTest();

    // Verify that the API settings have been updated
    OCI_Commerce_API__c apiSettings = [
      SELECT deltaToken__c, exportID__c
      FROM OCI_Commerce_API__c
      LIMIT 1
    ];
    System.assertEquals('test-token', apiSettings.deltaToken__c);
    System.assertEquals(null, apiSettings.exportID__c);
  }

  @isTest
  static void TestResetAvailability() {
    OCI_Commerce_API__c apiSettingsTestData = OCITestDataFactory.createOCICommerceAPITestData(
      'Test Delta Token',
      null
    );

    // Call the method
    Test.startTest();
    OCICommerceAPI.resetAvailability();
    Test.stopTest();

    // Verify that the API settings have been updated
    OCI_Commerce_API__c apiSettings = [
      SELECT deltaToken__c, exportID__c
      FROM OCI_Commerce_API__c
      LIMIT 1
    ];
    System.assertEquals(null, apiSettings.deltaToken__c);
    // Verify that all OCI_Stock__c is gone
    List<OCI_Stock__c> li = [SELECT Id FROM OCI_Stock__c];
    System.assertEquals(0, li.size());
  }

  @IsTest
  static void TestUpdateSafetyStock() {
    List<OCICommerceAPI.safetyStockAtLocation> sSAtLocs = new List<OCICommerceAPI.safetyStockAtLocation>();
    OCICommerceAPI.safetyStockAtLocation sSA = new OCICommerceAPI.safetyStockAtLocation();
    sSA.location = 'Test Location';
    sSA.safetyStock = 3;
    sSAtLocs.add(sSA);

    // Call the method
    Test.setMock(HttpCalloutMock.class, new OCICommerceAPIMock());
    Test.startTest();
    OCICommerceAPI.updateSafetyStock(sSAtLocs);
    Test.stopTest();

    // Verify that all OCI_Stock__c in Test Location has safety stock 3
    List<OCI_Stock__c> stockList = [
      SELECT Id, safetyStockCount__c
      FROM OCI_Stock__c
      WHERE Location__r.name = 'Test Location'
    ];
    for (OCI_Stock__c stock : stockList) {
      System.assertEquals(3, stock.safetyStockCount__c);
    }
  }
  /*
    @isTest
    static void testResetAvailability() {
        // Create test data
        Schema.Location location = new Schema.Location (
            ExternalReference = 'TestLocation'
        );
        insert location;

        OCI_Stock__c stock = new OCI_Stock__c(
            SKU__c = 'TestSKU',
            location__c = location.Id
        );
        insert stock;

        OCI_Commerce_API__c apiSettings = new OCI_Commerce_API__c(
            deltaToken__c = 'TestDeltaToken'
        );
        insert apiSettings;

        // Call the method
        Test.startTest();
        OCICommerceAPI oa = new OCICommerceAPI ();
        oa.resetAvailability();
        Test.stopTest();

        // Verify that all the availability records have been deleted and deltaToken has been reset
        List<OCI_Stock__c> stockList = [SELECT Id FROM OCI_Stock__c];
        System.assertEquals(0, stockList.size());

        apiSettings = [SELECT deltaToken__c FROM OCI_Commerce_API__c LIMIT 1];
        System.assertEquals(null, apiSettings.deltaToken__c);
    }

    @isTest
    static void testUpdateSafetyStock() {
        // Create test data
        Schema.Location location = new Schema.Location (
            ExternalReference = 'TestLocation'
        );
        insert location;

        OCI_Stock__c stock = new OCI_Stock__c(
            SKU__c = 'TestSKU',
            location__c = location.Id
        );
        insert stock;

        OCI_Commerce_API__c apiSettings = new OCI_Commerce_API__c(
            deltaToken__c = 'TestDeltaToken'
        );
        insert apiSettings;

        List<OCICommerceAPI.safetyStockAtLocation> sSAtLocs = new List<OCICommerceAPI.safetyStockAtLocation> ();

        OCICommerceAPI.safetyStockAtLocation sSAtLoc = new OCICommerceAPI.safetyStockAtLocation ();
        sSAtLoc.location = 'TestLocation';
        sSAtLoc.safetyStock = 10;
        sSAtLocs.add(sSAtLoc);


        // Call the method
        Test.startTest();
        OCICommerceAPI.updateSafetyStock(sSAtLocs);
        Test.stopTest();

        // Verify that safetyStockCount has been updated
        stock = [SELECT safetyStockCount__c FROM OCI_Stock__c WHERE Id = :stock.Id];
        System.assertEquals(10, stock.safetyStockCount__c);
    }
*/
}
