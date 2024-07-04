public with sharing class RestServiceReturnOrderWebshopReturn {
  @invocableMethod(
    Callout=true
    Label='Return Order API Return callout to Webshop'
  )
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
          System.enqueueJob(new AsyncReturnOrderReturnWebshop(itemsToProcess));
          itemsToProcess = new Map<Id, Integer>();
        }
      }
      if (itemsToProcess.size() >= 0) {
        System.enqueueJob(new AsyncReturnOrderReturnWebshop(itemsToProcess));
      }
    } else {
      AsyncReturnOrderReturnWebshop asyncReturnOrderReturn = new AsyncReturnOrderReturnWebshop(
        itemMap
      );
      asyncReturnOrderReturn.execute(null);
    }
  }

  class returnOrderWebshopReturnWrapper {
    public String transactionID; //string
    public String orderReferenceNumber; //string
    public String salesChannel; //string
    public String returnOrderID; //string
    public String originalOrderID; //string
    public returnOrderWebshopReturnItemsWrapper[] orderItems; //string
  }

  class returnOrderWebshopReturnItemsWrapper {
    public String itemID;
    public String quantity; //string
    public String sku; //string
    public String returnReason; //string
  }

  private class AsyncReturnOrderReturnWebshop implements Queueable, Database.AllowsCallouts {
    private Map<Id, Integer> internalMap;
    private List<API_Exception__c> exceptions;
    private List<ProcessException> processExceptions;
    private API_Endpoint__c endpoint;

    public AsyncReturnOrderReturnWebshop(Map<Id, Integer> returnOrderIdsMap) {
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
          ReturnOrderId,
          OrderItem.ItemId__c
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
            OriginalOrderReference__c
          FROM Order
          WHERE ID IN :orderIds
        ]
      );

      endpoint = [
        SELECT Base_URL__c
        FROM API_Endpoint__c
        WHERE Name = 'Return API Webshop Return Base URL' AND isDeleted = FALSE
        LIMIT 1
      ];

      for (ReturnOrder rOrder : returnOrderList) {
        List<ReturnOrderLineItem> returnOrderItems = getReturnOrderItemsByReturnOrderId(
          allReturnOrderItemList,
          rOrder.Id
        );
        String transactionID_s = TransactionId.generateID();

        returnOrderWebshopReturnWrapper returnOrderObj = constructJSON(
          rOrder,
          returnOrderItems,
          orderMap.get(rOrder.OrderId),
          transactionID_s
        );
        String JSONBody = JSON.serialize(returnOrderObj);
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

    public returnOrderWebshopReturnWrapper constructJSON(
      ReturnOrder returnOrder,
      List<ReturnOrderLineItem> returnItemList,
      Order order,
      String transactionID_s
    ) {
      List<returnOrderWebshopReturnItemsWrapper> returnItemWrapperList = new List<returnOrderWebshopReturnItemsWrapper>();

      for (ReturnOrderLineItem ri : returnItemList) {
        returnOrderWebshopReturnItemsWrapper riObj = new returnOrderWebshopReturnItemsWrapper();
        riObj.itemID = ri.OrderItem.ItemId__c;
        riObj.quantity = String.valueOf(ri.QuantityExpected);
        riObj.sku = ri.OrderItem.SKU__c;
        riObj.returnReason = ri.ReasonForReturn;
        returnItemWrapperList.add(riObj);
      }

      returnOrderWebshopReturnWrapper returnOrderObj = new returnOrderWebshopReturnWrapper();
      returnOrderObj.transactionID = transactionID_s;
      returnOrderObj.salesChannel = order.Magento_SalesChannel_Name__c;
      returnOrderObj.originalOrderID = order.OriginalOrderReference__c;
      returnOrderObj.orderReferenceNumber = order.OrderReferenceNumber;
      returnOrderObj.returnOrderID = returnOrder.ReturnOrderNumber;
      returnOrderObj.orderItems = returnItemWrapperList;
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
        processExc.Category = 'Return Order';
        processExc.Message = 'Return Order API Webshop callout is Failed';
        processExc.StatusCode__c = res.getStatusCode();
        processExc.Description = res.getBody().left(2000);
        processExc.Retries__c = internalMap.get(returnOrder.id);
        exceptionList.add('Return Order API Webshop callout is Failed');
      }
      return exceptionList;
    }
  }
}
