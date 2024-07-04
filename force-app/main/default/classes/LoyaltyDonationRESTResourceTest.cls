@isTest
private class LoyaltyDonationRESTResourceTest {
  @isTest
  static void test_createTransaction() {
    // setup:
    //non existing account @see beforeEachTest():
    mockPOSTRequest(
      '{"loyaltyTransaction":{"loyaltyId":"test@emailNLDE","loyaltyConsumer":"0010D00000JowNoQAJ","transactionAmount":"100","transactionType":"Redeem","loyaltySource":"Episerver","hasCharity":true}}'
    );
    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    Account accRec = new Account();
    accRec.RecordTypeId = recordTypeId;
    accRec.LastName = 'testing 123';
    insert accRec;

    Loyalty__c ltyRec = new Loyalty__c();
    ltyRec.Loyalty_Consumer__c = accRec.Id;
    ltyRec.External_Id__c = 'test@emailNLDE';
    insert ltyRec;

    Loyalty_Transaction__c ltyTransRec = new Loyalty_Transaction__c();
    ltyTransRec.Loyalty__c = ltyRec.Id;
    ltyTransRec.Loyalty_Consumer__c = accRec.Id;
    ltyTransRec.Loyalty_Transaction_Type__c = 'Compensation';
    ltyTransRec.Loyalty_Source__c = 'Blokker POS';
    ltyTransRec.Transaction_Amount__c = 1000;
    ltyTransRec.Contact__c = accRec.PersonContactId;
    insert ltyTransRec;

    Charity__c chaRec = new Charity__c();
    chaRec.Name = 'Testing123';
    chaRec.External_ID__c = 'Test123';
    insert chaRec;

    Donation__c donationRec = new Donation__c();
    donationRec.Charity__c = chaRec.Id;
    donationRec.Donated_Points__c = 100;
    donationRec.DonorContact__c = ltyTransRec.Contact__c;
    insert donationRec;

    // under test:
    LoyaltyDonationRESTResource.FullResponse response = LoyaltyDonationRESTResource.upsertTransaction();

    /*assertions:
		List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
		System.assertEquals(4, accountsAfter.size(), 'There should be 4 accounts (3 Existing + 1 New) response=' + response);
		System.assertEquals( true, response.success, 'Response should be successfull');
		System.assertEquals(response.message, AccountRESTResource.SUCCESS_ACCOUNT_CREATED, 'Response message should inform about account creation');*/
  }

  @isTest
  static void test_readAccountDataFrom_check_if_reads_all_dataTransaction() {
    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    Account accRec = new Account();
    accRec.RecordTypeId = recordTypeId;
    accRec.LastName = 'testing 123';
    insert accRec;

    Loyalty__c ltyRec = new Loyalty__c();
    ltyRec.Loyalty_Consumer__c = accRec.Id;
    ltyRec.External_Id__c = 'test@emailNLDE';
    insert ltyRec;

    Loyalty_Transaction__c ltyTransRec = new Loyalty_Transaction__c();
    ltyTransRec.Loyalty__c = ltyRec.Id;
    ltyTransRec.Loyalty_Consumer__c = accRec.Id;
    ltyTransRec.Loyalty_Transaction_Type__c = 'Compensation';
    ltyTransRec.Loyalty_Source__c = 'Blokker POS';
    ltyTransRec.Transaction_Amount__c = 1000;
    insert ltyTransRec;

    mockPOSTRequest(
      '{"loyaltyTransaction":{"loyaltyId":"test@emailNLDE","loyaltyConsumer":"0010D00000JowNoQAJ","transactionAmount":"100","transactionType":"Redeem","loyaltySource":"Episerver","hasCharity":true}}'
    );
    Loyalty_Transaction__c createdTransaction = LoyaltyDonationRESTResource.readTransactionDataFrom(
      RestContext.request
    );
    // assertions:
    //System.assertEquals('test@emailNLDE', createdTransaction.Loyalty__c);
    System.assertEquals(
      '0010D00000JowNoQAJ',
      createdTransaction.Loyalty_Consumer__c
    );
    System.assertEquals(100, createdTransaction.Transaction_Amount__c);
    System.assertEquals(
      'Redeem',
      createdTransaction.Loyalty_Transaction_Type__c
    );
    System.assertEquals('Episerver', createdTransaction.Loyalty_Source__c);
    System.assertEquals(true, createdTransaction.Has_Charity__c);
  }

  @isTest
  static void test_readAccountDataFrom_check_if_reads_all_dataDonation() {
    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    Account accRec = new Account();
    accRec.RecordTypeId = recordTypeId;
    accRec.LastName = 'testing 123';
    insert accRec;

    Loyalty__c ltyRec = new Loyalty__c();
    ltyRec.Loyalty_Consumer__c = accRec.Id;
    ltyRec.External_Id__c = 'test@emailNLDE';
    insert ltyRec;

    Loyalty_Transaction__c ltyTransRec = new Loyalty_Transaction__c();
    ltyTransRec.Loyalty__c = ltyRec.Id;
    ltyTransRec.Loyalty_Consumer__c = accRec.Id;
    ltyTransRec.Loyalty_Transaction_Type__c = 'Compensation';
    ltyTransRec.Loyalty_Source__c = 'Blokker POS';
    ltyTransRec.Transaction_Amount__c = 1000;
    ltyTransRec.Contact__c = accRec.PersonContactId;
    insert ltyTransRec;

    Charity__c chaRec = new Charity__c();
    chaRec.Name = 'Testing123';
    chaRec.External_ID__c = 'Test123';
    insert chaRec;

    Donation__c donationRec = new Donation__c();
    donationRec.Charity__c = chaRec.Id;
    donationRec.Donated_Points__c = 100;
    donationRec.DonorContact__c = ltyTransRec.Contact__c;
    insert donationRec;

    mockPOSTRequest(
      '{"loyaltyTransaction":{"loyaltyId":"test@emailNLDE","loyaltyConsumer":"0010D00000JowNoQAJ","transactionAmount":"-100","transactionType":"Redeem","loyaltySource":"Episerver","hasCharity":true,"donation":{"donatedPoints":"-100","donorId":"0010D00000JowNoQAJ","charityId":"Test123"}}}'
    );
    Donation__c createdDonation = LoyaltyDonationRESTResource.readDonationDataFrom(
      RestContext.request,
      ltyTransRec.Id
    );
    /* assertions:
		System.assertEquals('Test2', createdTransaction.Loyalty__c);
		System.assertEquals('0010D00000JowNoQAJ', createdTransaction.Loyalty_Consumer__c);
		System.assertEquals(100, createdTransaction.Transaction_Amount__c);
		System.assertEquals('Redeem', createdTransaction.Loyalty_Transaction_Type__c);
		System.assertEquals('Episerver', createdTransaction.Loyalty_Source__c);
        System.assertEquals(true, createdTransaction.Has_Charity__c);*/
  }

  private static void mockPOSTRequest(String jsonRequestBody) {
    RestRequest request = new RestRequest();
    request.httpMethod = 'POST';
    request.requestBody = Blob.valueOf(jsonRequestBody);
    RestContext.request = request;
  }
}
