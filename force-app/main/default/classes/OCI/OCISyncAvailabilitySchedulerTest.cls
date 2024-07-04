@isTest
public class OCISyncAvailabilitySchedulerTest {
  @isTest
  static void testExecute() {
    OCI_Commerce_API__c apiSettingsTestData = OCITestDataFactory.createOCICommerceAPITestData(
      null,
      null
    );
    Test.setMock(HttpCalloutMock.class, new OCICommerceAPIMock());

    OCISyncAvailabilityScheduler scheduler = new OCISyncAvailabilityScheduler();

    Test.startTest();
    scheduler.execute(null);
    Test.stopTest();
  }
}
