public with sharing class RestServiceFulfilmentOrder {
  //invocable Method to Query all data to be sent over to API
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
          System.enqueueJob(new AsyncFulfillmentOrder(itemsToProcess));
          itemsToProcess = new Map<Id, Integer>();
        }
      }
      if (itemsToProcess.size() >= 0) {
        System.enqueueJob(new AsyncFulfillmentOrder(itemsToProcess));
      }
    } else {
      AsyncFulfillmentOrder asyncFulfillmentOrder = new AsyncFulfillmentOrder(itemMap);
      asyncFulfillmentOrder.execute(null);
    }
  }

  class fulfillmentOrderWrapper {
    public String transactionID;
    public String customerId;
    public String orderReferenceNumber; //string
    public String salesChannelID; //string
    public String postNumber; //string
    public String fulfilmentOrderID; //string
    public String plantCode; //string
    public String createdDate; //datetime
    public String deliveryDate; //date
    public String deliveryMethod; //string
    public String carrierID; //string
    public String pickupLocationCode; //string
    public cls_billingAddress billingAddress;
    public cls_shippingAddress shippingAddress;
    public cls_orderItems[] orderItems;
  }

  class cls_billingAddress {
    public String street; //string
    public String street2; //string
    public String street3; //string
    public String city; //string
    public String countryCode; //string
    public String emailAddress; //string
    public String firstName; //string
    public String lastName; //string
    public String phoneNumber; //string
    public String postalCode; //string
  }

  class cls_shippingAddress {
    public String street; //string
    public String street2; //string
    public String street3; //string
    public String city; //string
    public String countryCode; //string
    public String emailAddress; //string
    public String firstName; //string
    public String lastName; //string
    public String phoneNumber; //string
    public String postalCode; //string
  }

  class cls_orderItems {
    public String sku; //string
    public String aggregatedLineID; //string
    public String[] itemLines; //string
    public String quantity; //number
    public String productName; //string
  }

  private class AsyncFulfillmentOrder implements Queueable, Database.AllowsCallouts {
    private Map<Id, Integer> internalMap;
    private List<API_Exception__c> exceptions;
    private List<ProcessException> processExceptions;
    private API_Endpoint__c endpoint;

    public AsyncFulfillmentOrder(Map<Id, Integer> itemsToProcess) {
      internalMap = itemsToProcess;
      exceptions = new List<API_Exception__c>();
      processExceptions = new List<ProcessException>();
    }

    public void execute(QueueableContext context) {
      List<FulfillmentOrder> fOrderList = [
        SELECT
          Transaction_ID__c,
          Fulfillment_Order_Id__c,
          FulfilledToEmailAddress,
          FulfilledToPhone,
          FulfilledFromLocationId,
          DeliveryMethodId,
          id,
          CreatedDate,
          FulfillmentOrderNumber,
          DeliveryMethod.Name,
          DeliveryMethod.Carrier,
          OrderSummary.OriginalOrderId,
          Fulfilled_to_Location_External_Reference__c,
          Country_Code__c
        FROM FulfillmentOrder
        WHERE ID IN :internalMap.keySet()
      ];

      List<Id> orderIds = new List<Id>();

      for (FulfillmentOrder fOrder : fOrderList) {
        orderIds.add(fOrder.OrderSummary.OriginalOrderId);
      }

      //quering Order Object by passing in orderIds
      Map<Id, Order> orderMap = new Map<Id, Order>(
        [
          SELECT
            id,
            Delivery_Date__c,
            Post_Number__c,
            SalesChannelStoreID__c,
            SalesChannelExternalReference__c,
            Pick_Up_Location_Code__c,
            AccountId,
            SalesChannel.SalesChannelName,
            Magento_SalesChannel_Name__c,
            SalesChannelCountryCode__c,
            OrderReferenceNumber,
            OriginalOrderId,
            BillingStreet1__c,
            BillingStreet2__c,
            BillingStreet3__c,
            BillingHouseNumber__c,
            BillingCity,
            BillingCountry,
            BillingEmailAddress,
            BillingFirstName__c,
            BillingLastName__c,
            BillingPostalCode,
            BillingPhoneNumber,
            ShippingStreet1__c,
            ShippingStreet2__c,
            ShippingStreet3__c,
            ShippingHouseNumber__c,
            ShippingCity,
            ShippingCountry,
            ShippingFirstName__c,
            ShippingLastName__c,
            ShippingPostalCode,
            OriginalBrand__c,
            CountryCode__c,
            Account.External_Id__c
          FROM Order
          WHERE id IN :orderIds
        ]
      );

      //quering Order Object by passing in orderIds
      List<OrderItem> oItemList = [
        SELECT id, Quantity, SKU__c, LineNumber, Product2.Name, OrderId
        FROM OrderItem
        WHERE Type != 'Delivery Charge' AND OrderId = :orderIds
      ];

      endpoint = [
        SELECT Base_URL__c
        FROM API_Endpoint__c
        WHERE Name = 'Fulfillment Order API Base Endpoint' AND isDeleted = FALSE
        LIMIT 1
      ];

      for (FulfillmentOrder fOrder : fOrderList) {
        Order order = orderMap.get(fOrder.OrderSummary.OriginalOrderId);
        String transactionID = TransactionId.generateID();
        String orderReferenceNumber = order.OrderReferenceNumber;
        String salesChannelExternalReference = order.SalesChannelExternalReference__c;
        String salesChannelStoreId = order.SalesChannelStoreID__c;
        String fulfilmentOrderID_s = String.valueOf(
          salesChannelStoreId + '-' + orderReferenceNumber + '-0' + 1
        );
        List<OrderItem> orderItems = getOrderItemsByOrderId(oItemList, order.Id);
        String JSONBody = JSON.serialize(constructJSON(fOrder, order, orderItems, transactionID, fulfilmentOrderID_s));
        String brand = order.Magento_SalesChannel_Name__c;
        String country = order.SalesChannelCountryCode__c;

        List<String> exceptionList = callApi(JSONBody, brand, country, orderReferenceNumber, fOrder, transactionID);
        updateTransactionId(fOrder, transactionID, fulfilmentOrderID_s, salesChannelExternalReference);

        if (exceptionList.size() > 0) {
          API_Exception__c apiExceptionObj = new API_Exception__c();
          apiExceptionObj.API_Name__c = 'Shipment Confirmation API';
          apiExceptionObj.Exception__c = String.valueOf(exceptionList);
          apiExceptionObj.JSON_Body__c = JSONBody;
          exceptions.add(apiExceptionObj);
        } else {
          fOrder.Status = 'Pickpack';
        }
      }

      if (exceptions.size() > 0) {
        insert exceptions;
      }
      if (processExceptions.size() > 0) {
        insert processExceptions;
      }
      update fOrderList;
    }

    private List<OrderItem> getOrderItemsByOrderId(List<OrderItem> allOrderItems, Id orderId) {
      List<OrderItem> returnObj = new List<OrderItem>();
      for (OrderItem orderItem : allOrderItems) {
        if (orderItem.OrderId == orderId) {
          returnObj.add(orderItem);
        }
      }
      return returnObj;
    }

    private fulfillmentOrderWrapper constructJSON(
      FulfillmentOrder fOrder,
      Order order,
      List<OrderItem> orderItems,
      String transactionID,
      String fulfilmentOrderID
    ) {
      String orderReference = order.OrderReferenceNumber;
      String salesChannelStoreId = order.SalesChannelStoreID__c;
      fulfillmentOrderWrapper fOrderWrapper = new fulfillmentOrderWrapper();
      cls_billingAddress billingAddressWrapper = new cls_billingAddress();
      cls_shippingAddress shippingAddressWrapper = new cls_shippingAddress();

      fOrderWrapper.transactionID = transactionID;
      fOrderWrapper.salesChannelID = salesChannelStoreId;
      fOrderWrapper.orderReferenceNumber = orderReference;
      fOrderWrapper.fulfilmentOrderID = fulfilmentOrderID;
      fOrderWrapper.customerId = order.Account.External_Id__c;
      fOrderWrapper.plantCode = fOrder.Fulfilled_to_Location_External_Reference__c;
      fOrderWrapper.postNumber = order.Post_Number__c;
      fOrderWrapper.createdDate = String.valueOf(fOrder.CreatedDate);
      fOrderWrapper.deliveryDate = String.valueOf(order.Delivery_Date__c);
      fOrderWrapper.deliveryMethod = fOrder.DeliveryMethod.Name;
      fOrderWrapper.carrierID = fOrder.DeliveryMethod.Carrier;
      fOrderWrapper.pickupLocationCode = order.Pick_Up_Location_Code__c;

      //initializing and inserting values to Billing Address Wrapper class Variables
      billingAddressWrapper.street = order.BillingStreet1__c;
      if (String.isNotBlank(order.BillingHouseNumber__c)) {
        billingAddressWrapper.street += ', ' + order.BillingHouseNumber__c;
      }
      billingAddressWrapper.street2 = stringOrEmpty(order.BillingStreet2__c);
      billingAddressWrapper.street3 = stringOrEmpty(order.BillingStreet3__c);
      billingAddressWrapper.city = order.BillingCity;
      billingAddressWrapper.countryCode = order.BillingCountry;
      billingAddressWrapper.emailAddress = fOrder.FulfilledToEmailAddress;
      billingAddressWrapper.firstName = order.BillingFirstName__c;
      billingAddressWrapper.lastName = order.BillingLastName__c;
      billingAddressWrapper.phoneNumber = order.BillingPhoneNumber;
      billingAddressWrapper.postalCode = order.BillingPostalCode;

      //initializing and inserting values to Shipping Address Wrapper class Variables
      shippingAddressWrapper.street = order.ShippingStreet1__c;
      if (String.isNotBlank(order.ShippingHouseNumber__c)) {
        shippingAddressWrapper.street += ', ' + order.ShippingHouseNumber__c;
      }
      shippingAddressWrapper.street2 = stringOrEmpty(order.ShippingStreet2__c);
      shippingAddressWrapper.street3 = stringOrEmpty(order.ShippingStreet3__c);
      shippingAddressWrapper.countryCode = order.ShippingCountry;
      shippingAddressWrapper.city = order.ShippingCity;
      shippingAddressWrapper.emailAddress = fOrder.FulfilledToEmailAddress;
      shippingAddressWrapper.firstName = order.ShippingFirstName__c;
      shippingAddressWrapper.lastName = order.ShippingLastName__c;
      shippingAddressWrapper.phoneNumber = order.BillingPhoneNumber;
      shippingAddressWrapper.postalCode = order.ShippingPostalCode;

      fOrderWrapper.billingAddress = billingAddressWrapper;
      fOrderWrapper.shippingAddress = shippingAddressWrapper;
      fOrderWrapper.orderItems = processOrderItems(order, orderItems);

      return fOrderWrapper;
    }

    private List<cls_orderItems> processOrderItems(Order order, List<OrderItem> oItemList) {
      Map<String, cls_orderItems> orderitemsWrapperList = new Map<String, cls_orderItems>();

      Integer aggregatedLineID = 1;
      for (Integer i = 0; i < oItemList.size(); i++) {
        if (orderitemsWrapperList.containsKey(oItemList[i].SKU__c)) {
          cls_orderItems oitemWrapper = orderitemsWrapperList.get(oItemList[i].SKU__c);
          Integer quantity = Integer.valueOf(oitemWrapper.quantity);
          quantity += Integer.valueOf(oItemList[i].Quantity);
          oitemWrapper.quantity = String.valueOf(quantity);
          orderitemsWrapperList.put(oItemList[i].SKU__c, oitemWrapper);
        } else {
          cls_orderItems oitemWrapper = new cls_orderItems();
          oitemWrapper.aggregatedLineID = String.valueOf(aggregatedLineID);
          oitemWrapper.quantity = String.valueOf(Integer.valueOf(oItemList[i].Quantity));
          oitemWrapper.sku = oItemList[i].SKU__c;
          oitemWrapper.productName = oItemList[i].Product2.Name;
          orderitemsWrapperList.put(oItemList[i].SKU__c, oitemWrapper);
          aggregatedLineID += 1;
        }
      }

      List<String> lineIds = new List<String>();
      String lineId = '';
      Integer itemCount = 0;
      Integer curNumber = 0;

      for (cls_orderItems oi : orderitemsWrapperList.values()) {
        lineIds = new List<String>();
        if (itemCount != 0) {
          for (integer j = itemCount + 1; j <= Integer.valueOf(oi.quantity) + itemCount; j++) {
            lineIds.add(String.valueOf(j));
            curNumber = j;
          }
          itemCount = curNumber;
        } else {
          for (integer j = 1; j <= Integer.valueOf(oi.Quantity); j++) {
            lineIds.add(String.valueOf(j));
            curNumber = j;
          }
          itemCount = curNumber;
        }
        oi.itemLines = lineIds;
      }
      return orderitemsWrapperList.values();
    }

    public List<String> callApi(
      String JSONBody,
      String brand,
      String country,
      String orderReferenceNumber,
      FulfillmentOrder fOrder,
      String transactionID
    ) {
      List<String> exceptionList = new List<String>();
      System.debug('Fulfillment Order sent to API: ' + JSONBody);
      HttpRequest req = new HttpRequest();
      req.setEndpoint(endpoint.Base_URL__c + brand + '/' + country + '/' + orderReferenceNumber);
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
        ProcessException processExc = new ProcessException();
        processExc.Status = 'New';
        processExc.Severity = 'Low';
        processExc.AttachedToId = fOrder.id;
        processExc.ExternalReference = orderReferenceNumber;
        processExc.TransactionId__c = transactionID;
        processExc.Priority = 'Low';
        processExc.Category = 'Fulfillment';
        processExc.Message = 'Fulfilment Order API callout is Failed';
        processExc.StatusCode__c = res.getStatusCode();
        processExc.Description = res.getBody().left(2000);
        processExc.Retries__c = internalMap.get(fOrder.id);
        processExceptions.add(processExc);
        exceptionList.add('Fulfilment Order API callout is Failed');
      }

      if (exceptionList.size() > 0) {
        API_Exception__c apiExceptionObj = new API_Exception__c();
        apiExceptionObj.API_Name__c = 'Fulfillment Order API';
        apiExceptionObj.Exception__c = String.valueOf(exceptionList);
        apiExceptionObj.JSON_Body__c = JSONBody;
        exceptions.add(apiExceptionObj);
      }
      return exceptionList;
    }

    public void updateTransactionId(
      FulfillmentOrder fOrder,
      String transactionID,
      String fulfillmentOrderId,
      String salesChannelExternalReference
    ) {
      fOrder.Fulfillment_Order_Id__c = fulfillmentOrderId;
      fOrder.Transaction_Id__c = transactionID;
      fOrder.SalesChannelExternalReferenceNumber__c = salesChannelExternalReference;
    }

    private String stringOrEmpty(String str) {
      if (String.isNotBlank(str)) {
        return str;
      } else {
        return '';
      }
    }
  }
}
