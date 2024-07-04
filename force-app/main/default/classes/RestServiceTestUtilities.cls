@IsTest(SeeAllData=true)
public class RestServiceTestUtilities {
  public static final String TEST_ACC_NAME = 'test-acc';
  public static final String TEST_FIRSTNAME = 'TEST-FN';
  public static final String TEST_LASTNAME = 'TEST-LN';
  public static final String TEST_ZIPCODE = '10785';
  public static final String TEST_COUNTRY = 'Germany';
  public static final String TEST_EMAIL = 'testoms@cloud.com';
  public static final String TEST_CITY = 'Berlin';

  public static final String TEST_PHONE = '123456789098';
  public static final String TEST_SALES_CHANNEL = 'SALESCHANNEL';
  public static final String TEST_STREET = '88 Rosenthaler Strasse';
  public static final String TEST_LOCATION = 'TestLocation';

  /**************************************************ヾ(⌐■_■)ノ♪**************************************************
   * @name			setupTestData
   * @description		Creates a test Order along with fulfillment
   * @return			`Map<String, Object>` Containing all the sobjects/records created.
   * @see             Use `.KeySet();` to list the keys.
   ***************************************************¯\_(ツ)_/¯**************************************************/
  public static Map<String, Object> setupTestData() {
    return setupTestData('PREPAYMENT');
  }

  /**************************************************ヾ(⌐■_■)ノ♪**************************************************
   * @name			setupTestData
   * @description		Creates a test Order along with fulfillment
   * @param           String paymentType : 'PREPAYMENT', Giftcard, etc
   * @return			`Map<String, Object>` Containing all the sobjects/records created.
   * @see             Use `.KeySet();` to list the keys.
   ***************************************************¯\_(ツ)_/¯**************************************************/
  public static Map<String, Object> setupTestData(String paymentType) {
    Account acc = createAccount(TEST_ACC_NAME);

    Map<String, Object> outputMap = new Map<String, Object>();
    outputMap.put('account', acc);
    outputMap.put('location', createLocation());

    Map<String, Object> orderOutputMap = createOrder(acc, paymentType);
    outputMap.putAll(orderOutputMap);
    Order testOrder = (Order) outputMap.get('order');

    // create order summary
    Map<String, Object> orderSummaryOutputMap = createOrderSummary(testOrder);
    outputMap.putAll(orderSummaryOutputMap);

    return outputMap;
  }

  public static Map<String, Object> createOrder(
    Account acc,
    String paymentType
  ) {
    return createOrder(acc, paymentType, null);
  }

