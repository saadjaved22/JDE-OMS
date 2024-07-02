/**
* @author piotr.tugeman@emark.com

History
    @Fixed by Wunderman Thompson  09/2022
*/
@isTest
private class CampaignMemberTrigger_Test {
	
	@testSetup
	static void beforeEachTest(){
		TriggerSettings__c ts1 = new TriggerSettings__c();
        // ts1.PersonAccountTrigger__c = false;
        ts1.CampaignMemberTrigger__c = true;
        insert ts1;
		// 4 accounts:
		List<Account> testAccounts = new List<Account>();

		Account account1 = new AccountBuilder()
		.setLastName('TestName_1')
		.setEmail('test_1@a.a')
		.setCountry('NL')
		.setBrand('Jacobs')
		.setAccountType('Loyalty')
		.build();

		Account account2 = new AccountBuilder()
		.setLastName('TestName_2')
		.setEmail('test_2@a.a')
		.setCountry('NL')
		.setBrand('Jacobs')
		.setAccountType('Guest')
		.build();

		Account account3 = new AccountBuilder()
		.setLastName('TestName_3')
		.setEmail('test_3@a.a')
		.setCountry('NL')
		.setBrand('Jacobs')
		.setAccountType('Loyalty')
		.build();

		Account account4 = new AccountBuilder()
		.setLastName('TestName_4')
		.setEmail('test_4@a.a')
		.setCountry('NL')
		.setBrand('Jacobs')
		.setAccountType('Loyalty')
		.build();

		testAccounts.add( account1 );
		testAccounts.add( account2 );
		testAccounts.add( account3 );
		testAccounts.add( account4 );

		Test.startTest();
		insert testAccounts;

		// 3 Loyalties

		List<Loyalty__c> testLoyalties = new List<Loyalty__c>();

		Loyalty__c loyalty1 = new Loyalty__c();
		loyalty1.Loyalty_Consumer__c = account1.Id;
		loyalty1.External_Id__c = account1.External_Id__c;

		Loyalty__c loyalty2 = new Loyalty__c();
		loyalty2.Loyalty_Consumer__c = account2.Id;
		loyalty2.External_Id__c = account2.External_Id__c;

		Loyalty__c loyalty3 = new Loyalty__c();
		loyalty3.Loyalty_Consumer__c = account4.Id;
		loyalty3.External_Id__c = 'SomeValueDifferentThanAccountExternalId';

		testLoyalties.add( loyalty1 );
		testLoyalties.add( loyalty2 );
		testLoyalties.add( loyalty3 );

		insert testLoyalties;

		// 2 campaigns:
		List<Campaign> testCampaigns = new List<Campaign>();

		Campaign campaign1 = new Campaign();
		campaign1.Name = 'FirstCampaign';
		campaign1.Brand__c= 'Senseo';
		campaign1.Country__c= 'NL';
		campaign1.Add_Points__c = true;
		campaign1.Points_Amount__c = 10;

		Campaign campaign3 = new Campaign();
		campaign3.Name = 'ThirdCampaign';
		campaign3.Brand__c= 'Tassimo';
		campaign3.Country__c= 'NL';
		campaign3.Add_Points__c = false;

		testCampaigns.add( campaign1 );
		testCampaigns.add( campaign3 );

		insert testCampaigns;
		Test.stopTest();
	}

	@IsTest
	static void testCampaingMemberCustomerUpdate(){
		List<Account>  accList = [Select ID,ContactID__pc FROM Account LIMIT 1];
		Campaign  camp = [SELECT ID FROM Campaign LIMIT 1];

		Test.startTest();
			CampaignMember cmpM = new CampaignMember(ContactId = accList[0].ContactID__pc , CampaignId = camp.Id, Status = 'Sent');
        	insert cmpM;
		Test.stopTest();

		CampaignMember cmpMM = [SELECT ID, Customer__c,Status FROM CampaignMember WHERE ID = :cmpM.ID];
		System.assert(cmpMM.Customer__c == accList[0].Id);

		cmpMM.Status = 'Responded';
		update cmpMM;

		CampaignMember cmpMMM = [SELECT ID, Customer__c,ContactId FROM CampaignMember WHERE ID = :cmpMM.ID];
		System.assert(cmpMM.Customer__c == accList[0].Id);


	}

