public with sharing class RestServiceReturnOrder {
  @invocableMethod(Callout=true Label='Return Order API callout to LSP')
  public static void getData(List<RestServiceInvocableAction> items) {
    Boolean runAsync = false;
    Map<Id, Integer> itemMap = new Map<Id, Integer>();
    for (RestServiceInvocableAction item : items) {
      runAsync = item.RunAsync != null ? item.RunAsync : runAsync;
      itemMap.put(item.Id, item.RetryNumber);
    }
    if (itemMap.size() > 50 || runAsync) {
      Map<Id, Integer> itemsToProcess = new Map<Id, Integer>();
      for (Id itemId : itemMap.keySet()) {
        itemsToProcess.put(itemId, itemMap.get(itemId));
        if (itemsToProcess.size() >= 50) {
          System.enqueueJob(new AsyncReturnOrder(itemsToProcess));
          itemsToProcess = new Map<Id, Integer>();
        }
      }
      if (itemsToProcess.size() >= 0) {
        System.enqueueJob(new AsyncReturnOrder(itemsToProcess));
      }
    } else {
      AsyncReturnOrder asyncReturnOrder = new AsyncReturnOrder(itemMap);
      asyncReturnOrder.execute(null);
    }
  }

  class returnOrderWrapper {
    public String transactionID; //string
    public String orderReferenceNumber; //string
    public String salesChannelID; //string
    public String returnOrderID; //string
    public String plantCode; //string
    public String customerId; //string
    public String createdDate; //string
    public returnOrderItemsWrapper[] returnItems; //string
  }

  class returnOrderItemsWrapper {
    public String returnLineID; //string
    public String quantity; //string
    public String sku; //string
    public String productName; //number
    public String returnReason; //string
  }

  private class AsyncReturnOrder implements Queueable, Database.AllowsCallouts {
    private Map<Id, Integer> internalMap;
    private List<API_Exception__c> exceptions;
    private List<ProcessException> processExceptions;
    private API_Endpoint__c endpoint;

    public AsyncReturnOrder(Map<Id, Integer> returnOrderIdsMap) {
      internalMap = returnOrderIdsMap;
      exceptions = new List<API_Exception__c>();
      processExceptions = new List<ProcessException>();
    }

    public void execute(QueueableContext context) {
      List<ReturnOrder> returnOrderList = [
        SELECT
          Account.External_Id__c,
          id,
          CreatedDate,
          API_JSON__c,
          ReturnOrderNumber,
          Transaction_ID__c,
          SourceLocationId,
          Location_External_Reference__c,
          OrderId
        FROM ReturnOrder
        WHERE id IN :internalMap.keySet()
      ];
      List<ReturnOrderLineItem> allReturnOrderItemList = [
        SELECT
          id,
          QuantityExpected,
          OrderItem.SKU__c,
          OrderItem.Product2.Name,
          ReasonForReturn,
          ReturnOrderId
        FROM ReturnOrderLineItem
        WHERE ReturnOrderId IN :internalMap.keySet() AND TypeCode != 'Charge'
      ];

      List<Id> orderIds = new List<Id>();
      for (ReturnOrder rOrder : returnOrderList) {
        orderIds.add(rOrder.OrderId);
      }

      Map<Id, Order> orderMap = new Map<Id, Order>(
        [
          SELECT
            Id,
            CreatedDate,
            OrderReferenceNumber,
            Account.External_Id__c,
            Magento_SalesChannel_Name__c,
            SalesChannelCountryCode__c,
            SalesChannelStoreID__c
          FROM Order
          WHERE ID IN :orderIds
        ]
      );

      endpoint = [
        SELECT Base_URL__c
        FROM API_Endpoint__c
        WHERE Name = 'Return API Base URL' AND isDeleted = FALSE
        LIMIT 1
      ];

      for (ReturnOrder rOrder : returnOrderList) {
        List<ReturnOrderLineItem> returnOrderItems = getReturnOrderItemsByReturnOrderId(
          allReturnOrderItemList,
          rOrder.Id
        );
        returnOrderWrapper returnOrderObj = constructJSON(
          rOrder,
          returnOrderItems,
          orderMap.get(rOrder.OrderId)
        );
        String JSONBody = JSON.serialize(returnOrderObj);
        String transactionID_s = returnOrderObj.transactionID;
        String brand = orderMap.get(rOrder.OrderId)
          .Magento_SalesChannel_Name__c;
        String country = orderMap.get(rOrder.OrderId)
          .SalesChannelCountryCode__c;
        String orderReference = orderMap.get(rOrder.OrderId)
          .OrderReferenceNumber;

        List<String> exceptionList = callAPI(
          JSONBody,
          brand,
          country,
          orderReference,
          rOrder,
          orderMap.get(rOrder.OrderId),
          transactionID_s
        );
        updateReturnOrder(rOrder, transactionID_s, JSONBody);

        if (exceptionList.size() > 0) {
          API_Exception__c apiExceptionObj = new API_Exception__c();
          apiExceptionObj.API_Name__c = 'Shipment Confirmation API';
          apiExceptionObj.Exception__c = String.valueOf(exceptionList);
          apiExceptionObj.JSON_Body__c = JSONBody;
          exceptions.add(apiExceptionObj);
        }
      }

      if (exceptions.size() > 0) {
        insert exceptions;
      }
      if (processExceptions.size() > 0) {
        insert processExceptions;
      }
      update returnOrderList;
    }

    private List<ReturnOrderLineItem> getReturnOrderItemsByReturnOrderId(
      List<ReturnOrderLineItem> allReturnOrderItems,
      Id returnOrderId
    ) {
      List<ReturnOrderLineItem> returnObj = new List<ReturnOrderLineItem>();
      for (ReturnOrderLineItem returnOrderItem : allReturnOrderItems) {
        if (returnOrderItem.ReturnOrderId == returnOrderId) {
          returnObj.add(returnOrderItem);
        }
      }
      return returnObj;
    }

    public returnOrderWrapper constructJSON(
      ReturnOrder returnOrder,
      List<ReturnOrderLineItem> returnItemList,
      Order order
    ) {
      List<returnOrderItemsWrapper> returnItemWrapperList = new List<returnOrderItemsWrapper>();

      for (ReturnOrderLineItem ri : returnItemList) {
        returnOrderItemsWrapper riObj = new returnOrderItemsWrapper();
        riObj.returnLineID = ri.Id;
        riObj.quantity = String.valueOf(ri.QuantityExpected);
        riObj.sku = ri.OrderItem.SKU__c;
        riObj.productName = ri.OrderItem.Product2.Name;
        riObj.returnReason = ri.ReasonForReturn;
        returnItemWrapperList.add(riObj);
      }

      returnOrderWrapper returnOrderObj = new returnOrderWrapper();
      returnOrderObj.transactionID = TransactionId.generateID();
      returnOrderObj.orderReferenceNumber = order.OrderReferenceNumber;
      returnOrderObj.returnOrderID = returnOrder.ReturnOrderNumber;
      returnOrderObj.plantCode = returnOrder.Location_External_Reference__c;
      returnOrderObj.customerId = order.Account.External_Id__c;
      returnOrderObj.createdDate = String.valueOf(order.CreatedDate);
      returnOrderObj.salesChannelID = order.SalesChannelStoreID__c;
      returnOrderObj.returnItems = returnItemWrapperList;
      return returnOrderObj;
    }

    public List<String> callAPI(
      String JSONBody,
      String brand,
      String country,
      String orderReference,
      ReturnOrder returnOrder,
      Order order,
      String transactionID_s
    ) {
      List<String> exceptionList = new List<String>();
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
        System.debug(res.getBody());
      } catch (Exception ex) {
        exceptionList.add(String.valueOf(ex.getMessage()));
      }

      if (res.getStatusCode() != 200) {
        //api callout is failed, creating process exception records

        ProcessException processExc = new ProcessException();
        processExc.Status = 'New';
        processExc.Severity = 'Low';
        processExc.AttachedToId = returnOrder.id;
        processExc.ExternalReference = order.orderReferenceNumber;
        processExc.TransactionId__c = transactionID_s;
        processExc.Priority = 'Low';
        processExc.Category = 'Place Order';
        processExc.Message = 'Return Order API callout is Failed';
        processExc.StatusCode__c = res.getStatusCode();
        processExc.Description = res.getBody().left(2000);
        processExceptions.add(processExc);
        exceptionList.add('Fulfilment Order API callout is Failed');
      }
      return exceptionList;
    }

    public void updateReturnOrder(
      ReturnOrder returnOrder,
      String transactionID_s,
      String apiJson_s
    ) {
      returnOrder.Transaction_ID__c = transactionID_s;
      returnOrder.API_JSON__c = apiJson_s;
    }
  }
}