  public static Map<String, Object> createOrder(
    Account acc,
    String paymentType,
    String bonus
  ) {
    Map<String, Object> outputMap = new Map<String, Object>();

    Decimal randomPrice = createRandPrice();
    Decimal tax = (randomPrice - (randomPrice / 1.2))
      .setScale(2, System.RoundingMode.HALF_EVEN);
    DateTime dateEntered = system.now();
    String orderRef = 'SE' + generateRandomId();

    Order o = new Order();
    Id pricebookId = Test.getStandardPricebookId();
    o.Pricebook2Id = pricebookId;

    SalesChannel sc = new SalesChannel();
    sc.SalesChannelName = TEST_SALES_CHANNEL;

    insert sc;

    outputMap.put('saleschannel', sc);

    o.SalesChannelId = sc.Id;
    o.Name = orderRef;
    o.Status = 'Draft';
    o.OrderReferenceNumber = orderRef;
    o.EffectiveDate = date.valueOf(dateEntered);
    o.BillingStreet = TEST_STREET;
    o.BillingCity = TEST_CITY;
    o.BillingPostalCode = TEST_ZIPCODE;
    o.BillingPhoneNumber = '';
    o.BillingEmailAddress = generateRandomId() + TEST_EMAIL;
    o.OrderedDate = datetime.valueOf(dateEntered);
    o.TaxLocaleType = 'Gross';
    o.AccountId = acc.Id;

    insert o;

    String paymentGateWayName = paymentType;
    if (paymentType == 'PREPAYMENT') {
      paymentGateWayName = 'prepay';
    }

    // Create OrderDeliveryGroup
    OrderDeliveryGroup odg = new OrderDeliveryGroup();
    odg.EmailAddress = generateRandomId() + TEST_EMAIL;
    odg.DeliverToCity = TEST_CITY;
    odg.DeliverToName = TEST_FIRSTNAME + TEST_LASTNAME;
    odg.DeliverToPostalCode = TEST_ZIPCODE;
    odg.DeliverToStreet = TEST_STREET;
    odg.PhoneNumber = TEST_PHONE;
    odg.OrderId = o.Id;

    OrderDeliveryMethod odm = createOrderDeliveryMethod();

    List<OrderDeliveryMethod> DeliveryList = [
      SELECT Id
      FROM OrderDeliveryMethod
      WHERE ReferenceNumber = 'standardDHL_DE'
    ];

    OrderDeliveryMethod delivery = DeliveryList[0];

    outputMap.put('orderdeliverymethod', delivery);

    odg.OrderDeliveryMethodId = delivery.Id;
    insert odg;

    outputMap.put('orderdeliverygroup', odg);

    Product2 prod = createProduct2(1)[0];

    outputMap.put('product', prod);

    // ** assuming that product2.trigger should have created price entreries for each new product2 insert.
    PricebookEntry pbe = [
      SELECT Id
      FROM PricebookEntry
      WHERE Product2Id = :prod.Id
    ][0];

    // create location group
    LocationGroup testLocGroup = new LocationGroup();
    testLocGroup.LocationGroupName = 'Test Location Group 99';
    testLocGroup.ExternalReference = 'test-location-group-99';
    insert testLocGroup;

    outputMap.put('locationgroup', testLocGroup);

    // Create OrderItem
    OrderItem oi = new OrderItem();
    oi.Description = 'Test Order Item Description';
    oi.Type = 'Order Product';
    oi.Quantity = 1.0;
    oi.TotalLineAmount = randomPrice;
    oi.LineNumber = 1;
    oi.UnitPrice = randomPrice;
    oi.GrossUnitPrice = randomPrice;
    oi.OrderId = o.Id;
    oi.OrderDeliveryGroupId = odg.Id;
    oi.PricebookEntryId = pbe.Id;
    oi.Product2Id = prod.Id;
    oi.SKU__c = prod.StockKeepingUnit;
    oi.ReservedAtLocationId = testLocGroup.Id;

    System.debug('OrderItem Created');
    insert oi;

    // Create OrderItemTaxLineItem
    OrderItemTaxLineItem oli = new OrderItemTaxLineItem();
    oli.Name = 'Test OI - Tax';
    oli.Type = 'Estimated';
    oli.Amount = tax;
    oli.Rate = .21;
    oli.TaxEffectiveDate = date.valueOf(dateEntered);
    oli.OrderItemId = oi.Id;

    System.debug('OrderItemTaxLineItem Created');
    insert oli;
    // Create OrderItem for Shipping
    OrderItem oiShipping = new OrderItem();
    oiShipping.Description = 'Shipping';
    oiShipping.Type = 'Delivery Charge';
    oiShipping.Quantity = 1;
    oiShipping.TotalLineAmount = 0.0;
    oiShipping.LineNumber = 2;
    oiShipping.UnitPrice = 0.0;
    oiShipping.GrossUnitPrice = 0.0;
    oiShipping.OrderId = o.Id;
    oiShipping.OrderDeliveryGroupId = odg.Id;
    oiShipping.PricebookEntryId = pbe.Id;
    oiShipping.Product2Id = prod.Id;
    oiShipping.SKU__c = prod.StockKeepingUnit;

    insert oiShipping;

    outputMap.put('orderitem', oi);
    outputMap.put('orderitemshipping', oiShipping);

    // Create OrderItemTaxLineItem for Delivery charges
    OrderItemTaxLineItem oliShipping = new OrderItemTaxLineItem();
    oliShipping.Name = 'DeliveryCharge - Tax';
    oliShipping.Type = 'Estimated';
    oliShipping.Amount = 0.0;
    // oliShipping.Rate = xxx; //
    oliShipping.TaxEffectiveDate = date.valueOf(dateEntered);
    oliShipping.OrderItemId = oiShipping.Id;

    System.debug('OrderItemTaxLineItem for Shipping Created');
    insert oliShipping;

    if (bonus != null) {
      OrderAdjustmentGroup oag = new OrderAdjustmentGroup();
      oag.Name = 'CRMBonusDiscount';
      oag.Description = 'CRMBonusDiscount';
      oag.Type = 'Header';
      oag.OrderId = o.Id;
      insert oag;
      System.debug('inserted  OrderAdjustmentGroup ' + oag);

      OrderItemAdjustmentLineItem oiali = new OrderItemAdjustmentLineItem();
      oiali.Name = bonus;
      oiali.Description = bonus;
      oiali.Amount = -5;
      oiali.OrderItemId = oi.Id;
      oiali.OrderAdjustmentGroupId = oag.Id;
      insert oiali;
      System.debug('inserted  OrderItemAdjustmentLineItem ' + oiali);
    }

    // update order status
    o.Status = 'Activated';
    update o;

    outputMap.put('order', o);

    return outputMap;
  }

