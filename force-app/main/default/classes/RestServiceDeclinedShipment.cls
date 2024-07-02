public with sharing class RestServiceDeclinedShipment {
  @invocableMethod(Callout=true)
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
          System.enqueueJob(new AsyncDeclinedShipment(itemsToProcess));
          itemsToProcess = new Map<Id, Integer>();
        }
      }
      if (itemsToProcess.size() >= 0) {
        System.enqueueJob(new AsyncDeclinedShipment(itemsToProcess));
      }
    } else {
      AsyncDeclinedShipment asyncDeclinedShipment = new AsyncDeclinedShipment(itemMap);
      asyncDeclinedShipment.execute(null);
    }
  }

  class ShipmentDeclinedWrapper {
    public String refundType;
    public String transactionID;
    public String salesChannelID;
    public String salesChannel;
    public String originalOrderID;
    public String orderReferenceNumber;
    public String fulfilmentOrderID;
    public String invoiceID;
    public String shippingRefund;
    public List<ShipmentDeclinedItemWrapper> orderItems;
  }

  class ShipmentDeclinedItemWrapper {
    public String itemID; //string
    public String sku; //number
    public Integer quantity; //string
  }

  private class AsyncDeclinedShipment implements Queueable, Database.AllowsCallouts {
    private Map<Id, Integer> internalMap;
    private List<ProcessException> processExceptions;
    private API_Endpoint__c endpoint;

    public AsyncDeclinedShipment(Map<Id, Integer> shipmentMap) {
      internalMap = shipmentMap;
      processExceptions = new List<ProcessException>();
    }

    public void execute(QueueableContext context) {
      List<DeclinedShipment__c> declinedShipments = [
        SELECT
          id,
          Transaction_Id__c,
          FulfillmentOrderId__r.Fulfillment_Order_Id__c,
          FulfillmentOrderId__r.OrderSummary.OrderNumber,
          FulfillmentOrderId__r.OrderSummary.OriginalOrder.OriginalOrderReference__c,
          FulfillmentOrderId__r.OrderSummary.OriginalOrder.CountryCode__c,
          FulfillmentOrderId__r.OrderSummary.OriginalOrder.Magento_SalesChannel_Name__c,
          FulfillmentOrderId__r.OrderSummary.OriginalOrder.InvoiceID__c,
          FulfillmentOrderId__r.OrderSummaryId
        FROM DeclinedShipment__c
        WHERE Id IN :internalMap.keySet()
      ];

      List<DeclinedShipmentItem__c> allDeclinedShipmentItems = [
        SELECT
          Id,
          FulfillmentOrderProductId__r.OrderItemSummary.OriginalOrderItem.ItemId__c,
          FulfillmentOrderProductId__r.OrderItemSummary.Product2.StockKeepingUnit,
          Quantity__c,
          DeclinedShipmentId__c
        FROM DeclinedShipmentItem__c
        WHERE DeclinedShipmentId__c IN :internalMap.keySet()
      ];

      endpoint = [
        SELECT Base_URL__c, Name
        FROM API_Endpoint__c
        WHERE Name = 'Declined Shipment API Base Endpoint' AND isDeleted = FALSE
        LIMIT 1
      ];

      List<Id> orderSummaryIds = new List<Id>();
      for (DeclinedShipment__c declinedShipment : declinedShipments) {
        if (!orderSummaryIds.contains(declinedShipment.FulfillmentOrderId__r.OrderSummaryId)) {
          orderSummaryIds.add(declinedShipment.FulfillmentOrderId__r.OrderSummaryId);
        }
      }

      List<OrderItemSummary> allOrderItemSummaries = [
        SELECT QuantityOrdered, QuantityCanceled, OrderSummaryId
        FROM OrderItemSummary
        WHERE OrderSummaryId IN :orderSummaryIds AND TypeCode != 'Charge'
      ];

      for (DeclinedShipment__c declinedShipment : declinedShipments) {
        List<DeclinedShipmentItem__c> declinedShipmentItems = getShipmentItemsByShipmentId(
          allDeclinedShipmentItems,
          declinedShipment.Id
        );
        // get total number of items
        Id orderSummaryId = declinedShipment.FulfillmentOrderId__r.OrderSummaryId;
        List<OrderItemSummary> orderItemSummaries = getOrderItemSummariesByOrderSummaryId(
          allOrderItemSummaries,
          orderSummaryId
        );

        Boolean hasNotFullyCancelledItems = false;
        for (OrderItemSummary oiSummary : orderItemSummaries) {
          if (oiSummary.QuantityOrdered - oiSummary.QuantityCanceled > 0) {
            hasNotFullyCancelledItems = true;
            // once we find an item that is not fully cancelled we can break the loop
            break;
          }
        }

        String orderReferenceNumber = declinedShipment.FulfillmentOrderId__r.OrderSummary.OrderNumber;
        String originalOrderID = declinedShipment.FulfillmentOrderId__r.OrderSummary.OriginalOrder.OriginalOrderReference__c;
        String countryCode = declinedShipment.FulfillmentOrderId__r.OrderSummary.OriginalOrder.CountryCode__c;
        String invoiceID = declinedShipment.FulfillmentOrderId__r.OrderSummary.OriginalOrder.InvoiceID__c;
        String fulfilmentOrderID = declinedShipment.FulfillmentOrderId__r.Fulfillment_Order_Id__c;
        String salesChannel = declinedShipment.FulfillmentOrderId__r.OrderSummary.OriginalOrder.Magento_SalesChannel_Name__c;
        String transactionID = TransactionId.generateID();

        RestServiceSendRefund refund = new RestServiceSendRefund();
        ProcessException processExc = refund.sendRefund(
          'declineRefund',
          salesChannel,
          originalOrderID,
          orderReferenceNumber,
          fulfilmentOrderID,
          invoiceID,
          transactionID,
          !hasNotFullyCancelledItems,
          countryCode,
          null,
          refund.convertDeclinedShipmentItems(declinedShipmentItems),
          declinedShipment.Id,
          endpoint
        );

        updateTransactionId(declinedShipment, transactionID);

        if (processExc != null) {
          Integer retries = internalMap.get(declinedShipment.Id);
          if (retries == null) {
            retries = 0;
          }
          processExc.Retries__c = retries;
          processExceptions.add(processExc);
        }
      }

      if (processExceptions.size() > 0) {
        insert processExceptions;
      }
      update declinedShipments;
    }

    private List<DeclinedShipmentItem__c> getShipmentItemsByShipmentId(
      List<DeclinedShipmentItem__c> shipmentItems,
      Id shipmentId
    ) {
      List<DeclinedShipmentItem__c> returnObj = new List<DeclinedShipmentItem__c>();
      for (DeclinedShipmentItem__c shipmentItem : shipmentItems) {
        if (shipmentItem.DeclinedShipmentId__c == shipmentId) {
          returnObj.add(shipmentItem);
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

    public void updateTransactionId(DeclinedShipment__c declinedShipment, String transactionID) {
      declinedShipment.Transaction_Id__c = transactionID;
    }
  }
}