	/* @isTest 
	static void test_onAfterInsert_create_loyalty_transaction() {
		// setup
		Account account1 = AccountSelector.getAccountByExternalId('test_1@a.aNLJacobs'); // account type Loyalty
		Campaign campaignWithTransferablePoints = CampaignSelector.getCampaignByExternalId('Senseo-NL-FirstCampaign');
		CampaignMember member = new CampaignMember();
		member.ContactId = account1.PersonContactId;
		member.CampaignId = campaignWithTransferablePoints.Id;
		
		// under test:
		insert member;

		// assertrions:
		List<Loyalty__c> loyalties = LoyaltySelector.getLoyalties( account1.Id );
		System.assert( null != loyalties, 'Account still should have loyalty' );
		System.assertEquals( 1, loyalties.size(), 'No changes in Loyalties on account - no new loyalties' );
		List<Loyalty_Transaction__c> transactions = LoyaltySelector.getLoyaltyTransactions( account1.Id, loyalties[0].Id );
        if(transactions.size()>0){
           System.assert( null != transactions, 'There should be transaction created' );
		//System.assertEquals( 1, transactions.size(), ' There should be exactly one transaction created' );
		Loyalty_Transaction__c trans = transactions[0];
		System.assert( null != trans.Name, ' Transaction Name should be autogenerated' );
		System.assert( null != trans.Loyalty__c, ' Transaction Layalty__c should exist' );
		System.assert( null != trans.Loyalty_Transaction_Type__c, ' Transaction Loyalty_Transaction_Type__c should exist - is required' );
		System.assertEquals( CampaignMemberTriggerHandler.LOYALTY_TRANSACTION_TYPE, trans.Loyalty_Transaction_Type__c, 'Transaction type should be set from static value');
		System.assert( null != trans.Loyalty_Source__c, ' Transaction Loyalty_Source__c should exist' );
		System.assertEquals( CampaignMemberTriggerHandler.LOYALTY_SOURCE, trans.Loyalty_Source__c, 'Transaction loyalty source should be set from static value');
		System.assert( null != trans.Loyalty_Notes_Reference__c, ' Transaction Loyalty_Notes_Reference__c should exist' );
		System.assertEquals( campaignWithTransferablePoints.External_Id__c, trans.Loyalty_Notes_Reference__c, 'Transaction Loyalty_Notes_Reference__c should be equal to Campaign External ID');
		Loyalty__c loyalty1 = LoyaltySelector.getLoyaltyByExternalId( account1.External_Id__c ); 
		System.assertEquals( loyalty1.Id, trans.Loyalty__c, 'Transaction should be created on existing account loyalty' );
		System.assertEquals( account1.Id, trans.Loyalty_Consumer__c, 'Transaction should be created for account from CampaignMember' );
		System.assertEquals( campaignWithTransferablePoints.Points_Amount__c, trans.Transaction_Amount__c, 'Transaction amount on Loyalty Transaction should equal points from campaign' );
		//System.assertEquals( campaignWithTransferablePoints.Points_Amount__c, trans.Total_Loyalty_Points__c, 'Transaction points should equal points from campaign' );
 
        }
		
		//TODO: ??add checks on total amount on Loyalty and Account (after clarification about points addition)
	} */

	/* @isTest 
	static void test_onAfterInsert_do_not_create_transaction_when_campaign_without_points() {
		// setup
		Account account1 = AccountSelector.getAccountByExternalId('test_1@a.aNLJacobs'); // account type Loyalty
		Campaign campaignWithoutPoints = CampaignSelector.getCampaignByExternalId('Tassimo-NL-ThirdCampaign');
		CampaignMember member = new CampaignMember();
		member.ContactId = account1.PersonContactId;
		member.CampaignId = campaignWithoutPoints.Id;
		
		// under test:
		insert member;

		// assertrions:
		List<Loyalty__c> loyalties = LoyaltySelector.getLoyalties( account1.Id );
		System.assert( null != loyalties, 'Account still should have loyalty' );
		System.assertEquals( 1, loyalties.size(), 'No changes in Loyalties on account - no new loyalties' );
		List<Loyalty_Transaction__c> transactions = LoyaltySelector.getLoyaltyTransactions( account1.Id, loyalties[0].Id );
		System.assert( null != transactions, 'There should be transaction list' );
		System.assertEquals( 0, transactions.size(), ' There should be no transactions for this loyalty' );
	} */

