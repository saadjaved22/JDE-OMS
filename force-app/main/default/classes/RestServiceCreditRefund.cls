public with sharing class RestServiceCreditRefund {
  @invocableMethod(Callout=true)
  public static void getData(List<ID> ids) {
    if (ids.size() > 50) {
      List<Id> IdsToProcess = new List<Id>();
      for (Id id : ids) {
        IdsToProcess.add(id);
        if (IdsToProcess.size() >= 50) {
          System.enqueueJob(new AsyncCreditRefund(IdsToProcess));
          IdsToProcess = new List<Id>();
        }
      }
      if (IdsToProcess.size() >= 0) {
        System.enqueueJob(new AsyncCreditRefund(IdsToProcess));
      }
    } else {
      AsyncCreditRefund asyncCredit = new AsyncCreditRefund(ids);
      asyncCredit.execute(null);
    }
  }

  private class AsyncCreditRefund implements Queueable, Database.AllowsCallouts {
    private List<Id> ids;
    private List<ProcessException> processExceptions;

    public AsyncCreditRefund(List<Id> creditMemoIds) {
      ids = creditMemoIds;
      processExceptions = new List<ProcessException>();
    }

    public void execute(QueueableContext context) {
      List<CreditMemo> creditMemoList = [
        SELECT id, ReferenceEntityId, TotalAmountWithTax
        FROM CreditMemo
        WHERE ID IN :ids
      ];

      List<ID> orderSummaryIds = new List<ID>();

      for (CreditMemo cr : creditMemoList) {
        if (
          cr.ReferenceEntityId.getSObjectType().getDescribe().getName() ==
          'OrderSummary'
        ) {
          orderSummaryIds.add(cr.ReferenceEntityId);
        }
      }

      List<ReturnOrder> returnOrder = [
        SELECT id, Return_Order_ID__c, OrderSummaryId
        FROM ReturnOrder
        WHERE OrderSummaryId IN :orderSummaryIds
      ];

      List<OrderSummary> orderSummaryList = [
        SELECT
          id,
          OriginalOrderId,
          Order_Invoice_Id__c,
          TotalAmount,
          SalesChannel_Country_Code__c,
          Magento_SaleChannel_Name__c,
          SalesChannel.SalesChannelName,
          OrderNumber
        FROM OrderSummary
        WHERE id IN :orderSummaryIds
      ];

      List<ID> orderIds = new List<ID>();

      for (OrderSummary os : orderSummaryList) {
        orderIds.add(os.OriginalOrderId);
      }

      List<OrderItem> oItems = [
        SELECT id, Product2.StockKeepingUnit, ItemId__c
        FROM OrderItem
        WHERE OrderId IN :orderIds AND TypeCode != 'Charge'
      ];

      List<CreditMemoLine> creditMemoLines = [
        SELECT id, CreditMemoId, Product2.StockKeepingUnit
        FROM CreditMemoLine
        WHERE CreditMemoId IN :ids
        LIMIT 1
      ];

      Map<ID, OrderSummary> creditRefundMapper = new Map<ID, OrderSummary>();

      for (CreditMemo cr : creditMemoList) {
        for (OrderSummary os : orderSummaryList) {
          if (cr.ReferenceEntityId == os.id) {
            creditRefundMapper.put(cr.id, os);
          }
        }
      }

      for (CreditMemo cr : creditMemoList) {
        String transactionID_s = TransactionId.generateID();

        List<CreditMemoLine> crLines = getCreditLines(creditMemoLines, cr.id);
        creditRefundwrapper creditMemoWrapper = constructJSON(
          cr,
          crLines,
          creditRefundMapper.get(cr.id),
          transactionID_s,
          oItems
        );
        String JSONBody = JSON.serialize(creditMemoWrapper);
        String brand = creditRefundMapper.get(cr.id)
          .Magento_SaleChannel_Name__c;
        String country = creditRefundMapper.get(cr.id)
          .SalesChannel_Country_Code__c;
        String orderReference = creditRefundMapper.get(cr.id).OrderNumber;
        callAPI(
          JSONBody,
          brand,
          country,
          orderReference,
          cr.id,
          transactionID_s
        );

        updateCreditMemo(cr, JSONBody, transactionID_s);
      }

      if (processExceptions.size() > 0) {
        insert processExceptions;
      }

      update creditMemoList;
    }

    public creditRefundwrapper constructJSON(
      CreditMemo creditMemo,
      List<CreditMemoLine> creditMemoLines,
      OrderSummary orderSummary,
      String transactionID_s,
      List<OrderItem> oItems
    ) {
      List<creditRefundItemsWrapper> creditLineList = new List<creditRefundItemsWrapper>();

      for (OrderItem oi : oItems) {
        for (CreditMemoLine crLine : creditMemoLines) {
          if (
            crLine.Product2.StockKeepingUnit == oi.Product2.StockKeepingUnit
          ) {
            creditRefundItemsWrapper creditLineWrapper = new creditRefundItemsWrapper();
            creditLineWrapper.itemID = oi.ItemId__c;
            creditLineWrapper.sku = crLine.Product2.StockKeepingUnit;
            creditLineWrapper.quantity = '0';
            creditLineList.add(creditLineWrapper);
          }
        }
      }
      creditRefundwrapper creditRefundWrapper = new creditRefundwrapper();
      creditRefundWrapper.transactionID = transactionID_s;
      creditRefundWrapper.refundType = 'creditRefund';
      creditRefundWrapper.salesChannel = orderSummary.Magento_SaleChannel_Name__c;
      creditRefundWrapper.originalOrderID = orderSummary.OrderNumber;
      creditRefundWrapper.orderReferenceNumber = orderSummary.OrderNumber;
      creditRefundWrapper.refundAmount = String.valueOf(
        creditMemo.TotalAmountWithTax
      );
      creditRefundWrapper.shippingRefund = 'false';
      creditRefundWrapper.invoiceID = orderSummary.Order_Invoice_Id__c;
      creditRefundWrapper.orderItems = creditLineList;

      return creditRefundWrapper;
    }

    private List<CreditMemoLine> getCreditLines(
      List<CreditMemoLine> creditMemoLines,
      ID crId
    ) {
      List<CreditMemoLine> creditLineList = new List<CreditMemoLine>();

      for (CreditMemoLine crList : creditMemoLines) {
        if (crList.CreditMemoId == crId) {
          creditLineList.add(crList);
        }
      }

      return creditLineList;
    }

    public void callAPI(
      String JSONBody,
      String brand,
      String country,
      String orderReference,
      Id crId,
      String transactionID_s
    ) {
      List<String> exceptions = new List<String>();
      List<ProcessException> processExceptions = new List<ProcessException>();

      API_Endpoint__c endpoint = [
        SELECT Base_URL__c
        FROM API_Endpoint__c
        WHERE Name LIKE 'Credit Refund API Endpoint'
        LIMIT 1
      ];
      HttpRequest req = new HttpRequest();
      req.setEndpoint(
        endpoint.Base_URL__c + brand + '/' + country + '/' + orderReference
      );
      req.setMethod('POST');
      req.setBody(JSONBody);

      HTTPResponse res = new HTTPResponse();

      try {
        Http http = new Http();
        res = http.send(req);
      } catch (Exception ex) {
        exceptions.add(String.valueOf(ex.getMessage()));
      }
      if (res.getStatusCode() != 200) {
        //api callout is failed, creating process exception records
        //first find OS that this creditMemo is related to
        CreditMemo credMemo = [
          SELECT ReferenceEntityId
          FROM CreditMemo
          WHERE Id = :crId
          LIMIT 1
        ];
        Id osId = (credMemo == null ? null : credMemo.ReferenceEntityId);

        ProcessException processExc = new ProcessException();
        processExc.Status = 'New';
        processExc.Severity = 'Low';
        processExc.OrderSummaryId = osId;
        processExc.AttachedToId = crId;
        processExc.ExternalReference = orderReference;
        processExc.TransactionId__c = transactionID_s;
        processExc.payload__c = JSONBody;
        processExc.Response__c = res.getBody();
        processExc.Priority = 'Low';
        processExc.Category = 'Credit Refund';
        processExc.Message = 'Credit Refund	API callout to Magento has failed';
        processExc.StatusCode__c = res.getStatusCode();
        processExc.Description = res.getBody().left(2000);
        processExceptions.add(processExc);
        exceptions.add('Credit Refund API callout to Magento has failed');
      }
    }

    public void updateCreditMemo(
      CreditMemo creditMemo,
      String JSON,
      String transactionId
    ) {
      creditMemo.API_JSON_Body__c = JSON;
      creditMemo.Transaction_ID__c = transactionId;
    }
  }

  class creditRefundwrapper {
    public String transactionID; //string
    public String refundType; //string
    public String salesChannel; //string
    public String originalOrderID; //string
    public String orderReferenceNumber; //string
    public String invoiceID; //string
    public String refundAmount; //string
    public String shippingRefund; //string
    public creditRefundItemsWrapper[] orderItems; //array
  }

  class creditRefundItemsWrapper {
    public String itemID; //string
    public String quantity; //string
    public String sku; //string
  }
}
