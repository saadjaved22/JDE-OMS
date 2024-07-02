@isTest
public with sharing class RestServiceCreditRefundTest {
  @isTest(SeeAllData=true)
  static void testReturnOrder() {
    List<API_Endpoint__c> existingEndpoints = [
      SELECT Id
      FROM API_Endpoint__c
      WHERE Name = 'Credit Refund API Endpoint'
      LIMIT 1
    ];

    if (existingEndpoints.size() == 0) {
      API_Endpoint__c endpoint = new API_Endpoint__c();
      endpoint.Name = 'Credit Refund API Endpoint';
      endpoint.Base_URL__c = 'https://jdecoffee.com';
      insert endpoint;
    }

    Map<String, Object> results = RestServiceTestUtilities.setupTestData();
    Id orderSummaryId = ((OrderSummary) results.get('orderSummary')).Id;

    FulfillmentOrder fOrder = RestServiceTestUtilities.setupFulfillmentOrderData(
      orderSummaryId,
      ((Account) results.get('account')).Id
    );

    OrderItemSummary orderItemSummary = [
      SELECT Id
      FROM OrderItemSummary
      WHERE TypeCode != 'Charge' AND OrderSummaryId = :orderSummaryId
      LIMIT 1
    ];

    ConnectApi.AdjustOrderItemSummaryInputRepresentation adjustInput = new ConnectApi.AdjustOrderItemSummaryInputRepresentation();
    ConnectApi.AdjustItemInputRepresentation adjustItem = new ConnectApi.AdjustItemInputRepresentation();
    adjustItem.adjustmentType = 'Percentage';
    adjustItem.amount = -50.0;
    adjustItem.orderItemSummaryId = orderItemSummary.Id;
    adjustItem.reason = 'Unknown';
    adjustInput.adjustItems = new List<ConnectApi.AdjustItemInputRepresentation>();
    adjustInput.adjustItems.add(adjustItem);
    ConnectApi.AdjustOrderSummaryOutputRepresentation output = ConnectApi.OrderSummary.adjustSubmit(
      orderSummaryId,
      adjustInput
    );

    ConnectApi.CreateCreditMemoInputRepresentation createMemoInput = new ConnectApi.CreateCreditMemoInputRepresentation();
    createMemoInput.changeOrderIds = new List<String>{ output.preFulfillmentChangeOrderId };
    ConnectApi.CreateCreditMemoOutputRepresentation creditMemoOutput = connectAPI.OrderSummary.createCreditMemo(
      orderSummaryId,
      createMemoInput
    );

    List<ID> ids = new List<ID>();
    ids.add(creditMemoOutput.creditMemoId);
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new RestServiceCreditRefundCalloutMock());
    RestServiceCreditRefund.getData(ids);
    test.stopTest();
  }

  public class RestServiceCreditRefundCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success": true}');
      res.setStatusCode(200);
      return res;
    }
  }
}
