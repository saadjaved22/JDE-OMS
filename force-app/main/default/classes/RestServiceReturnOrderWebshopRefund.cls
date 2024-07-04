public with sharing class RestServiceReturnOrderWebshopRefund {
  @invocableMethod(
    Callout=true
    Label='Return Order API Refund callout to Webshop'
  )
  public static void getData(List<RestServiceInvocableAction> items) {
    Map<Id, Integer> itemMap = new Map<Id, Integer>();
    for (RestServiceInvocableAction item : items) {
      itemMap.put(item.Id, item.RetryNumber);
    }
    if (itemMap.size() > 50) {
      Map<Id, Integer> itemsToProcess = new Map<Id, Integer>();
      for (Id itemId : itemMap.keySet()) {
        itemsToProcess.put(itemId, itemMap.get(itemId));
        if (itemsToProcess.size() >= 50) {
          System.enqueueJob(new AsyncReturnOrderRefundWebshop(itemsToProcess));
          itemsToProcess = new Map<Id, Integer>();
        }
      }
      if (itemsToProcess.size() >= 0) {
        System.enqueueJob(new AsyncReturnOrderRefundWebshop(itemsToProcess));
      }
    } else {
      AsyncReturnOrderRefundWebshop asyncReturnOrderRefund = new AsyncReturnOrderRefundWebshop(
        itemMap
      );
      asyncReturnOrderRefund.execute(null);
    }
  }

  private class AsyncReturnOrderRefundWebshop implements Queueable, Database.AllowsCallouts {
    private Map<Id, Integer> internalMap;
    private List<API_Exception__c> exceptions;
    private List<ProcessException> processExceptions;
    private API_Endpoint__c endpoint;

    public AsyncReturnOrderRefundWebshop(Map<Id, Integer> returnOrderIdsMap) {
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
          OrderId,
          OrderSummaryId
        FROM ReturnOrder
        WHERE id IN :internalMap.keySet()
      ];
      List<ReturnOrderLineItem> allReturnOrderItemList = [
        SELECT
          id,
          QuantityExpected,
          OrderItem.SKU__c,
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
            OrderReferenceNumber,
            Magento_SalesChannel_Name__c,
            SalesChannelCountryCode__c,
            CountryCode__c,
            OriginalOrderReference__c,
            InvoiceID__c
          FROM Order
          WHERE ID IN :orderIds
        ]
      );

      List<Id> orderSummaryIds = new List<Id>();
      for (ReturnOrder returnOrder : returnOrderList) {
        if (!orderSummaryIds.contains(returnOrder.OrderSummaryId)) {
          orderSummaryIds.add(returnOrder.OrderSummaryId);
        }
      }

      List<OrderItemSummary> allOrderItemSummaries = [
        SELECT
          QuantityOrdered,
          QuantityReturnInitiated,
          Declined_Quantity__c,
          OrderSummaryId
        FROM OrderItemSummary
        WHERE OrderSummaryId IN :orderSummaryIds AND TypeCode != 'Charge'
      ];

      endpoint = [
        SELECT Base_URL__c, Name
        FROM API_Endpoint__c
        WHERE Name = 'Return API Webshop Refund Base URL' AND isDeleted = FALSE
        LIMIT 1
      ];

      for (ReturnOrder rOrder : returnOrderList) {
        List<ReturnOrderLineItem> returnOrderItems = getReturnOrderItemsByReturnOrderId(
          allReturnOrderItemList,
          rOrder.Id
        );

        // get total number of items
        Id orderSummaryId = rOrder.OrderSummaryId;
        List<OrderItemSummary> orderItemSummaries = getOrderItemSummariesByOrderSummaryId(
          allOrderItemSummaries,
          orderSummaryId
        );

        Boolean hasNotFullyReturnedItems = false;
        for (OrderItemSummary oiSummary : orderItemSummaries) {
          if (
            (oiSummary.QuantityOrdered -
            oiSummary.Declined_Quantity__c -
            oiSummary.QuantityReturnInitiated) > 0
          ) {
            hasNotFullyReturnedItems = true;
            // once we find an item that is not fully cancelled we can break the loop
            break;
          }
        }

        String transactionID_s = TransactionId.generateID();

        String orderReferenceNumber = orderMap.get(rOrder.OrderId)
          .OrderReferenceNumber;
        String originalOrderID = orderMap.get(rOrder.OrderId)
          .OriginalOrderReference__c;
        String countryCode = orderMap.get(rOrder.OrderId).CountryCode__c;
        String invoiceID = orderMap.get(rOrder.OrderId).InvoiceID__c;
        String returnOrderId = rOrder.ReturnOrderNumber;
        String salesChannel = orderMap.get(rOrder.OrderId)
          .Magento_SalesChannel_Name__c;
        String transactionID = TransactionId.generateID();

        RestServiceSendRefund refund = new RestServiceSendRefund();
        ProcessException processExc = refund.sendRefund(
          'returnRefund',
          salesChannel,
          originalOrderID,
          orderReferenceNumber,
          null,
          invoiceID,
          transactionID,
          !hasNotFullyReturnedItems,
          countryCode,
          returnOrderId,
          refund.convertReturnOrderLineItems(returnOrderItems),
          rOrder.Id,
          endpoint
        );

        if (processExc != null) {
          Integer retries = internalMap.get(rOrder.Id);
          if (retries == null) {
            retries = 0;
          }
          processExc.Retries__c = retries;
          processExceptions.add(processExc);
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

    private List<OrderItemSummary> getOrderItemSummariesByOrderSummaryId(
      List<OrderItemSummary> allOrderItemSummaries,
      Id orderSummaryId
    ) {
      List<OrderItemSummary> returnObj = new List<OrderItemSummary>();
      for (OrderItemSummary orderItemSummary : allOrderItemSummaries) {
        if (orderItemSummary.OrderSummaryId == orderSummaryId) {
          returnObj.add(orderItemSummary);
        }
      }
      return returnObj;
    }
  }
}