	/* @isTest 
	static void test_onAfterInsert_do_not_create_transaction_when_account_is_not_loyalty_type() {
		// setup
		Account account2 = AccountSelector.getAccountByExternalId('test_2@a.aNLJacobs'); //account type Guest
		Campaign campaignWithTransferablePoints = CampaignSelector.getCampaignByExternalId('Senseo-NL-FirstCampaign');
		CampaignMember member = new CampaignMember();
		member.ContactId = account2.PersonContactId;
		member.CampaignId = campaignWithTransferablePoints.Id;
		
		// under test:
		insert member;

		// assertrions:
		List<Loyalty__c> loyalties = LoyaltySelector.getLoyalties( account2.Id );
		System.assert( null != loyalties, 'Account still should have loyalty' );
		System.assertEquals( 1, loyalties.size(), 'No changes in Loyalties on account - no new loyalties' );
		List<Loyalty_Transaction__c> transactions = LoyaltySelector.getLoyaltyTransactions( account2.Id, loyalties[0].Id );
		System.assert( null != transactions, 'There should be transaction list' );
		System.assertEquals( 0, transactions.size(), ' There should be no transactions for this loyalty' );
	} */

	/* @isTest 
	static void test_onAfterInsert_do_not_create_transaction_nor_loyalty_when_account_do_not_have_loyalty() {
		// setup
		Account account3 = AccountSelector.getAccountByExternalId('test_3@a.aNLJacobs'); //account type Loyalty, but no Loyalty object
		Campaign campaignWithTransferablePoints = CampaignSelector.getCampaignByExternalId('Senseo-NL-FirstCampaign');
		CampaignMember member = new CampaignMember();
		member.ContactId = account3.PersonContactId;
		member.CampaignId = campaignWithTransferablePoints.Id;
		
		// under test:
		insert member;

		// assertrions:
		List<Loyalty__c> loyalties = LoyaltySelector.getLoyalties( account3.Id );
		System.assert( null != loyalties, 'There should be list od Loyalties returned' );
		System.assertEquals( 0, loyalties.size(), 'List size should be 0 - no new loyalties created. Loyalties:' + loyalties );
		List<Loyalty_Transaction__c> transactions = LoyaltySelector.getLoyaltyTransactions( account3.Id );
		System.assert( null != transactions, 'There should be transaction list' );
		System.assertEquals( 0, transactions.size(), ' There should be no transactions for this account' );
	} */


	/* @isTest 
	static void test_onAfterInsert_do_not_create_transaction_nor_loyalty_when_account_do_not_have_loyalty_with_proper_externalId() {
		
	 	// setup
		Account account4 = AccountSelector.getAccountByExternalId('test_4@a.aNLJacobs'); //account type Loyalty, with incorrect Loyalty.ExternalId
		Campaign campaignWithTransferablePoints = CampaignSelector.getCampaignByExternalId('Senseo-NL-FirstCampaign');
		CampaignMember member = new CampaignMember();
		member.ContactId = account4.PersonContactId;
		member.CampaignId = campaignWithTransferablePoints.Id;
		
		// under test:
		insert member;

		// assertrions:
		List<Loyalty__c> loyalties = LoyaltySelector.getLoyalties( account4.Id );
		System.assert( null != loyalties, 'There should be list od Loyalties returned' );
		System.assertEquals( 1, loyalties.size(), 'List size should be still 1 - no new loyalties created. Loyalties:' + loyalties );
		List<Loyalty_Transaction__c> transactions = LoyaltySelector.getLoyaltyTransactions( account4.Id );
		System.assert( null != transactions, 'There should be transaction list' );
		System.assertEquals( 0, transactions.size(), ' There should be no transactions for this account' );
	} */
	
}