  public static Map<String, Object> createOrderSummary(Order ord) {
    ConnectAPI.OrderSummaryInputRepresentation orderSummaryInput = new ConnectAPI.OrderSummaryInputRepresentation();
    orderSummaryInput.orderId = ord.Id;
    ConnectAPI.OrderSummaryCreation.createOrderSummary(orderSummaryInput);

    Map<String, Object> outputMap = new Map<String, Object>();
    List<OrderSummary> ordSummary = [
      SELECT Id, AccountId, GrandTotalAmount, CreatedDate, BillingCountry
      FROM OrderSummary
      WHERE OriginalOrderId = :ord.Id
      LIMIT 1
    ];

    outputMap.put('orderSummary', ordSummary[0]);
    return outputMap;
  }

  /**************************************************ヾ(⌐■_■)ノ♪**************************************************
   * @name			createSFDCPricebook
   * @date			16-11-2020 (dd-mm-yy)
   * @param			String name: PRICE BOOK Name
   * @return			Pricebook2
   ***************************************************¯\_(ツ)_/¯**************************************************/
  public static Pricebook2 createSFDCPricebook(String name) {
    Pricebook2 pb2 = new Pricebook2(
      Name = name,
      isActive = true,
      Description = 'TEST PRICEBOOK'
    );
    insert pb2;
    return pb2;
  }

  public static List<Product2> createProduct2(Integer count) {
    Product2[] products = new List<Product2>();
    PricebookEntry[] priceEntries = new List<PricebookEntry>();
    Integer i = count - 1;
    for (; i >= 0; i--) {
      String TEST_PRODUCT_NAME =
        'TEST' +
        EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(0, 10);
      products.add(
        new Product2(
          Description = TEST_PRODUCT_NAME,
          Name = TEST_PRODUCT_NAME,
          StockKeepingUnit = TEST_PRODUCT_NAME + 'SKU',
          ProductCode = TEST_PRODUCT_NAME,
          IsActive = true
        )
      );
    }
    insert products;
    for (Product2 product : products) {
      priceEntries.add(
        new PricebookEntry(
          Pricebook2Id = Test.getStandardPricebookId(),
          Product2Id = product.Id,
          UnitPrice = 1
        )
      );
    }
    insert priceEntries;
    return products;
  }

  public static String generateRandomId() {
    Integer length = 10;
    Blob blobKey = crypto.generateAesKey(128);
    String key = EncodingUtil.convertToHex(blobKey);
    return key.substring(0, length);
  }

  public static Decimal createRandPrice() {
    return Decimal.valueOf(
        Integer.valueof(Math.random() * 1000) +
          '.' +
          Integer.valueof(Math.random() * 99)
      )
      .setScale(2, System.RoundingMode.HALF_EVEN);
  }

