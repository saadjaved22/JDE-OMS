/**
* All Account related SOQL queries.
*
* @author piotr.tugeman@emark.com
*/
public class AccountSelector {

	public static Account getAccount( String email, String country, String brand ){
		String externalID = email + country + brand;
		return AccountSelector.getAccountByExternalId( externalId );
	}

	// External_Id__c is unique
	public static Account getAccountByExternalId( String externalID ){

		List<Account> accounts = [SELECT Id, PersonContactId,
		RecordTypeID, External_Id__c, Consent_Status__c,
		Type__c, Brand__c, Country__c, PersonEmail, Gender__pc, FirstName, LastName, Language__c,
		Consent_Registration_Source_URL__c, Consent_Registration_Date__c,
		Consent_Text__c, Consent_Text_Version__c, Privacy_Policy_Version__c, 
		Consent_Registration_IP_Address__c,
		Opt_in_URL__c, Opt_out_URL__c, Consent_Confirmation_URL__c, Sixteen_Years_or_Older__c,
		Active_Subscription__c, IsCustomerPortal, 
		ShippingStreet, ShippingState, ShippingCity, ShippingPostalCode, ShippingCountry
		FROM Account 
		WHERE External_Id__c=:externalID];
		if ( !accounts.isEmpty() && 1 == accounts.size() ){
			return accounts[0];
		}
		else {
			return null;
		}
	}

	public static Account getAccountByContactId( String personContactID ){

		List<Account> accounts = [SELECT Id, PersonContactId,
		RecordTypeID, External_Id__c, Consent_Status__c,
		Type__c, Brand__c, Country__c, PersonEmail, Gender__pc, FirstName, LastName, Language__c,
		Consent_Registration_Source_URL__c, Consent_Registration_Date__c,
		Consent_Text__c, Consent_Text_Version__c, Privacy_Policy_Version__c, 
		Consent_Registration_IP_Address__c,
		Opt_in_URL__c, Opt_out_URL__c, Consent_Confirmation_URL__c, Sixteen_Years_or_Older__c,
		Active_Subscription__c,
		ShippingStreet, ShippingState, ShippingCity, ShippingPostalCode, ShippingCountry
		FROM Account 
		WHERE PersonContactId=:personContactID];
		if ( !accounts.isEmpty() && 1 == accounts.size() ){
			return accounts[0];
		}
		else {
			return null;
		}
	}

	// @return only External_Id__c of Account
	public static Account getAccountExternalId( String accountID ){

		List<Account> accounts = [SELECT Id, External_Id__c, PersonContactId 
		FROM Account 
		WHERE Id=:accountID];
		if ( !accounts.isEmpty() && 1 == accounts.size() ){
			return accounts[0];
		}
		else {
			return null;
		}
	}

	// Returns all account relevant information - for testing purposes
	public static List<Account> getAllAccountsBusinessRelevantFields(){
		List<Account> allAccounts = [SELECT Id, PersonContactId,
		RecordTypeID, External_Id__c, Consent_Status__c,
		Type__c, Brand__c, Country__c, PersonEmail, Gender__pc, FirstName, LastName, Language__c,
		Consent_Registration_Source_URL__c, Consent_Registration_Date__c,
		Consent_Text__c, Consent_Text_Version__c, Privacy_Policy_Version__c, 
		Consent_Registration_IP_Address__c,
		Opt_in_URL__c, Opt_out_URL__c, Consent_Confirmation_URL__c, Sixteen_Years_or_Older__c,
		Active_Subscription__c,
		ShippingStreet, ShippingState, ShippingCity, ShippingPostalCode, ShippingCountry
		FROM Account];

		return allAccounts;
	}


	// Returns contact Id by external_id
	public static Account getContactByExternalId(String externalId) {
		List<Account> account = [SELECT PersonContactId FROM Account WHERE External_Id__c = :externalId];

		if ( !account.isEmpty() && 1 == account.size() ){
			return account[0];
		}
		else {
			return null;
		}
	}
}