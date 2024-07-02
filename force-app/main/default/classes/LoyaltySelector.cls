/**
* All Loyalty and LoyaltyTransaction related SOQL queries.

* @author piotr.tugeman@emark.com
*/
public with sharing class LoyaltySelector {


	public static List<Loyalty__c> getLoyalties( String accountId ){
		List<Loyalty__c> loyalties = [ SELECT Id,
		Name, External_Id__c, Loyalty_Account_Number__c, Loyalty_Card_Blocked_Date__c,
		Loyalty_Card_Created_Date__c, Loyalty_Card_Number__c, Loyalty_Card_Status__c,
		Loyalty_Consumer__c, Loyalty_Total_Points__c
		FROM Loyalty__c
		WHERE Loyalty_Consumer__c=:accountId];

		return loyalties;
	}

	//loyalty.External_Id__c is unique and equal to account.External_Id__c
	public static Loyalty__c getLoyaltyByExternalId( String accountExternalId ){
		List<Loyalty__c> loyalties = [ SELECT Id,
		Name, External_Id__c, Loyalty_Account_Number__c, Loyalty_Card_Blocked_Date__c,
		Loyalty_Card_Created_Date__c, Loyalty_Card_Number__c, Loyalty_Card_Status__c,
		Loyalty_Consumer__c, Loyalty_Total_Points__c
		FROM Loyalty__c
		WHERE External_Id__c=:accountExternalId];

		if ( !loyalties.isEmpty() && 1 == loyalties.size() ){
			return loyalties[0];
		}
		else {
			return null;
		}
	}

	//TODO: is there a need for this method?
	//public static List<Loyalty_Transaction__c> getLoyaltyTransactionsByExternalId( String accountExternalId ){
	//}

	
	public static List<Loyalty_Transaction__c> getLoyaltyTransactions( String accountId, String loyaltyId ){
		List<Loyalty_Transaction__c> transactions = [ SELECT Id,
		Name, Data_Migration_ID__c, CurrencyIsoCode, Loyalty__c, Loyalty_Consumer__c,
		Loyalty_Notes__c, Loyalty_Source__c, Loyalty_Notes_Reference__c, Transaction_Amount__c,
		 Loyalty_Transaction_Type__c, Total_Loyalty_Points__c
		FROM Loyalty_Transaction__c
		WHERE Loyalty__c=:loyaltyId
		AND Loyalty_Consumer__c =:accountId];

		return transactions;
	}

	public static List<Loyalty_Transaction__c> getLoyaltyTransactions( String accountId  ){
		List<Loyalty_Transaction__c> transactions = [ SELECT Id,
		Name, Data_Migration_ID__c, CurrencyIsoCode, Loyalty__c, Loyalty_Consumer__c,
		Loyalty_Notes__c, Loyalty_Source__c, Loyalty_Notes_Reference__c, Transaction_Amount__c,
		Loyalty_Transaction_Type__c, Total_Loyalty_Points__c
		FROM Loyalty_Transaction__c
		WHERE Loyalty_Consumer__c =:accountId];

		return transactions;
	}
}