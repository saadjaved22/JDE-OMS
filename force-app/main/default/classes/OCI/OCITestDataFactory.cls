public with sharing class OCITestDataFactory {
  public static List<OCI_Stock__c> createOCIStockTestData(
    Integer numberOfRecords
  ) {
    Schema.Location loc = new Schema.Location(
      name = 'Test Location',
      externalReference = 'Test Location'
    );
    insert loc;
    List<OCI_Stock__c> stockRecords = new List<OCI_Stock__c>();
    for (Integer i = 0; i < numberOfRecords; i++) {
      OCI_Stock__c stock = new OCI_Stock__c(
        id__c = 'Test Stock ' + i,
        Name = 'Test Stock ' + i,
        SKU__c = 'SKU-' + i,
        location__c = loc.id,
        safetyStockCount__c = i
      );
      stockRecords.add(stock);
    }
    insert stockRecords;
    return stockRecords;
  }

  public static OCI_Commerce_API__c createOCICommerceAPITestData(
    String deltaToken,
    String exportId
  ) {
    OCI_Commerce_API__c apiSettings = new OCI_Commerce_API__c(
      organisationID__c = 'Test Org ID',
      deltaToken__c = deltaToken,
      exportID__c = exportId
    );
    insert apiSettings;
    return apiSettings;
  }
}
