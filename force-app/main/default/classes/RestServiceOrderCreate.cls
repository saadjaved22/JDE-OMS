@RestResource(urlMapping='/salesorder/create/v1/*')
global with sharing class RestServiceOrderCreate {
  private static Boolean isSubscriptionOrder = false;
  public static List<String> exceptionList = new List<String>();

  @HttpPost
  global static List<RestServiceUtils.RestServiceErrorMessage> getData(
    String deliveryDate,
    String orderReferenceNumber,
    String originalOrderID,
    String name,
    String orderedDate,
    String orderCurrency,
    String deliveryMethod,
    String grossShippingFee,
    String netShippingFee,
    String pickupLocationCode,
    String carrierID,
    String invoiceID,
    String transactionID,
    String postNumber,
    accountWrapper account,
    salesChannelWrapper salesChannel,
    addressWrapper billingAddress,
    addressWrapper shippingAddress,
    orderItemWrapper[] orderItems,
    paymentWrapper[] payment
  ) {
    List<Order> existingOrderList = [SELECT id FROM Order WHERE OrderReferenceNumber = :orderReferenceNumber];

    if (existingOrderList.size() > 0) {
      ProcessException processExc = new ProcessException();
      processExc.Status = 'New';
      processExc.Severity = 'Low';
      processExc.AttachedToId = existingOrderList[0].id;
      processExc.ExternalReference = orderReferenceNumber;
      processExc.TransactionId__c = transactionID;
      processExc.Priority = 'Low';
      processExc.Category = 'Place Order';
      processExc.Message = 'Duplicate order ' + orderReferenceNumber;
      processExc.Description = 'Order Reference Number: ' + OrderReferenceNumber + ' already exists in OMS';
      exceptionList.add('Order Reference Number: ' + OrderReferenceNumber + ' already exists in OMS');

      try {
        insert processExc;
      } catch (Exception ex) {
        system.debug('Exception: ' + ex.getMessage());
        exceptionList.add(ex.getMessage());
      }
    } else {
      // new order
      // Get the sales channel
      SalesChannel salesChannelObj = getSalesChannel(salesChannel);

      // before we create objects, we do a reservation for this order
      Boolean reservationSucceeded = RestServiceCreateReservation.makeReservation(
        orderReferenceNumber,
        salesChannelObj.Location_Group__r.ExternalReference,
        orderItems,
        salesChannelObj.SalesChannelName,
        transactionID,
        true
      );

      if (!reservationSucceeded) {
        // if reservation fails, we skip the order creation and return an error message.
        exceptionList.add('Reservation failed, order has NOT been created');
        SendFailedReservationMessage(transactionID, originalOrderID, orderReferenceNumber, salesChannel.salesChannel);
      } else {
        String brand = salesChannel.salesChannel;
        String country = salesChannel.countryCode;
        String externalACCID = account.emailAddress + country + salesChannel.storeName;
        Boolean isGuestOrder = Boolean.valueOf(account.isGuestCheckout);

        // Create a new account or use the existing one
        ID accID = getAccount(account, salesChannel.storeName, externalACCID);

        // create the order object
        Id orderID = createOrder(
          deliveryDate,
          postNumber,
          accId,
          salesChannelObj.Id,
          orderReferenceNumber,
          originalOrderID,
          isGuestOrder,
          name,
          orderedDate,
          orderCurrency,
          grossShippingFee,
          netShippingFee,
          deliveryMethod,
          pickupLocationCode,
          carrierID,
          invoiceID,
          transactionID,
          brand,
          country,
          billingAddress,
          shippingAddress,
          salesChannel,
          orderItems,
          payment
        );

        // create the order items and related objects
        createOrderItems(
          shippingAddress,
          deliveryMethod,
          orderId,
          orderedDate,
          orderItems,
          grossShippingFee,
          netShippingFee,
          salesChannel.countryCode,
          salesChannelObj.Location_Group__c
        );

        // create the payment objects
        createPayments(accID, orderID, orderCurrency, payment);

        // set the order status to trigger the order orchestration flow
        updateOrder(orderID);

        // if there are any exceptions, log them
        if (exceptionList.size() > 0) {
          API_Exception__c exceptionObj = new API_Exception__c();
          exceptionObj.API_Name__c = 'Order Create API';
          RestRequest req = RestContext.request;
          exceptionObj.RestRequest__c = String.valueOf(req);
          exceptionObj.Request_URI__c = String.valueOf(req.requestURI);
          exceptionObj.Exception__c = String.valueOf(exceptionList);

          try {
            insert exceptionObj;
          } catch (Exception ex) {
            system.debug('Exception at API_Exception DML: ' + ex.getMessage());
          }
        } else {
          finalizeReservation(
            orderReferenceNumber,
            salesChannelObj.Location_Group__r.ExternalReference,
            JSON.serialize(orderItems),
            salesChannelObj.SalesChannelName,
            transactionID
          );
        }
      }
    }

    if (exceptionList.size() > 0 && !Test.isRunningTest()) {
      RestContext.response.statusCode = 500;
    }

    return RestServiceUtils.ConvertExceptionList(exceptionList);
  }

  @future(callout=true)
  private static void finalizeReservation(
    String orderReferenceNumber,
    String locationExternalReference,
    String orderItems,
    String salesChannel,
    String transactionID
  ) {
    RestServiceCreateReservation.makeReservation(
      orderReferenceNumber,
      locationExternalReference,
      (RestServiceOrderCreate.orderItemWrapper[]) JSON.deserialize(
        orderItems,
        RestServiceOrderCreate.orderItemWrapper[].class
      ),
      salesChannel,
      transactionID,
      false
    );
  }

  public static ID getAccount(accountWrapper account, String fullBrandName, String exID) {
    ID accID;

    List<Account> existingAccs = [
      SELECT id
      FROM Account
      WHERE External_Id__c = :exID
      LIMIT 1
    ];

    if (existingAccs.size() > 0) {
      accID = existingAccs[0].id;
      // update account with (only) is_guest according to this last order
      existingAccs[0].Is_Guest__c = Boolean.valueOf(account.isGuestCheckout);
      upsert (existingAccs[0]);
    } else {
      // create new account
      List<RecordType> accRecordType = [
        SELECT id
        FROM RecordType
        WHERE Name = 'Person Account'
      ];

      Account newAcc = new Account();
      newAcc.LastName = account.lastName;
      newAcc.FirstName = account.firstName;
      newAcc.PersonEmail = account.emailAddress;
      newAcc.Phone = account.phoneNumber;
      newAcc.RecordTypeId = accRecordType[0].id;
      newAcc.External_Id__c = exID;
      newAcc.brand__c = fullBrandName;
      newAcc.Is_Guest__c = Boolean.valueOf(account.isGuestCheckout);

      try {
        insert newAcc;
        accID = newAcc.Id;
      } catch (Exception ex) {
        system.debug('Exception: ' + ex);
        exceptionList.add(ex.getMessage());
      }
    }

    return accID;
  }

  public static SalesChannel getSalesChannel(salesChannelWrapper salesChannel) {
    SalesChannel salesChannelObj;
    String salesChannelName = salesChannel.salesChannelID + '_' + salesChannel.countryCode;

    List<SalesChannel> sCList = [
      SELECT id, Location_Group__c, Location_Group__r.ExternalReference, SalesChannelName
      FROM SalesChannel
      WHERE ExternalChannelNumber LIKE :salesChannelName
      LIMIT 1
    ];

    if (sCList.size() > 0) {
      salesChannelObj = sCList[0];
    }

    return salesChannelObj;
  }

  public static ID createOrder(
    String deliveryDate,
    String postNumber,
    ID accId,
    ID salesChannelID,
    String orderReferenceNumber,
    String originalOrderID,
    Boolean isGuestOrder,
    String name,
    String orderedDate,
    String orderCurrency,
    String grossShippingFee,
    String netShippingFee,
    String deliveryMethod,
    String pickupLocationCode,
    String carrierID,
    String invoiceID,
    String transactionID,
    String brand,
    String country,
    addressWrapper billingAddress,
    addressWrapper shippingAddress,
    salesChannelWrapper salesChannel,
    orderItemWrapper[] orderItems,
    paymentWrapper[] payment
  ) {
    Id orderID;

    Order orderObj = new Order();

    orderObj.Magento_SalesChannel_Name__c = salesChannel.salesChannel;
    orderObj.Magento_Store_Name__c = salesChannel.storeName;
    orderObj.Post_Number__c = postNumber;
    if (deliveryDate != null) {
      orderObj.Delivery_Date__c = Date.valueOf(deliveryDate);
    }
    orderObj.Delivery_Method_new__c = deliveryMethod;
    orderObj.Shipping_Carrier__c = carrierID;
    orderObj.Pick_Up_Location_Code__c = pickupLocationCode;
    orderObj.TaxLocaleType = 'Gross';
    orderObj.Gross_Shipping_Fees__c = decimal.valueOf(grossShippingFee);
    orderObj.Net_Shipping_Fees__c = decimal.valueOf(netShippingFee);
    orderObj.OrderedDate = Datetime.valueOf(orderedDate);
    orderObj.EffectiveDate = Date.valueOf(orderedDate);
    orderObj.OrderReferenceNumber = orderReferenceNumber;
    orderObj.OriginalOrderReference__c = originalOrderID;
    orderObj.SalesChannelExternalReference__c = salesChannel.salesChannelID + '_' + salesChannel.countryCode;
    orderObj.SalesChannelStoreID__c = salesChannel.salesChannelID;
    orderObj.SalesChannelCountryCode__c = salesChannel.countryCode;
    orderObj.Name = name;
    orderObj.AccountId = accId;
    orderObj.is_Guest_Order__c = isGuestOrder;
    orderObj.Status = 'Draft';
    orderObj.ShippingCity = shippingAddress.city;
    orderObj.ShippingCountry = shippingAddress.country;
    orderObj.ShippingPostalCode = shippingAddress.postalCode;
    orderObj.ShippingState = shippingAddress.state;
    if (deliveryMethod == 'home') {
      orderObj.ShippingStreet = createStreet(shippingAddress);
      orderObj.ShippingStreet1__c = shippingAddress.street;
      orderObj.ShippingStreet2__c = shippingAddress.street2;
    } else {
      // deliveryMethod == 'pickuppoint' (SFOMS-253)
      orderObj.ShippingStreet = shippingAddress.street.substringBefore(',');
      orderObj.ShippingStreet1__c = shippingAddress.street.substringBefore(',');
      orderObj.ShippingStreet2__c = shippingAddress.street.substringAfter(',').trim();
    }
    orderObj.ShippingStreet3__c = shippingAddress.street3;
    orderObj.ShippingHouseName__c = shippingAddress.houseName;
    orderObj.ShippingHouseNumber__c = shippingAddress.houseNumber;
    orderObj.ShippingAdministrativeArea__c = shippingAddress.administrativeArea;
    orderObj.ShippingFirstName__c = shippingAddress.firstName;
    orderObj.ShippingLastName__c = shippingAddress.lastName;
    orderObj.BillingCity = billingAddress.city;
    orderObj.BillingCountry = billingAddress.country;
    orderObj.BillingPostalCode = billingAddress.postalcode;
    orderObj.BillingState = billingAddress.state;
    orderObj.BillingStreet = createStreet(billingAddress);
    orderObj.BillingStreet1__c = billingAddress.street;
    orderObj.BillingStreet2__c = billingAddress.street2;
    orderObj.BillingStreet3__c = billingAddress.street3;
    orderObj.BillingHouseName__c = billingAddress.houseName;
    orderObj.BillingHouseNumber__c = billingAddress.houseNumber;
    orderObj.BillingAdministrativeArea__c = billingAddress.administrativeArea;
    orderObj.BillingPhoneNumber = billingAddress.phoneNumber;
    orderObj.BillingFirstName__c = billingAddress.firstName;
    orderObj.BillingLastName__c = billingAddress.lastName;
    orderObj.SalesChannelId = salesChannelID;
    orderObj.CurrencyIsoCode = orderCurrency;
    orderObj.InvoiceID__c = invoiceID;
    orderObj.Transaction_Id__c = transactionID;
    orderObj.OriginalBrand__c = brand;
    orderObj.CountryCode__c = country;
    orderObj.API_JSON_Body__c = JSON.serialize(
      'postNumber: ' +
        postNumber +
        'accId: ' +
        accId +
        'salesChannelID: ' +
        salesChannelID +
        'orderReferenceNumber: ' +
        orderReferenceNumber +
        'originalOrderID: ' +
        originalOrderID +
        'name: ' +
        name +
        'orderedDate:' +
        orderedDate +
        'orderCurrency: ' +
        orderCurrency +
        'grossShippingFee:' +
        grossShippingFee +
        'netShippingFee:' +
        netShippingFee +
        'pickupLocationCode:' +
        pickupLocationCode +
        'carrierID:' +
        carrierID +
        'invoiceID:' +
        invoiceID +
        'billingAddress: ' +
        billingAddress +
        'shippingAddress: ' +
        shippingAddress +
        'salesChannel: ' +
        salesChannel +
        'orderItems: ' +
        orderItems +
        'payment: ' +
        payment
    );

    try {
      insert orderObj;
      orderId = orderObj.id;
    } catch (Exception ex) {
      system.debug('Exception: ' + ex);
      exceptionList.add(ex.getMessage());
    }

    return orderId;
  }

  private static ID GetDeliveryMethodId(String deliveryMethod, String countryCode) {
    String externalReference;
    if (deliveryMethod == 'home') {
      externalReference = 'Home_' + countryCode;
    } else if (deliveryMethod == 'pickuppoint') {
      externalReference = 'PCK_' + countryCode;
    }
    OrderDeliveryMethod orderDeliveryMethod = [
      SELECT Id
      FROM OrderDeliveryMethod
      WHERE ReferenceNumber LIKE :externalReference
      LIMIT 1
    ];
    return orderDeliveryMethod.Id;
  }

  public static Product2 getDeliveryProduct(String deliveryMethod, String countryCode) {
    ID orderDeliveryMethodId = GetDeliveryMethodId(deliveryMethod, countryCode);
    return [
      SELECT id, name
      FROM product2
      WHERE
        Id IN (
          SELECT ProductId
          FROM OrderDeliveryMethod
          WHERE Id = :orderDeliveryMethodId
        )
      LIMIT 1
    ];
  }

  public static orderItemMapper createShippingOrderItem(
    String orderId,
    String grossShippingFee,
    String netShippingFee,
    ID deliveryGroupId,
    String deliveryMethod,
    String countryCode,
    String orderedDate,
    ID locationGroupId
  ) {
    //have to add product if it not exist in oms
    Product2 product = getDeliveryProduct(deliveryMethod, countryCode);
    // create shipping order line
    OrderItem shippingLineItem = new OrderItem();
    shippingLineItem.OrderId = orderId;
    shippingLineItem.GrossUnitPrice = Decimal.valueOf(grossShippingFee);
    shippingLineItem.Quantity = 1;
    shippingLineItem.Product2Id = product.ID;
    shippingLineItem.Type = 'Delivery Charge';
    shippingLineItem.UnitPrice = Decimal.valueOf(grossShippingFee);
    shippingLineItem.ListPrice = Decimal.valueOf(grossShippingFee);
    shippingLineItem.OrderDeliveryGroupId = deliveryGroupId;
    shippingLineItem.Description = product.Name;
    shippingLineItem.TotalLineAmount = Decimal.valueOf(netShippingFee);

    OrderItemTaxLineItem shippingTaxObj = new OrderItemTaxLineItem();
    shippingTaxObj.Amount = Decimal.valueOf(grossShippingFee) - Decimal.valueOf(netShippingFee);
    shippingTaxObj.Name = 'Tax';
    if (Decimal.valueOf(grossShippingFee) != 0 && Decimal.valueOf(netShippingFee) != 0) {
      shippingTaxObj.Rate = (Decimal.valueOf(grossShippingFee) / Decimal.valueOf(netShippingFee)) - 1;
    } else {
      shippingTaxObj.Rate = 0.0;
    }
    shippingTaxObj.Type = 'Actual';
    shippingTaxObj.TaxEffectiveDate = date.valueOf(orderedDate);

    orderItemMapper shippingMapper = new orderItemMapper();
    shippingMapper.orderItem = shippingLineItem;
    shippingMapper.orderItemTaxLineItem = shippingTaxObj;
    return shippingMapper;
  }

  private static Map<String, Product2> createOrRetrieveProducts(orderItemWrapper[] orderitems) {
    Map<String, Product2> productMap = new Map<String, Product2>();
    List<String> productSkus = new List<String>();
    for (orderItemWrapper orderItem : orderItems) {
      if (!productSkus.contains(orderItem.sku)) {
        productSkus.add(orderItem.sku);
      }
    }

    List<Product2> prodList = [
      SELECT id, StockKeepingUnit
      FROM product2
      WHERE StockKeepingUnit IN :productSkus
    ];

    List<Product2> newProducts = new List<Product2>();
    for (orderItemWrapper orderItem : orderItems) {
      if (productMap.containsKey(orderItem.sku)) {
        // SKU might have already been added if there are multiple order lines with the same sku
        // if so, skip it
        continue;
      }
      Product2 prodObj = findProduct(orderItem.sku, prodList);
      if (prodObj == null) {
        prodObj = new Product2();
        prodObj.Name = orderItem.productName;
        prodObj.StockKeepingUnit = orderItem.sku;
        newProducts.add(prodObj);
      }
      productMap.put(orderItem.sku, prodObj);
    }
    if (newProducts.size() > 0) {
      insert newProducts;
    }
    return productMap;
  }

  private static Product2 findProduct(String sku, List<Product2> prodList) {
    for (Product2 product : prodList) {
      if (product.StockKeepingUnit == sku) {
        return product;
      }
    }
    return null;
  }

  public static void createOrderItems(
    addressWrapper shippingAddress,
    String deliveryMethod,
    ID orderId,
    String orderedDate,
    orderItemWrapper[] orderitems,
    String grossShippingFee,
    String netShippingFee,
    String countryCode,
    Id locationGroupId
  ) {
    ID deliveryMethodId = GetDeliveryMethodId(deliveryMethod, countryCode);
    ID deliveryGroupId = createDeliveryGroup(orderId, deliveryMethodId, shippingAddress);
    Map<String, Product2> productMap = createOrRetrieveProducts(orderItems);

    List<OrderItem> orderItemsList = new List<OrderItem>();
    List<OrderItemTaxLineItem> taxObjList = new List<OrderItemTaxLineItem>();
    List<orderItemMapper> orderItemMappingList = new List<orderItemMapper>();

    orderItemMapper shippingOrderLineMapper = createShippingOrderItem(
      orderId,
      grossShippingFee,
      netShippingFee,
      deliveryGroupId,
      deliveryMethod,
      countryCode,
      orderedDate,
      locationGroupId
    );
    orderItemMappingList.add(shippingOrderLineMapper);
    orderItemsList.add(shippingOrderLineMapper.orderItem);

    if (orderitems.size() > 0) {
      for (orderItemWrapper orderItem : orderitems) {
        if (orderItem.type == 'bundle') {
          // bundle line items are ignored for now
          system.debug('orderItem.type: ' + orderItem.type);
        } else if (orderItem.type == 'subscription') {
          // subscription line items are used to flag the order as subscription order
          system.debug('orderItem.type: ' + orderItem.type);
          isSubscriptionOrder = true;
        } else {
          // orderItem.type == 'simple'
          system.debug('orderItem.type: ' + orderItem.type);

          Product2 product = productMap.get(orderItem.sku);

          OrderItem orderItemObj = new OrderItem();
          orderItemObj.OrderId = orderId;
          orderItemObj.ItemId__c = orderItem.itemID;
          orderItemObj.GrossUnitPrice = Decimal.valueOf(orderItem.grossUnitPrice);
          orderItemObj.Product2Id = product.Id;
          orderItemObj.Quantity = Decimal.valueOf(orderItem.quantity);
          orderItemObj.Type = 'Order Product';
          orderItemObj.Description = orderItem.productName;
          orderItemObj.UnitPrice = Decimal.valueOf(orderItem.unitPrice);
          orderItemObj.ListPrice = Decimal.valueOf(orderItem.unitPrice);
          orderItemObj.SKU__c = orderItem.sku;
          orderItemObj.OrderDeliveryGroupId = deliveryGroupId;
          orderItemObj.ReservedAtLocationId = locationGroupId;
          orderItemObj.TotalLineAmount = Decimal.valueOf(orderItem.totalLineAmount);

          orderItemsList.add(orderItemObj);

          if (orderItem.orderItemTax != null) {
            OrderItemTaxLineItem taxObj = new OrderItemTaxLineItem();
            taxObj.Amount = decimal.valueOf(orderItem.orderItemTax.amount);
            taxObj.Name = 'Tax';
            taxObj.Rate = Decimal.valueOf(orderItem.orderItemTax.rate);
            taxObj.Type = 'Actual';
            taxObj.TaxEffectiveDate = date.valueOf(orderedDate);

            orderItemMapper mapper = new orderItemMapper();
            mapper.orderItem = orderItemObj;
            mapper.orderItemTaxLineItem = taxObj;
            mapper.orderItemAdjustments = orderItem.orderItemAdjustments;
            orderItemMappingList.add(mapper);
          }
        }
      }

      if (orderItemsList.size() > 0) {
        try {
          insert orderItemsList;
        } catch (Exception ex) {
          system.debug('Exception: ' + ex);

          exceptionList.add(ex.getMessage());
        }
      }

      if (orderItemMappingList.size() > 0) {
        for (Integer i = 0; i < orderItemMappingList.size(); i++) {
          orderItemMappingList[i].orderItemTaxLineItem.OrderItemId = orderItemMappingList[i].orderItem.id;
          taxObjList.add(orderItemMappingList[i].orderItemTaxLineItem);
        }

        try {
          insert taxObjList;
        } catch (Exception ex) {
          system.debug('Exception ex: ' + ex);
          exceptionList.add(ex.getMessage());
        }

        List<OrderItemAdjustmentLineItem> adjsmntList = new List<OrderItemAdjustmentLineItem>();
        List<OrderItemTaxLineItem> taxAdjsmtList = new List<OrderItemTaxLineItem>();
        List<orderItemAdjustmentMapper> orderItemAdjustmentsMappingList = new List<orderItemAdjustmentMapper>();

        for (Integer i = 0; i < orderItemMappingList.size(); i++) {
          if (
            orderItemMappingList[i].orderItemAdjustments != null &&
            orderItemMappingList[i].orderItemAdjustments.size() > 0
          ) {
            for (Integer j = 0; j < orderItemMappingList[i].orderItemAdjustments.size(); j++) {
              OrderItemAdjustmentLineItem adjstObj = new OrderItemAdjustmentLineItem();
              adjstObj.Amount = Decimal.valueof(orderItemMappingList[i].orderItemAdjustments[j].amount);
              adjstObj.name = 'Adjustment';
              adjstObj.OrderItemId = orderItemMappingList[i].orderItem.id;
              adjsmntList.add(adjstObj);

              OrderItemTaxLineItem taxObj = new OrderItemTaxLineItem();
              taxObj.Amount = Decimal.valueof(
                orderItemMappingList[i].orderItemAdjustments[j].orderItemAdjustmentTax.amount
              );
              taxObj.Rate = Decimal.valueof(
                orderItemMappingList[i].orderItemAdjustments[j].orderItemAdjustmentTax.rate
              );
              taxObj.Type = 'Actual';
              taxObj.Name = 'Tax';
              taxObj.TaxEffectiveDate = date.valueOf(orderedDate);
              taxAdjsmtList.add(taxObj);

              orderItemAdjustmentMapper mapper = new orderItemAdjustmentMapper();
              mapper.orderItemAdjustment = adjstObj;
              mapper.orderItemTaxLineItem = taxObj;
              mapper.orderItemId = orderItemMappingList[i].orderItem.id;
              orderItemAdjustmentsMappingList.add(mapper);
            }
          }
        }

        if (adjsmntList.size() > 0) {
          try {
            insert adjsmntList;
          } catch (Exception ex) {
            system.debug('Exception ex: ' + ex);
            exceptionList.add(ex.getMessage());
          }

          for (integer i = 0; i < orderItemAdjustmentsMappingList.size(); i++) {
            orderItemAdjustmentsMappingList[i]
              .orderItemTaxLineItem.OrderItemAdjustmentLineItemId = orderItemAdjustmentsMappingList[i]
              .orderItemAdjustment.id;
            orderItemAdjustmentsMappingList[i].orderItemTaxLineItem.OrderItemId = orderItemAdjustmentsMappingList[i]
              .orderItemId;
          }

          try {
            insert taxAdjsmtList;
          } catch (Exception ex) {
            system.debug('Exception: ' + ex);
            exceptionList.add(ex.getMessage());
          }
        }
      }
    }
  }

  public static void updateOrder(ID orderID) {
    List<Order> orderList = [
      SELECT id, status
      FROM Order
      WHERE ID = :orderID
      LIMIT 1
    ];

    if (orderList.size() > 0) {
      orderList[0].status = 'Activated';
      orderList[0].isSubscriptionOrder__c = isSubscriptionOrder;

      try {
        update orderList;
      } catch (Exception ex) {
        system.debug('Exception :' + ex);
        exceptionList.add(ex.getMessage());
      }
    }
  }

  public static Id createDeliveryGroup(ID orderId, Id deliveryMthdId, addressWrapper shippingAddress) {
    OrderDeliveryGroup deliveryGroupObj = new OrderDeliveryGroup();
    deliveryGroupObj.EmailAddress = shippingAddress.emailAddress;
    deliveryGroupObj.DeliverToCity = shippingAddress.city;
    deliveryGroupObj.DeliverToCountry = shippingAddress.country;
    deliveryGroupObj.DeliverToName = shippingAddress.firstName + ' ' + shippingAddress.lastName;
    deliveryGroupObj.DeliverToPostalCode = shippingAddress.postalCode;
    deliveryGroupObj.DeliverToState = shippingAddress.state;
    deliveryGroupObj.DeliverToStreet = createStreet(shippingAddress);

    deliveryGroupObj.PhoneNumber = shippingAddress.phoneNumber;
    deliveryGroupObj.OrderDeliveryMethodId = deliveryMthdId;
    deliveryGroupObj.OrderId = orderId;

    try {
      insert deliveryGroupObj;
    } catch (Exception ex) {
      system.debug('Exception: ' + ex);
      exceptionList.add(ex.getMessage());
    }

    return deliveryGroupObj.Id;
  }

  public static void createPayments(ID accID, ID orderID, string orderCurrency, paymentWrapper[] payment) {
    CardPaymentMethod cardPayObj = new CardPaymentMethod();
    cardPayObj.ProcessingMode = 'External';
    cardPayObj.PaymentMethodDetails = payment[0].method;
    cardPayObj.CardType = payment[0].cardType;
    cardPayObj.CardHolderName = payment[0].cardHolder;
    if (payment[0].expiryMonth != null && payment[0].expiryYear != null) {
      cardPayObj.ExpiryMonth = Integer.valueOf(payment[0].expiryMonth);
      cardPayObj.ExpiryYear = Integer.valueOf(payment[0].expiryYear);
    }
    cardPayObj.CardCategory = payment[0].cardCategory;
    cardPayObj.Status = 'Active';
    cardPayObj.AccountId = accID;

    try {
      insert cardPayObj;
    } catch (Exception ex) {
      system.debug('Eception: ' + ex);
      exceptionList.add(ex.getMessage());
    }

    ID payGroupID;
    PaymentGroup payGroupObj = new PaymentGroup();
    payGroupObj.SourceObjectId = orderID;
    payGroupObj.CurrencyIsoCode = orderCurrency;

    try {
      insert payGroupObj;
      payGroupID = payGroupObj.Id;
    } catch (Exception ex) {
      system.debug('Exception: ' + ex);
      exceptionList.add(ex.getMessage());
    }

    ID payAuthID;
    PaymentAuthorization payAuthObj = new PaymentAuthorization();
    payAuthObj.AccountId = accID;
    payAuthObj.Amount = Decimal.valueOf(payment[0].amount);
    payAuthObj.Status = payment[0].status;
    payAuthObj.CurrencyIsoCode = orderCurrency;
    payAuthObj.ProcessingMode = 'External';
    payAuthObj.PaymentGroupId = payGroupObj.Id;
    payAuthObj.PaymentMethodId = cardPayObj.id;

    try {
      insert payAuthObj;
      payAuthID = payAuthObj.Id;
    } catch (Exception ex) {
      system.debug('Exception occurs: ' + ex);
      exceptionList.add(ex.getMessage());
    }

    List<PaymentGateway> gateWayList = [
      SELECT id
      FROM PaymentGateway
      WHERE PaymentGatewayName LIKE 'TestPaymentGateway'
    ];

    // when a test is running and there is no gateway, we skip this part
    // This is because there is no way to create a payment gateway provider object in a test.
    if (!(gateWayList.size() == 0 && Test.isRunningTest())) {
      PaymentGatewayLog gatewayLogObj = new PaymentGatewayLog();
      gatewayLogObj.CurrencyIsoCode = orderCurrency;
      gatewayLogObj.InteractionStatus = payment[0].interactionStatus;
      gatewayLogObj.InteractionType = payment[0].interactionType;
      gatewayLogObj.PaymentGatewayId = gateWayList[0].id;
      gatewayLogObj.ReferencedEntityId = payAuthID;

      try {
        insert gatewayLogObj;
      } catch (Exception ex) {
        system.debug('Eception: ' + ex);
        exceptionList.add(ex.getMessage());
      }
    }

    Payment payObj = new Payment();
    payObj.AccountId = accID;
    payObj.Amount = Decimal.valueOf(payment[0].amount);
    payObj.Status = payment[0].status;
    payObj.Type = 'Capture';
    payObj.CurrencyIsoCode = orderCurrency;
    payObj.ProcessingMode = 'External';
    payObj.PaymentAuthorizationId = payAuthObj.Id;

    try {
      insert payObj;
    } catch (Exception ex) {
      system.debug('Exception occurs: ' + ex);
      exceptionList.add(ex.getMessage());
    }
  }

  private static string createStreet(addressWrapper a) {
    String address;
    if (!String.isEmpty(a.street) && a.street != 'null')
      address = a.street;
    if (!String.isEmpty(a.houseNumber) && a.houseNumber != 'null')
      address += ' ' + a.houseNumber;
    if (!String.isEmpty(a.street2) && a.street2 != 'null')
      address += ', ' + a.street2;
    if (!String.isEmpty(a.street3) && a.street3 != 'null')
      address += ', ' + a.street3;
    return address;
  }

  global class accountWrapper {
    global String isGuestCheckout;
    global String externalID;
    global String firstName;
    global String lastName;
    global String emailAddress;
    global String phoneNumber;
  }

  global class salesChannelWrapper {
    global String salesChannelID;
    global String countryCode;
    global String salesChannel;
    global String storeName;
  }

  global class addressWrapper {
    global String firstName;
    global String lastName;
    global String city;
    global String country;
    global String countryCode;
    global String emailAddress;
    global String state;
    global String houseNumber;
    global String houseName;
    global String administrativeArea;
    global String street;
    global String street2;
    global String street3;
    global String postalCode;
    global String phoneNumber;
  }

  global class orderItemAdjustmentWrapper {
    public String amount;
    public orderItemTaxWrapper orderItemAdjustmentTax;
  }

  global class orderItemTaxWrapper {
    public String amount;
    public String rate;
  }

  global class orderItemWrapper {
    public String itemID;
    public String grossUnitPrice;
    public String sku;
    public String productName;
    public String quantity;
    public String totalLineAmount;
    public String type;
    public String unitPrice;
    public orderItemTaxWrapper orderItemTax;
    public orderItemAdjustmentWrapper[] orderItemAdjustments;
  }

  global class paymentWrapper {
    public String referenceId;
    public String method;
    public String cardType;
    public String cardHolder;
    public String expiryMonth;
    public String expiryYear;
    public String cardCategory;
    public String amount;
    public String status;
    public String interactionStatus;
    public String interactionType;
  }

  private class orderItemMapper {
    public OrderItem orderItem;
    public OrderItemTaxLineItem orderItemTaxLineItem;
    public orderItemAdjustmentWrapper[] orderItemAdjustments;
  }

  private class orderItemAdjustmentMapper {
    public OrderItemAdjustmentLineItem orderItemAdjustment;
    public OrderItemTaxLineItem orderItemTaxLineItem;
    public ID orderItemId;
  }

  @future(callout=true)
  private static void SendFailedReservationMessage(
    String transactionID,
    String originalOrderID,
    String orderReferenceNumber,
    String salesChannel
  ) {
    API_Endpoint__c endpoint = [
      SELECT Base_URL__c
      FROM API_Endpoint__c
      WHERE Name = 'Reservation Failed API Endpoint' AND isDeleted = FALSE
      LIMIT 1
    ];

    FailedCreateReservationWrapper wrapper = new FailedCreateReservationWrapper();
    wrapper.transactionID = transactionID;
    wrapper.originalOrderID = originalOrderID;
    wrapper.orderReferenceNumber = orderReferenceNumber;
    wrapper.salesChannel = salesChannel;
    wrapper.ErrorMessage = 'Stock Unavailable. Order aborted';

    String JSONBody = JSON.serialize(wrapper);
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint.Base_URL__c + salesChannel + '/' + originalOrderID);
    req.setMethod('POST');
    req.setBody(JSONBody);

    Http http = new Http();
    http.send(req);
  }

  private class FailedCreateReservationWrapper {
    public String transactionID;
    public String originalOrderID;
    public String orderReferenceNumber;
    public String salesChannel;
    public String ErrorMessage;
  }
}
