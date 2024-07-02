@isTest
public class SalesforceAdapterTest {
  @isTest
  static void testSalesforceAdapter() {
    // This class is not used as there is no payment integration yet
    // But for code coverage we still need to add this
    SalesforceAdapter adapter = new SalesforceAdapter();
    adapter.processRequest(null);
    adapter.createTokenizeResponse(null);
    adapter.createAuthResponse(null);
    adapter.createAuthReversalResponse(null);
    adapter.createCaptureResponse(null);
    adapter.createSaleResponse(null);
    adapter.createRefundResponse(null);
  }
}
