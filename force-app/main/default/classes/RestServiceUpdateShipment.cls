public with sharing class RestServiceUpdateShipment {
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
          System.enqueueJob(new AsyncUpdateShipment(itemsToProcess));
          itemsToProcess = new Map<Id, Integer>();
        }
      }
      if (itemsToProcess.size() >= 0) {
        System.enqueueJob(new AsyncUpdateShipment(itemsToProcess));
      }
    } else {
      AsyncUpdateShipment asyncUpdateShipment = new AsyncUpdateShipment(
        itemMap
      );
      asyncUpdateShipment.execute(null);
    }
  }

  class ShipmentWrapper {
    public String transactionID;
    public String orderReferenceNumber;
    public String salesChannelID;
    public String salesChannel;
    public String originalOrderID;
    public String carrierID;
    public String fulfilmentOrderID;
    public String trackingNumber;
    public List<ShipmentItemWrapper> orderItems;
  }

  class ShipmentItemWrapper {
    public String itemID; //string
    public String sku; //number
    public Integer shippedQuantity; //string
  }

  private class AsyncUpdateShipment implements Queueable, Database.AllowsCallouts {
    private Map<Id, Integer> internalMap;
    private List<API_Exception__c> exceptions;
    private List<ProcessException> processExceptions;
    private API_Endpoint__c endpoint;

    public AsyncUpdateShipment(Map<Id, Integer> shipmentMap) {
      internalMap = shipmentMap;
      exceptions = new List<API_Exception__c>();
      processExceptions = new List<ProcessException>();
    }

    public void execute(QueueableContext context) {
      List<Shipment> shipmentList = [
        SELECT
          id,
          FulfillmentOrderId,
          Transaction_Id__c,
          FulfillmentOrder.Fulfillment_Order_Id__c,
          OrderSummary.OrderNumber,
          OrderSummary.OriginalOrder.OriginalOrderReference__c,
          OrderSummary.OriginalOrder.CountryCode__c,
          OrderSummary.OriginalOrder.Shipping_Carrier__c,
          OrderSummary.OriginalOrder.Magento_SalesChannel_Name__c,
          TrackingUrl,
          TrackingNumber
        FROM Shipment
        WHERE Id IN :internalMap.keySet()
      ];

      List<ShipmentItem> allShipmentItems = [
        SELECT
          id,
          Product2.StockKeepingUnit,
          Quantity,
          OrderItemSummary.OriginalOrderItem.ItemId__c,
          ShipmentId
        FROM ShipmentItem
        WHERE ShipmentId IN :internalMap.keySet()
      ];

      endpoint = [
        SELECT Base_URL__c
        FROM API_Endpoint__c
        WHERE Name = 'Update Shipment API Base Endpoint' AND isDeleted = FALSE
        LIMIT 1
      ];

      for (Shipment shipment : shipmentList) {
        List<ShipmentItem> shipmentItems = getShipmentItemsByShipmentId(
          allShipmentItems,
          shipment.Id
        );

        String salesChannelID = '';
        String orderReferenceNumber = shipment.OrderSummary.OrderNumber;
        String originalOrderID = shipment.OrderSummary.OriginalOrder.OriginalOrderReference__c;
        String carrierID = shipment.OrderSummary.OriginalOrder.Shipping_Carrier__c;
        String countryCode = shipment.OrderSummary.OriginalOrder.CountryCode__c;
        String fulfilmentOrderID = shipment.FulfillmentOrder.Fulfillment_Order_Id__c;
        String salesChannel = shipment.OrderSummary.OriginalOrder.Magento_SalesChannel_Name__c;
        String trackingNumber = shipment.TrackingNumber;
        String transactionID = TransactionId.generateID();

        List<String> fulfilmentOrderID_s = String.valueOf(fulfilmentOrderID)
          .split('-');

        if (fulfilmentOrderID_s.size() > 1) {
          salesChannelID = fulfilmentOrderID_s[0];
        }

        String JSONBody = JSON.serialize(
          constructJSON(
            salesChannelID,
            salesChannel,
            originalOrderID,
            orderReferenceNumber,
            carrierID,
            fulfilmentOrderID,
            trackingNumber,
            transactionID,
            shipmentItems
          )
        );

        List<String> exceptionList = callApi(
          JSONBody,
          salesChannelID,
          countryCode,
          fulfilmentOrderID,
          orderReferenceNumber,
          transactionID,
          shipment
        );

        updateTransactionId(shipment, transactionID);

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
      update shipmentList;
    }

    private List<ShipmentItem> getShipmentItemsByShipmentId(
      List<ShipmentItem> shipmentItems,
      Id shipmentId
    ) {
      List<ShipmentItem> returnObj = new List<ShipmentItem>();
      for (ShipmentItem shipmentItem : shipmentItems) {
        if (shipmentItem.ShipmentId == shipmentId) {
          returnObj.add(shipmentItem);
        }
      }
      return returnObj;
    }

    public ShipmentWrapper constructJSON(
      String salesChannelID,
      String salesChannel,
      String originalOrderID,
      String orderReferenceNumber,
      String carrierID,
      String fulfilmentOrderID,
      String trackingNumber,
      String transactionID,
      List<ShipmentItem> shipmentItemsList
    ) {
      ShipmentWrapper shipmentWrapper = new ShipmentWrapper();
      shipmentWrapper.transactionID = transactionID;
      shipmentWrapper.salesChannelID = salesChannelID;
      shipmentWrapper.salesChannel = salesChannel;
      shipmentWrapper.originalOrderID = originalOrderID;
      shipmentWrapper.orderReferenceNumber = orderReferenceNumber;
      shipmentWrapper.carrierID = carrierID;
      shipmentWrapper.fulfilmentOrderID = fulfilmentOrderID;
      shipmentWrapper.trackingNumber = trackingNumber;
      List<ShipmentItemWrapper> shipmentItems = new List<ShipmentItemWrapper>();

      for (integer i = 0; i < shipmentItemsList.size(); i++) {
        ShipmentItemWrapper shipmentObj = new ShipmentItemWrapper();
        shipmentObj.itemID = shipmentItemsList[i]
          .OrderItemSummary.OriginalOrderItem.ItemId__c;
        shipmentObj.sku = shipmentItemsList[i].Product2.StockKeepingUnit;
        shipmentObj.shippedQuantity = shipmentItemsList[i].Quantity.intValue();
        shipmentItems.add(shipmentObj);
      }
      shipmentWrapper.orderItems = shipmentItems;

      return shipmentWrapper;
    }

    public List<String> callApi(
      String JSONBody,
      String salesChannelID,
      String country,
      String fulfilmentOrderID,
      String orderReferenceNumber,
      String transactionID,
      Shipment shipment
    ) {
      List<String> exceptionList = new List<String>();
      System.debug('Shipment sent to API: ' + JSONBody);
      HttpRequest req = new HttpRequest();
      req.setEndpoint(
        endpoint.Base_URL__c +
          salesChannelID +
          '/' +
          country +
          '/' +
          fulfilmentOrderID
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

      system.debug('Update shipment : ' + res.getBody());

      if (res.getStatusCode() != 200) {
        ProcessException processExc = new ProcessException();
        processExc.Status = 'New';
        processExc.Severity = 'Low';
        processExc.AttachedToId = shipment.FulfillmentOrderId;
        processExc.ExternalReference = orderReferenceNumber;
        processExc.TransactionId__c = transactionID;
        processExc.Priority = 'Low';
        processExc.Category = 'Shipment';
        processExc.Shipment__c = shipment.Id;
        processExc.Message = 'Shipment API Callout is failed';
        processExc.StatusCode__c = res.getStatusCode();
        processExc.Description = res.getBody().left(2000);
        processExc.Retries__c = internalMap.get(shipment.Id);
        processExceptions.add(processExc);
        exceptionList.add('Shipment API Callout is failed');
      }
      return exceptionList;
    }

    public void updateTransactionId(Shipment shipment, String transactionID) {
      shipment.Transaction_Id__c = transactionID;
    }
  }
}
