@isTest
private class LoyaltyDonationBuilderTest{
      
    @isTest
	static void test_setLoyaltyId(){
		//underTest:
		
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        insert accRec;
        
		Loyalty__c ltyRec = new Loyalty__c();
        ltyRec.Loyalty_Consumer__c = accRec.Id;
        ltyRec.External_Id__c = 'imapaguio+002@gmail.comNLDouwe Egberts';
        insert ltyRec;
        
		Loyalty_Transaction__c ltyTransRec = new Loyalty_Transaction__c();
        ltyTransRec.Loyalty__c = ltyRec.Id;
        ltyTransRec.Loyalty_Consumer__c = accRec.Id;
        ltyTransRec.Loyalty_Transaction_Type__c = 'Compensation';
        ltyTransRec.Loyalty_Source__c = 'Blokker POS';
        ltyTransRec.Transaction_Amount__c = 1000;
        insert ltyTransRec;
        
		Loyalty_Transaction__c ltyDonation = new LoyaltyDonationBuilder()
		//.setLoyaltyId(ltyTransRec.Loyalty__c)
		.setLoyaltyId('imapaguio+002@gmail.comNLDouwe Egberts')
		.transactionbuild();
        
		//assertions:
		//System.assertEquals('imapaguio+002@gmail.comNLDouwe Egberts', ltyRec.Loyalty__c);
	}
    
    @isTest
	static void test_setLoyaltyConsumer(){
		//underTest:
		Loyalty_Transaction__c ltyRec = new LoyaltyDonationBuilder()
		.setLoyaltyConsumer('0010D00000JowNoQAJ')
		.transactionbuild();
        
		//assertions:
		System.assertEquals('0010D00000JowNoQAJ', ltyRec.Loyalty_Consumer__c);
	}
    
    @isTest
	static void test_setTransactionAmount(){
		//underTest:
		//Double x = 100;
		Loyalty_Transaction__c ltyRec = new LoyaltyDonationBuilder()
		.setTransactionAmount(100)
		.transactionbuild();
        
		//assertions:
		System.assertEquals(100, ltyRec.Transaction_Amount__c);
	}
    
    @isTest
	static void test_setTransactionType(){
		//underTest:
		Loyalty_Transaction__c ltyRec = new LoyaltyDonationBuilder()
		.setTransactionType('Redeem')
		.transactionbuild();
        
		//assertions:
		System.assertEquals('Redeem', ltyRec.Loyalty_Transaction_Type__c);
	}
    
    @isTest
	static void test_setLoyaltySource(){
		//underTest:
		Loyalty_Transaction__c ltyRec = new LoyaltyDonationBuilder()
		.setLoyaltySource('Episerver')
		.transactionbuild();
        
		//assertions:
		System.assertEquals('Episerver', ltyRec.Loyalty_Source__c);
	}
    
    @isTest
	static void test_setHasCharity(){
		//underTest:
		Loyalty_Transaction__c ltyRec = new LoyaltyDonationBuilder()
		.setHasCharity( true )
		.transactionbuild();
        
		//assertions:
		System.assertEquals(true, ltyRec.Has_Charity__c);
	}
    
    @isTest
	static void test_setDonatedPoints(){
		//underTest:
		Donation__c donRec = new LoyaltyDonationBuilder()
		.setDonatedPoints( 100 )
		.donationbuild();
        
		//assertions:
		System.assertEquals(100, donRec.Donated_Points__c);
	}
    
    @isTest
	static void test_setDonorId(){
		//underTest:
		Donation__c donRec = new LoyaltyDonationBuilder()
		.setDonorId('0010D00000JowNoQAJ')
		.donationbuild();
        
		//assertions:
		System.assertEquals('0010D00000JowNoQAJ', donRec.Donor__c);
	}
    
    /*@isTest
	static void test_setCharityId(){
		//underTest:
		String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Accou/*nt();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        insert accRec;
        
		Loyalty__c ltyRec = new Loyalty__c();
        ltyRec.Loyalty_Consumer__c = accRec.Id;
        ltyRec.External_Id__c = 'imapaguio+002@gmail.comNLDouwe Egberts';
        insert ltyRec;
        
		Loyalty_Transaction__c ltyTransRec = new Loyalty_Transaction__c();
        //Loyalty__c queryLoyalty = [SELECT Id FROM Loyalty__c WHERE External_ID__c = :loyaltyId LIMIT 1];
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
        donationRec.Loyalty_Transaction__c = ltyTransRec.Id;
        donationRec.DonorContact__c = ltyTransRec.Contact__c;
      	insert donationRec;
        
		Donation__c donRec = new LoyaltyDonationBuilder()
		.setCharityId('Test123')
		.donationbuild();
        
		//assertions:
		System.assertEquals('Test123', donRec.Charity__c);
	}*/

    @isTest
	static void test_setTransactionId(){
		//underTest:
		
		Donation__c donRec = new LoyaltyDonationBuilder()
		.setTransactionId('a0V0D000001PDS3UAO')
		.donationbuild();
        
		//assertions:
		System.assertEquals('a0V0D000001PDS3UAO', donRec.Loyalty_Transaction__c);
	}
    
    /*@isTest
	static void test_setContactId(){
		//underTest:
		String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        insert accRec;
        
		Loyalty__c ltyRec = new Loyalty__c();
        ltyRec.Loyalty_Consumer__c = accRec.Id;
        ltyRec.External_Id__c = 'imapaguio+002@gmail.comNLDouwe Egberts';
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
        donationRec.Loyalty_Transaction__c = ltyTransRec.Id;
        donationRec.DonorContact__c = ltyTransRec.Contact__c;
      	insert donationRec;
        
		Donation__c donRec = new LoyaltyDonationBuilder()
		.setContactId('0030D00000FBHsPQAX')
		.donationbuild();
        
		//assertions:
		//System.assertEquals('0030D00000FBHsPQAX', donRec.DonorContact__c);
	}*/
}