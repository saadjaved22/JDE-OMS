@RestResource(urlMapping='/Shipment/create/v1/*')
global with sharing class RestServiceShipment {
  public static List<String> exceptionsList = new List<String>();

  @HttpPost
  global static List<RestServiceUtils.RestServiceErrorMessage> createShipment(
    String orderReferenceNumber,
    String fulfilmentOrderID,
    String trackingNumber,
    String transactionID,
    orderItemWrapper[] orderItems
  ) {
    //checking if this fulfilment order is fully shipped
    FulfillmentOrder fOrder = [
      SELECT id, Status, OrderSummaryId, ItemCount, Transaction_ID__c
      FROM FulfillmentOrder
      WHERE Fulfillment_Order_Id__c LIKE :fulfilmentOrderID
      LIMIT 1
    ];

    //aggregating fulfilment orders total line items which are not set as Delivery Charges
    AggregateResult[] fulfilmentOrderItems = [
      SELECT sum(OriginalQuantity) totalQuantity
      FROM FulfillmentOrderLineItem
      WHERE Type != 'Delivery Charge' AND FulfillmentOrderId = :fOrder.id
    ];

    //Aggregating shipment line items for this fulfilment order
    AggregateResult[] existingShipments = [
      SELECT sum(TotalItemsQuantity) totalShipped
      FROM Shipment
      WHERE FulfillmentOrderId = :fOrder.id
    ];

    if (
      existingShipments[0].get('totalShipped') != null &&
      fulfilmentOrderItems[0].get('totalQuantity') != null &&
      Decimal.valueOf(String.valueOf(existingShipments[0].get('totalShipped'))) >=
      Decimal.valueOf(String.valueOf(fulfilmentOrderItems[0].get('totalQuantity')))
    ) {
      exceptionsList.add('This Fulfilment Order is Already Fully Shipped');

      ProcessException processExc = new ProcessException();
      processExc.Status = 'New';
      processExc.Severity = 'Low';
      processExc.AttachedToId = fOrder.id;
      processExc.ExternalReference = orderReferenceNumber;
      processExc.TransactionId__c = forder.Transaction_ID__c;
      processExc.Priority = 'Low';
      processExc.Category = 'Fufillment';
      processExc.Message = 'Duplicate shipment received';
      processExc.Description = 'This Fulfilment Order is Already Fully Shipped';

      try {
        insert processExc;
      } catch (Exception ex) {
        system.debug('Exception: ' + ex.getMessage());
        exceptionsList.add(ex.getMessage());
      }
    } else {
      List<FulfillmentOrderLineItem> fOrderItems = [
        SELECT id, OrderItemId, OrderItem.SKU__c, OrderItemSummaryId, Product2Id, OriginalQuantity
        FROM FulfillmentOrderLineItem
        WHERE FulfillmentOrderId = :fOrder.id AND TypeCode != 'Charge'
        ORDER BY UnitPrice DESC
      ];

      List<OrderSummary> orderSummaryList = [
        SELECT id, OriginalOrderId
        FROM OrderSummary
        WHERE Id = :fOrder.OrderSummaryId
      ];

      List<Order> orderList = [
        SELECT
          ShippingState,
          BillingStreet,
          BillingCity,
          BillingCountry,
          BillingEmailAddress,
          BillingFirstName__c,
          BillingLastName__c,
          BillingPostalCode,
          BillingPhoneNumber,
          ShippingStreet,
          ShippingCity,
          ShippingCountry,
          ShippingPostalCode,
          CurrencyIsoCode,
          ShippingFirstName__c,
          ShippingLastName__c,
          Delivery_Date__c
        FROM Order
        WHERE id = :orderSummaryList[0].OriginalOrderId
      ];

      List<OrderDeliveryGroup> deliveryGroupList = [
        SELECT id
        FROM OrderDeliveryGroup
        WHERE OrderId = :orderSummaryList[0].OriginalOrderId
      ];

      List<ShipmentItem> existingShipmentItems = [
        SELECT Id, Quantity, FulfillmentOrderLineItemId
        FROM ShipmentItem
        WHERE ShipmentId IN (SELECT Id FROM Shipment WHERE FulfillmentOrderId = :fOrder.Id)
      ];

      List<DeclinedShipmentItem__c> existingDeclinedShipmentItems = [
        SELECT Id, Quantity__c, FulfillmentOrderProductId__c
        FROM DeclinedShipmentItem__c
        WHERE DeclinedShipmentId__c IN (SELECT Id FROM DeclinedShipment__c WHERE FulfillmentOrderId__c = :fOrder.Id)
      ];

      createShipmentObj(
        fOrder,
        orderList,
        trackingNumber,
        transactionID,
        orderItems,
        fOrderItems,
        existingShipmentItems,
        existingDeclinedShipmentItems
      );

      updateFulfillmentItemStatus(fOrder, fOrderItems);
    }
    if (exceptionsList.size() > 0 && !Test.isRunningTest()) {
      RestContext.response.statusCode = 500;
    }

    return RestServiceUtils.ConvertExceptionList(exceptionsList);
  }

  public static void createShipmentObj(
    FulfillmentOrder fOrder,
    List<Order> orderList,
    String trackingNumber,
    String transactionID,
    orderItemWrapper[] orderItems,
    List<FulfillmentOrderLineItem> fOrderItems,
    List<ShipmentItem> existingShipmentItems,
    List<DeclinedShipmentItem__c> existingDeclinedShipmentItems
  ) {
    List<ShipmentItem> shipmentItemList = new List<ShipmentItem>();

    Map<String, shippedItemsHelper> orderItemMap = new Map<String, shippedItemsHelper>();
    DeclinedShipment__c declinedShipmentObj;
    List<DeclinedShipmentItem__c> declinedShipmentItems = new List<DeclinedShipmentItem__c>();

    // create objects to track shipments over multiple lineitems
    for (orderItemWrapper orderItem : orderItems) {
      shippedItemsHelper sih = new shippedItemsHelper();
      sih.shippedQuantity = Integer.valueOf(orderItem.shippedQuantity);
      sih.declinedQuantity = Integer.valueOf(orderItem.declinedQuantity);
      orderItemMap.put(orderItem.sku, sih);
    }

    for (FulfillmentOrderLineItem fOrderItem : fOrderItems) {
      shippedItemsHelper sih = orderItemMap.get(fOrderItem.OrderItem.SKU__c);
      if (sih != null) {
        // get existing shipments
        List<ShipmentItem> existingFoiShipmentItems = getShipmentItemsByFoiId(existingShipmentItems, fOrderItem.Id);
        List<DeclinedShipmentItem__c> existingFoiDeclinedShipmentItems = getDeclinedShipmentItemsByFoiId(
          existingDeclinedShipmentItems,
          fOrderItem.Id
        );
        // set the quantity that we need to divide
        Integer quantityLeftToDivide = Integer.valueOf(fOrderItem.OriginalQuantity);
        // subtract any existing shipments (declined or normal)
        for (ShipmentItem existingFoiShipmentItem : existingFoiShipmentItems) {
          quantityLeftToDivide -= Integer.valueOf(existingFoiShipmentItem.Quantity);
        }
        for (DeclinedShipmentItem__c existingFoiDeclinedShipmentItem : existingFoiDeclinedShipmentItems) {
          quantityLeftToDivide -= Integer.valueOf(existingFoiDeclinedShipmentItem.Quantity__c);
        }

        // if the declined quantity is higher than what is in this fulfillment lineitem,
        // update the tracking object and create a declined shipment only for what is in this lineitem
        Integer declinedQuantity = sih.declinedQuantity;
        if (declinedQuantity > quantityLeftToDivide) {
          declinedQuantity = quantityLeftToDivide;
          sih.declinedQuantity -= quantityLeftToDivide;
          orderItemMap.put(fOrderItem.OrderItem.SKU__c, sih);
          quantityLeftToDivide = 0;
        } else if (declinedQuantity > 0) {
          quantityLeftToDivide -= declinedQuantity;
          sih.declinedQuantity = 0;
          orderItemMap.put(fOrderItem.OrderItem.SKU__c, sih);
        }

        if (declinedQuantity > 0) {
          // create declined shipment object if it is not set yet
          if (declinedShipmentObj == null) {
            declinedShipmentObj = new DeclinedShipment__c();
            declinedShipmentObj.FulfillmentOrderId__c = fOrder.Id;
            declinedShipmentObj.OrderSummaryId__c = fOrder.OrderSummaryId;
            declinedShipmentObj.Status__c = 'Declined';
            declinedShipmentObj.Transaction_ID__c = transactionID;
          }

          DeclinedShipmentItem__c declinedShipmentItem = new DeclinedShipmentItem__c();
          declinedShipmentItem.FulfillmentOrderProductId__c = fOrderItem.Id;
          declinedShipmentItem.OrderItemSummaryId__c = fOrderItem.OrderItemSummaryId;
          declinedShipmentItem.Product2Id__c = fOrderItem.Product2Id;
          declinedShipmentItem.Quantity__c = declinedQuantity;
          declinedShipmentItems.add(declinedShipmentItem);
        }

        // repeat the process for shipped items
        Integer shippedQuantity = sih.shippedQuantity;
        if (shippedQuantity > quantityLeftToDivide) {
          shippedQuantity = quantityLeftToDivide;
          sih.shippedQuantity -= quantityLeftToDivide;
          orderItemMap.put(fOrderItem.OrderItem.SKU__c, sih);
          quantityLeftToDivide = 0;
        } else if (shippedQuantity > 0) {
          //
          // if this lineitem covers the entire shipping lineitem, update it in the tracking object
          quantityLeftToDivide -= shippedQuantity;
          sih.shippedQuantity = 0;
          orderItemMap.put(fOrderItem.OrderItem.SKU__c, sih);
        }

        // create the actual objects
        if (shippedQuantity > 0) {
          ShipmentItem shipmentItemObj = new ShipmentItem();
          shipmentItemObj.Product2Id = fOrderItem.Product2Id;
          shipmentItemObj.FulfillmentOrderLineItemId = fOrderItem.Id;
          shipmentItemObj.OrderItemSummaryId = fOrderItem.OrderItemSummaryId;
          shipmentItemObj.Quantity = shippedQuantity;
          shipmentItemList.add(shipmentItemObj);
        }
      }
    }

    if (shipmentItemList.size() > 0) {
      Shipment shipmentObj = new Shipment();
      shipmentObj.FulfillmentOrderId = fOrder.id;
      shipmentObj.Status = 'Shipped';
      shipmentObj.ShipToName = orderList[0].ShippingFirstName__c + ' ' + orderList[0].ShippingLastName__c;
      shipmentObj.CurrencyIsoCode = orderList[0].CurrencyIsoCode;
      shipmentObj.OrderSummaryId = fOrder.OrderSummaryId;
      shipmentObj.ShipToCity = orderList[0].ShippingCity;
      shipmentObj.ShipToStreet = orderList[0].ShippingStreet;
      shipmentObj.ShipToState = orderList[0].ShippingState;
      shipmentObj.ShipToCountry = orderList[0].ShippingCountry;
      shipmentObj.ShipToPostalCode = orderList[0].ShippingPostalCode;
      shipmentObj.TrackingNumber = trackingNumber;
      shipmentObj.Transaction_ID__c = transactionID;

      //shipmentObj.Fulfilment_Order_Total_Quantity__c = Decimal.valueOf(String.valueOf(fulfilmentOrderItems[0].get('totalQuantity')));

      try {
        insert shipmentObj;
      } catch (Exception ex) {
        system.debug('Exception : ' + ex.getMessage());
        exceptionsList.add(String.valueOf(ex.getMessage()));
      }

      for (ShipmentItem si : shipmentItemList) {
        si.ShipmentId = shipmentObj.id;
      }

      try {
        insert shipmentItemList;

        system.debug('shipmentItemList: ' + shipmentItemList);
      } catch (Exception ex) {
        system.debug('Exception: ' + ex.getMessage());
        exceptionsList.add(String.valueOf(ex.getMessage()));
      }
    }

    if (declinedShipmentObj != null) {
      try {
        insert declinedShipmentObj;

        system.debug('declinedShipmentObj: ' + declinedShipmentObj);
      } catch (Exception ex) {
        system.debug('Exception: ' + ex.getMessage());
        exceptionsList.add(String.valueOf(ex.getMessage()));
      }

      for (DeclinedShipmentItem__c declinedShipmentItem : declinedShipmentItems) {
        declinedShipmentItem.DeclinedShipmentId__c = declinedShipmentObj.Id;
        if (declinedShipmentObj.Quantity__c == null) {
          declinedShipmentObj.Quantity__c = declinedShipmentItem.Quantity__c;
        } else {
          declinedShipmentObj.Quantity__c += declinedShipmentItem.Quantity__c;
        }
      }

      try {
        insert declinedShipmentItems;
        update declinedShipmentObj;

        system.debug('declinedShipmentItems: ' + declinedShipmentItems);
      } catch (Exception ex) {
        system.debug('Exception: ' + ex.getMessage());
        exceptionsList.add(String.valueOf(ex.getMessage()));
      }
    }
  }

  private static List<ShipmentItem> getShipmentItemsByFoiId(List<ShipmentItem> shipmentItems, ID fulfillmentItemID) {
    List<ShipmentItem> foundShipmentItems = new List<ShipmentItem>();
    for (ShipmentItem shipmentItem : shipmentItems) {
      if (shipmentItem.FulfillmentOrderLineItemId == fulfillmentItemID) {
        foundShipmentItems.add(shipmentItem);
      }
    }
    return foundShipmentItems;
  }

  private static List<DeclinedShipmentItem__c> getDeclinedShipmentItemsByFoiId(
    List<DeclinedShipmentItem__c> declinedShipmentItems,
    ID fulfillmentItemID
  ) {
    List<DeclinedShipmentItem__c> foundShipmentItems = new List<DeclinedShipmentItem__c>();
    for (DeclinedShipmentItem__c declinedShipmentItem : declinedShipmentItems) {
      if (declinedShipmentItem.FulfillmentOrderProductId__c == fulfillmentItemID) {
        foundShipmentItems.add(declinedShipmentItem);
      }
    }
    return foundShipmentItems;
  }

  private static void updateFulfillmentItemStatus(FulfillmentOrder fOrder, List<FulfillmentOrderLineItem> fOrderItems) {
    // retrieve all objects again from database after updates
    List<ShipmentItem> shipmentItems = [
      SELECT Id, Quantity, FulfillmentOrderLineItemId
      FROM ShipmentItem
      WHERE ShipmentId IN (SELECT Id FROM Shipment WHERE FulfillmentOrderId = :fOrder.Id)
    ];

    List<DeclinedShipment__c> declinedShipments = [
      SELECT Id, Status__c
      FROM DeclinedShipment__c
      WHERE FulfillmentOrderId__c = :fOrder.Id
    ];

    List<DeclinedShipmentItem__c> declinedShipmentItems = [
      SELECT Id, Quantity__c, FulfillmentOrderProductId__c
      FROM DeclinedShipmentItem__c
      WHERE DeclinedShipmentId__c IN (SELECT Id FROM DeclinedShipment__c WHERE FulfillmentOrderId__c = :fOrder.Id)
    ];

    OrderSummary orderSummary = [SELECT Id, Status FROM OrderSummary WHERE Id = :fOrder.OrderSummaryId LIMIT 1];

    List<OrderItemSummary> orderItemSummaryList = [
      SELECT Id, QuantityShipped, Declined_Quantity__c
      FROM OrderItemSummary
      WHERE OrderSummaryId = :fOrder.OrderSummaryId
    ];
    Map<Id, OrderItemSummary> oiSummaryLookupMap = new Map<Id, OrderItemSummary>();
    for (OrderItemSummary oiSummary : orderItemSummaryList) {
      oiSummaryLookupMap.put(oiSummary.Id, oiSummary);
    }

    Boolean isFullyFulfilled = true;
    Boolean hasCancellations = false;
    Boolean hasShipments = false;

    // list to store cancellation quantities to cancel the FulfillmentOrderLineItems later
    List<ConnectApi.FulfillmentOrderLineItemInputRepresentation> FOLIRList = new List<ConnectApi.FulfillmentOrderLineItemInputRepresentation>();

    for (FulfillmentOrderLineItem fOrderItem : fOrderItems) {
      OrderItemSummary oiSummary = oiSummaryLookupMap.get(fOrderItem.OrderItemSummaryId);
      List<ShipmentItem> fShipmentItems = getShipmentItemsByFoiId(shipmentItems, fOrderItem.Id);
      List<DeclinedShipmentItem__c> fDeclinedShipmentItems = getDeclinedShipmentItemsByFoiId(
        declinedShipmentItems,
        fOrderItem.Id
      );

      Decimal quantityToFulfill = fOrderItem.OriginalQuantity;
      Decimal totalShippedQuantity = 0.0;
      Decimal QuantityToCancel = 0.0;
      // deduct shipped items
      for (ShipmentItem fShipmentItem : fShipmentItems) {
        quantityToFulfill -= fShipmentItem.Quantity;
        totalShippedQuantity += fShipmentItem.Quantity;
        hasShipments = true;
      }
      if (oiSummary != null) {
        oiSummary.QuantityShipped = totalShippedQuantity;
        if (oiSummary.Declined_Quantity__c == null) {
          oiSummary.Declined_Quantity__c = 0;
        }
      }
      // if quantity to fulfill is 0, everything is fulfilled so we can continue
      if (quantityToFulfill != 0) {
        // deduct cancelled items and prep them for cancellation call to OCI
        for (DeclinedShipmentItem__c fDeclinedShipmentItem : fDeclinedShipmentItems) {
          quantityToFulfill -= fDeclinedShipmentItem.Quantity__c;
          QuantityToCancel += fDeclinedShipmentItem.Quantity__c;
        }
        if (quantityToFulfill == 0) {
          // if this is 0, it means that all items are accounted for but there are cancellations
          hasCancellations = true;
        } else {
          // if this is not 0, it means the fulfillment order is not yet completed
          isFullyFulfilled = false;
        }
      }
      // prepare for FulfillmentOrderLineItems cancellation call
      if (QuantityToCancel > 0) {
        ConnectApi.FulfillmentOrderLineItemInputRepresentation FOLIR = new ConnectApi.FulfillmentOrderLineItemInputRepresentation();
        FOLIR.fulfillmentOrderLineItemId = fOrderItem.Id;
        FOLIR.quantity = QuantityToCancel;
        oiSummary.Declined_Quantity__c = QuantityToCancel;
        FOLIRList.add(FOLIR);
      }
    }
    update orderItemSummaryList;
    if (isFullyFulfilled) {
      if (hasCancellations && !hasShipments) {
        // order is fully cancelled
        orderSummary.Status = 'CANCELED';
        fOrder.Status = 'Canceled';
      } else {
        // order is complete and has at least one product shipped, set fulfillment order status to fulfilled
        // This is important for the rest of the process
        if (hasCancellations && hasShipments) {
          // if we have both cancellations and shipments, the order is partially fulfilled
          orderSummary.Status = 'PARTIALLY FULFILLED';
          fOrder.Status = 'Partially Fulfilled';
        } else {
          // if not, the order is fully fulfilled
          orderSummary.Status = 'FULFILLED';
          fOrder.Status = 'Fulfilled';
        }
      }
      if (declinedShipments.size() > 0) {
        // activate the DeclinedShipments
        for (DeclinedShipment__c declinedShipment : declinedShipments) {
          declinedShipment.Status__c = 'Activated';
        }
        update declinedShipments;
        // and cancel the FulfillmentOrderLineItems
        ConnectApi.FulfillmentOrderLineItemsToCancelInputRepresentation FOIR = new ConnectApi.FulfillmentOrderLineItemsToCancelInputRepresentation();
        FOIR.fulfillmentOrderLIneItemsToCancel = FOLIRList;
        ConnectApi.FulfillmentOrder.cancelFulfillmentOrderLineItems(fOrder.Id, FOIR);
      }
    } else {
      // we did not receive updates on all products yet, mark order as incomplete
      orderSummary.Status = 'INCOMPLETE';
      fOrder.Status = 'Incomplete';
    }
    update orderSummary;
    update fOrder;
  }

  global class orderItemWrapper {
    public String aggregatedLineID;
    public String sku;
    public String shippedQuantity;
    public String declinedQuantity;
  }

  private class shippedItemsHelper {
    Integer shippedQuantity;
    Integer declinedQuantity;
  }
}
