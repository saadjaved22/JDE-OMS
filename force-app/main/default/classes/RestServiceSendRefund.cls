public with sharing class RestServiceSendRefund {
  public List<ShipmentRefundItemWrapper> convertDeclinedShipmentItems(
    List<DeclinedShipmentItem__c> declinedShipmentItems
  ) {
    List<ShipmentRefundItemWrapper> shipmentItems = new List<ShipmentRefundItemWrapper>();

    for (DeclinedShipmentItem__c item : declinedShipmentItems) {
      ShipmentRefundItemWrapper shipmentItemObj = new ShipmentRefundItemWrapper();
      shipmentItemObj.itemID = item.FulfillmentOrderProductId__r.OrderItemSummary.OriginalOrderItem.ItemId__c;
      shipmentItemObj.sku = item.FulfillmentOrderProductId__r.OrderItemSummary.Product2.StockKeepingUnit;
      shipmentItemObj.quantity = Integer.valueOf(item.Quantity__c);
      shipmentItems.add(shipmentItemObj);
    }
    return shipmentItems;
  }

  public List<ShipmentRefundItemWrapper> convertReturnOrderLineItems(List<ReturnOrderLineItem> returnOrderLineItems) {
    List<ShipmentRefundItemWrapper> shipmentItems = new List<ShipmentRefundItemWrapper>();

    for (ReturnOrderLineItem item : returnOrderLineItems) {
      ShipmentRefundItemWrapper shipmentItemObj = new ShipmentRefundItemWrapper();
      shipmentItemObj.itemID = item.OrderItem.ItemId__c;
      shipmentItemObj.sku = item.OrderItem.SKU__c;
      shipmentItemObj.quantity = Integer.valueOf(item.QuantityExpected);
      shipmentItems.add(shipmentItemObj);
    }
    return shipmentItems;
  }

  public ProcessException sendRefund(
    String refundType,
    String salesChannel,
    String originalOrderID,
    String orderReferenceNumber,
    String fulfilmentOrderID,
    String invoiceID,
    String transactionID,
    Boolean shippingRefund,
    String countryCode,
    String returnOrderID,
    List<ShipmentRefundItemWrapper> refundShipmentItems,
    Id sourceObjectId,
    API_Endpoint__c endpoint
  ) {
    String JSONBody = JSON.serialize(
      constructJSON(
        refundType,
        salesChannel,
        originalOrderID,
        orderReferenceNumber,
        fulfilmentOrderID,
        invoiceID,
        transactionID,
        shippingRefund,
        returnOrderID,
        refundShipmentItems
      ),
      true
    );

    return callApi(
      JSONBody,
      salesChannel,
      countryCode,
      fulfilmentOrderID,
      orderReferenceNumber,
      transactionID,
      sourceObjectId,
      endpoint
    );
  }

  private ShipmentRefundWrapper constructJSON(
    String refundType,
    String salesChannel,
    String originalOrderID,
    String orderReferenceNumber,
    String fulfilmentOrderID,
    String invoiceID,
    String transactionID,
    Boolean shippingRefund,
    String returnOrderID,
    List<ShipmentRefundItemWrapper> refundShipmentItems
  ) {
    ShipmentRefundWrapper shipmentWrapper = new ShipmentRefundWrapper();
    shipmentWrapper.refundType = refundType;
    shipmentWrapper.transactionID = transactionID;
    shipmentWrapper.salesChannel = salesChannel;
    shipmentWrapper.originalOrderID = originalOrderID;
    shipmentWrapper.orderReferenceNumber = orderReferenceNumber;
    shipmentWrapper.fulfilmentOrderID = fulfilmentOrderID;
    shipmentWrapper.invoiceID = invoiceID;
    shipmentWrapper.shippingRefund = String.valueOf(shippingRefund);
    shipmentWrapper.orderItems = refundShipmentItems;
    shipmentWrapper.returnOrderID = returnOrderID;
    return shipmentWrapper;
  }

  private ProcessException callApi(
    String JSONBody,
    String salesChannel,
    String country,
    String fulfilmentOrderID,
    String orderReferenceNumber,
    String transactionID,
    Id sourceObjectId,
    API_Endpoint__c endpoint
  ) {
    System.debug('Refund sent to API: ' + JSONBody);
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint.Base_URL__c + salesChannel + '/' + country + '/' + fulfilmentOrderID);
    req.setMethod('POST');
    req.setBody(JSONBody);
    HTTPResponse res = new HTTPResponse();

    Http http = new Http();
    res = http.send(req);

    if (res.getStatusCode() != 200) {
      ProcessException processExc = new ProcessException();
      processExc.Status = 'New';
      processExc.Severity = 'Low';
      processExc.AttachedToId = sourceObjectId;
      processExc.ExternalReference = orderReferenceNumber;
      processExc.TransactionId__c = transactionID;
      processExc.Priority = 'Low';
      processExc.Category = endpoint.Name;
      processExc.Message = endpoint.Name + ' callout is Failed';
      processExc.Description = res.getBody().left(2000);
      processExc.StatusCode__c = res.getStatusCode();
      return processExc;
    }
    return null;
  }

  class ShipmentRefundWrapper {
    public String refundType;
    public String transactionID;
    public String salesChannel;
    public String originalOrderID;
    public String orderReferenceNumber;
    public String fulfilmentOrderID;
    public String returnOrderID;
    public String refundAmount;
    public String shippingRefund;
    public String invoiceID;
    public List<ShipmentRefundItemWrapper> orderItems;
  }

  class ShipmentRefundItemWrapper {
    public String itemID; //string
    public String sku; //number
    public Integer quantity; //string
  }
}