  /**************************************************ヾ(⌐■_■)ノ♪**************************************************
   * @name			createAccount
   * @param           String name: Account name
   * @return			Account : Account
   ***************************************************¯\_(ツ)_/¯**************************************************/
  public static Account createAccount(String name) {
    String randomId = generateRandomId();
    // List<RecordType> accountRecordTypes = [SELECT Id, name FROM RecordType WHERE SobjectType = 'Account' AND IsActive = TRUE];
    Account acc = new Account(
      FirstName = name + randomId,
      LastName = name + randomId,
      Phone = randomId,
      BillingCity = TEST_CITY,
      BillingStreet = TEST_STREET,
      BillingCountry = TEST_COUNTRY,
      BillingPostalCode = TEST_ZIPCODE,
      Salutation = 'Mr.',
      PersonBirthdate = Date.today().addYears(-24),
      External_Id__c = 'LORFR',
      recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('PersonAccount')
        .getRecordTypeId()
    );

    insert acc;
    // acc = [select id from account where name like '%surpal%' limit 1][0];
    return acc;
  }

  public static OrderDeliveryMethod createOrderDeliveryMethod() {
    String refNum = 'standardDHL_DE';
    OrderDeliveryMethod odm = new OrderDeliveryMethod(
      ReferenceNumber = refNum,
      Name = refNum,
      IsActive = true
    );
    insert odm;
    return odm;
  }

  public static Schema.Location createLocation() {
    Schema.Location location = new Schema.Location(
      ExternalReference = TEST_LOCATION,
      Name = 'Test'
    );
    insert location;
    return location;
  }

  public static FulfillmentOrder setupFulfillmentOrderData(
    String orderSummaryRecordId,
    Id accId
  ) {
    FulfillmentOrder fulfillmentOrder = new FulfillmentOrder(
      FulfilledToName = 'test',
      DeliveryMethodId = [SELECT ID FROM OrderDeliveryMethod LIMIT 1]
      .Id,
      OrderSummaryId = orderSummaryRecordId,
      status = 'Draft',
      AccountId = accId,
      Fulfillment_Order_Id__c = 'TESTFO1234'
    );
    fulfillmentOrder.FulfilledFromLocationId = [
      SELECT Id
      FROM Location
      WHERE ExternalReference = :TEST_LOCATION
      LIMIT 1
    ]
    .Id;

    insert fulfillmentOrder;

    List<OrderItemSummary> orderItemSummaryList = [
      SELECT ID, OriginalOrderItemId
      FROM OrderItemSummary
      WHERE
        OrderSummaryId = :orderSummaryRecordId
        AND (Type = 'Order Product'
        OR Type = 'Delivery Charge')
      ORDER BY Type
    ];
    List<FulfillmentOrderLineItem> orderLineItemList = new List<FulfillmentOrderLineItem>();
    FulfillmentOrderLineItem fulfillmentOrderItem = new FulfillmentOrderLineItem(
      Type = 'Order Product',
      TypeCode = 'Product',
      Quantity = 1.0,
      OriginalQuantity = 1.0,
      UnitPrice = 100.00,
      FulfillmentOrderId = fulfillmentOrder.Id,
      OrderItemSummaryId = orderItemSummaryList[1].Id,
      OrderItemId = orderItemSummaryList[1].OriginalOrderItemId
    );
    orderLineItemList.add(fulfillmentOrderItem);

    FulfillmentOrderLineItem fulfillmentShippingItem = new FulfillmentOrderLineItem(
      Type = 'Delivery Charge',
      TypeCode = 'Charge',
      Quantity = 1.0,
      OriginalQuantity = 1.0,
      UnitPrice = 100.00,
      FulfillmentOrderId = fulfillmentOrder.Id,
      OrderItemSummaryId = orderItemSummaryList[0].Id,
      OrderItemId = orderItemSummaryList[0].OriginalOrderItemId
    );
    orderLineItemList.add(fulfillmentShippingItem);
    insert orderLineItemList;
    return fulfillmentOrder;
  }
}
