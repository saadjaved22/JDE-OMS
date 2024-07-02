/**
* @author piotr.tugeman@emark.com
*/
@isTest
private class AccountRESTResource_Test {
	
	@testSetup
	static void beforeEachTest(){

		List<Account> testAccounts = new List<Account>();

		Account account1 = new AccountBuilder()
		.setLastName('ExistingName')
		.setEmail('existing@email.com')
		.setCountry('NL')
		.setBrand('Jacobs')
		.build();

		Account account2 = new AccountBuilder()
		.setLastName('DifferentName')
		.setFirstName('First')
		.setEmail('existing@email.com')
		.setCountry('NL')
		.setBrand('Tassimo')
		.setGender('Female')
		.setLanguage( 'English' )
		.setAccountType('Loyalty')
		.setConsentRegistrationSourceUrl( 'https://reg.com' )
		.setConsentRegistrationDate( '2018-09-23T10:32:56.555Z')
		.setConsentText( 'My consent text...' )
		.setConsentStatus( 'Expired' )
		.setConsentTextVersion( 'v1.0' )
		.setPrivacyPolicyVersion( 'p1.0' )
		.setConsentRegistrationIPAddress( '192.168.0.0' )
		.setOptInUrl( 'https://opt.in.pl' )
		.setOptOutUrl(  'https://opt.out.pl' )
		.setConsentConfirmationUrl(  'https://conf.in.pl' )
		//.setConsentStatus()
		.setSixteenYearsOrOlder( true )
        .setBillingStreet( 'Old Street 123a' )
		.setBillingState( 'Old State' )
		.setBillingCity( 'Old City' )
		.setBillingPostalCode( '999-99A' )
		.setBillingCountry( 'Old Country' )
		.setShippingStreet( 'Old Street 123a' )
		.setShippingState( 'Old State' )
		.setShippingCity( 'Old City' )
		.setShippingPostalCode( '999-99A' )
		.setShippingCountry( 'Old Country' )
        .setSingleOptIn(true)
		.build();//Account with all fields filled except CommercialConsentStatus

		Account account3 = new AccountBuilder()
		.setLastName('OtherName')
		.setEmail('existing@email.com')
		.setCountry('UK')
		.setBrand('Jacobs')
		.build();
        

		testAccounts.add(account1);
		testAccounts.add(account2);
		testAccounts.add(account3);

		Test.startTest();
		insert testAccounts;
		Test.stopTest();
	}

	@isTest 
	static void test_findInDatabase_null_when_External_ID_does_not_exist() {
		// setup:
		Account newAccount1 = new AccountBuilder()
		.setLastName('OtherName')
		.setEmail('existing@email.com')
		.setCountry('UK') //differs only by country
		.setBrand('Tassimo') 
		.build();
		
		Account newAccount2 = new AccountBuilder()
		.setLastName('OtherName')
		.setEmail('new@email.com') //differs only by email
		.setCountry('UK')
		.setBrand('Jacobs') 
		.build();

		Account newAccount3 = new AccountBuilder()
		.setLastName('OtherName')
		.setEmail('existing@email.com')
		.setCountry('UK')
		.setBrand('Milka') //differs only by brand
		.build();

		// under test:
		Account existingAccount1 = AccountRESTResource.findInDatabase(newAccount1);
		Account existingAccount2 = AccountRESTResource.findInDatabase(newAccount2);
		Account existingAccount3 = AccountRESTResource.findInDatabase(newAccount3);

		// assertions:
		System.assertEquals(null, existingAccount1, 'newAccount1 should NOT be found in database');
		System.assertEquals(null, existingAccount2, 'newAccount2 should NOT be found in database');
		System.assertEquals(null, existingAccount3, 'newAccount3 should NOT be found in database');
	}
	
	@isTest 
	static void test_findInDatabase_when_External_ID_exists() {
		// setup:
		Account newAccount = new AccountBuilder() 
		.setLastName('OtherName')
		.setEmail('existing@email.com')
		.setCountry('NL')
		.setBrand('Jacobs') 
		.build();//this account already exists

		// under test:
		Account existingAccount = AccountRESTResource.findInDatabase(newAccount);

		// assertions:
		System.assertNotEquals(null, existingAccount, 'newAccount should be found in database');
	}

	@isTest 
	static void test_readAccountDataFrom_check_if_reads_all_data() {
		// setup: 
		//non existing account @see beforeEachTest():
		mockPOSTRequest('{"account":{"lastName":"Test2","email":"new@email.com","country":"NL","brand":"Jacobs"}}');

		// under test:
		Account createdAccount = AccountRESTResource.readAccountDataFrom( RestContext.request );

		// assertions:
		System.assertEquals('Test2', createdAccount.LastName, 'LastName should be taken from request body');
		System.assertEquals('new@email.com', createdAccount.PersonEmail, 'PersonEmail should be taken from request body');
		System.assertEquals('NL', createdAccount.Country__c, 'Country__c should be taken from request body');
		System.assertEquals('Jacobs', createdAccount.Brand__c, 'Brand__c should be taken from request body');
		System.assertEquals('new@email.comNLJacobs', createdAccount.External_Id__c, 'External_Id__c should be set as email+country+brand (without delimiters)');
		Id personRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
		System.assertEquals(personRecordType, createdAccount.RecordTypeID, 'Account should be created as PersonAccount');

	}

	@isTest 
	static void test_createAccount_inserts_new_account_min() {
		// setup: 
		//non existing account @see beforeEachTest():
		mockPOSTRequest('{"account":{"lastName":"Test2","email":"new@email.com","country":"NL","brand":"Jacobs"}}');

		// under test:
		AccountRESTResource.FullResponse response = AccountRESTResource.upsertAccount();

		// assertions:
		List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
		System.assertEquals(4, accountsAfter.size(), 'There should be 4 accounts (3 Existing + 1 New) response=' + response);
		System.assertEquals( true, response.success, 'Response should be successfull');
		System.assertEquals(response.message, AccountRESTResource.SUCCESS_ACCOUNT_CREATED, 'Response message should inform about account creation');
	}

	@isTest 
	static void test_createAccount_insert_new_account_full() {
		// setup: 
		//non existing account @see beforeEachTest():
		mockPOSTRequest('{"account":{"accountType":"Loyalty", "brand":"L\'Or", "country":"NL", "email":"new@email.com", "gender":"Female", "firstName":"T", "lastName":"TestName", "languagePreference":"English", "consent":{"consentRegistrationSourceUrl": "https://www.registration.source.com", "consentRegistrationDate": "2017-09-27T16:42:10.555Z", "consentText":"very long consent text that nobody reads...", "consentTextVersion": "v1.92", "privacyPolicyVersion":"v1.0", "consentRegistrationIPAddress": "192.168.0.1", "optInUrl":"https://www.opt.IN.url.com", "optOutUrl":"https://www.opt.OUT.url.com", "consentConfirmationUrl":"https://www.con.conf.url.com", "sixteenYearsOrOlder": true}, "shippingAddress":{"street":"My Street 123a", "state":"My State", "city":"My City", "postalCode":"11-111a", "country":"FR"} } }');

		// under test:
		AccountRESTResource.FullResponse response = AccountRESTResource.upsertAccount();

		// assertions:
		List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
		System.assertEquals(4, accountsAfter.size(), 'There should be 4 accounts (3 Existing + 1 New) response=' + response);
		System.assertEquals( true, response.success, 'Response should be successfull');
		System.assertEquals(response.message, AccountRESTResource.SUCCESS_ACCOUNT_CREATED, 'Response message should inform about account creation');
		for (Account account : accountsAfter){
			if (account.External_Id__c == 'new@email.comNLL\'or'){
				System.assertEquals('Loyalty', account.Type__c, 'Account Type should be same as in request');
				System.assertEquals('L\'Or', account.Brand__c, 'Brand should be equal to value from builder');
				System.assertEquals('NL', account.Country__c, 'Country should be equal to value from request');
				System.assertEquals('new@email.com', account.PersonEmail, 'PersonEmail should be equal to value from request');
				System.assertEquals('Female', account.Gender__pc, 'Account gender should be same as in request');
				System.assertEquals('T', account.firstName, 'Account firstName should be same as in request');
				System.assertEquals('TestName', account.LastName, 'LastName should be equal to value from request');
				System.assertEquals( 'English', account.Language__c, 'Language should be equal to value from request.' );
				
				System.assertEquals('https://www.registration.source.com', account.Consent_Registration_Source_URL__c, 'Account consent registration source url should be same as in request');
				System.assertEquals(2017, account.Consent_Registration_Date__c.yearGmt(), 'Account Consent Registration Date YEAR should be same as in request');
				System.assertEquals(9, account.Consent_Registration_Date__c.monthGmt(), 'Account Consent Registration Date MONTH should be same as in request');
				System.assertEquals(27, account.Consent_Registration_Date__c.dayGmt(), 'Account Consent Registration Date DAY should be same as in request');
				System.assertEquals(16, account.Consent_Registration_Date__c.hourGmt(), 'Account Consent Registration Date HOUR should be same as in request');
				System.assertEquals(42, account.Consent_Registration_Date__c.minuteGmt(), 'Account Consent Registration Date MINUTE should be same as in request');
				System.assertEquals(10, account.Consent_Registration_Date__c.secondGmt(), 'Account Consent Registration Date SECOND should be same as in request');
				//NOPE -  milliseconds are lost when stored into database as DateTime... https://success.salesforce.com/ideaView?id=08730000000LhBNAA0
				//System.assertEquals(555, account.Consent_Registration_Date__c.millisecondGmt(), 'Account Consent Registration Date MILLISECOND should be same as in request');
				System.assertEquals('very long consent text that nobody reads...', account.Consent_Text__c, 'Account consent text should be same as in request');
				System.assertEquals('v1.92', account.Consent_Text_Version__c, 'Account consent text version should be same as in request');
				System.assertEquals('v1.0', account.Privacy_Policy_Version__c, 'Account Privacy Policy Version should be same as in request');
				System.assertEquals('192.168.0.1', account.Consent_Registration_IP_Address__c, 'Account consent registration IP address should be same as in request');
				
				System.assertEquals('https://www.opt.IN.url.com', account.Opt_in_URL__c, 'Account opt in URL should be same as in request');
				System.assertEquals('https://www.opt.OUT.url.com', account.Opt_out_URL__c, 'Account opt out URL should be same as in request');
				System.assertEquals('https://www.con.conf.url.com', account.Consent_Confirmation_URL__c, 'Account consent confirmation URL should be same as in request');
				System.assertEquals(true, account.Sixteen_Years_or_Older__c, 'Account Sixteen Years or Older should be same as in request');
				
				Id personRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
				System.assertEquals(personRecordType, account.RecordTypeID, 'Account should be created as PersonAccount');
				// Shipping Address:
				//System.assertEquals( 'My Street 123a', account.ShippingStreet, 'Account Shipping Street should be same as in request.' );
				//System.assertEquals( 'My State', account.ShippingState, 'Account Shipping State should be same as in request.' );
				//System.assertEquals( 'My City', account.ShippingCity, 'Account Shipping City should be same as in request.' );
				//System.assertEquals( '11-111a', account.ShippingPostalCode, 'Account Shipping Postal Code should be same as in request.' );
				//System.assertEquals( 'FR', account.ShippingCountry, 'Account Shipping Country should be same as in request.' );
			}
		}
	}

	@isTest
	static void test_createAccount_consent_status_Registered() {
		// setup:
		// account with consent text:
		mockPOSTRequest('{"account":{ "lastName":"NewName", "email":"jde_new_registered@emark.com", "country":"NL", "brand":"Jacobs", "consent":{"consentText":"Something", "consentRegistrationDate":"2019-04-11T13:38:45Z"} } }');
		Test.startTest();

		// under test:
		AccountRESTResource.FullResponse response = AccountRESTResource.upsertAccount();

		// assertions:
		Account accountAfter = AccountSelector.getAccount( 'jde_new_registered@emark.com', 'NL', 'Jacobs' );
		Test.stopTest();
		System.assertEquals( 'Registered', accountAfter.Consent_Status__c, 'Consent Status should be set to Registered. accountAfter=' + accountAfter );
	}

	@isTest
	static void test_createAccount_consent_status_empty() {
		// setup:
		// account without consent text:
		mockPOSTRequest('{"account":{"lastName":"NewName", "email":"jde_new_empty@emark.com", "country":"NL", "brand":"Jacobs"} }');
		Test.startTest();

		// under test:
		AccountRESTResource.FullResponse response = AccountRESTResource.upsertAccount();

		// assertions:
		Account accountAfter = AccountSelector.getAccount( 'jde_new_empty@emark.com', 'NL', 'Jacobs' );
		Test.stopTest();
		System.assert( String.isBlank( accountAfter.Consent_Status__c ), 'Consent Status should be empty when there is no Consent text in request.' );
	}

	@isTest
	static void test_updateAccount_consent_status_Registered() {
		// setup:
		Test.startTest();
		Account accountBefore = AccountSelector.getAccountByExternalId('existing@email.comNLTassimo');
		AccountUpdateMode__c setting = new AccountUpdateMode__c();
		setting.allowExtendedUpdate__c = true;
		insert setting;

		// REST request with consent text:
		mockPOSTRequest('{"account":{"lastName":"' + accountBefore.LastName 
			+ '","email":"' + accountBefore.PersonEmail
			+ '","country":"' + accountBefore.Country__c
			+ '","brand":"' + accountBefore.Brand__c
			+ '","consent":{"consentText":"Something", "consentRegistrationDate":"2019-04-11T13:38:45Z"} } }');

		// under test:
		AccountRESTResource.FullResponse response = AccountRESTResource.upsertAccount();

		// assertions:
		Account accountAfter = AccountSelector.getAccountByExternalId( accountBefore.External_Id__c );
		Test.stopTest();
		System.assertEquals( 'Registered', accountAfter.Consent_Status__c, 'Consent Status should be set to Registered.' );
	}


	@isTest
	static void test_updateAccount_consent_status_unchanged() {
		// setup:
		Test.startTest();
		Account accountBefore = AccountSelector.getAccountByExternalId('existing@email.comNLTassimo');
		// REST request without consent text:
		mockPOSTRequest('{"account":{"lastName":"' + accountBefore.LastName 
			+ '","email":"' + accountBefore.PersonEmail
			+ '","country":"' + accountBefore.Country__c
			+ '","brand":"' + accountBefore.Brand__c + '"} }');

		// under test:
		AccountRESTResource.FullResponse response = AccountRESTResource.upsertAccount();

		// assertions:
		Account accountAfter = AccountSelector.getAccountByExternalId( accountBefore.External_Id__c );
		Test.stopTest();
		System.assertEquals( accountBefore.Consent_Status__c, accountAfter.Consent_Status__c, 'Consent Status should NOT be changed.' );
		System.assertNotEquals( 'Registered', accountAfter.Consent_Status__c, 'Consent Status should NOT be equal to Registered.' );

	}

	@isTest 
	static void test_updateAccount_limited_mode() {
		// setup:
		Account account = AccountSelector.getAccountByExternalId('existing@email.comNLTassimo');
		account.Consent_Status__c = 'Active';
		upsert account;
		AccountUpdateMode__c setting = new AccountUpdateMode__c();
		setting.allowExtendedUpdate__c = false;
		insert setting;

		//request to change all fields of existing account @see beforeEachTest():
		mockPOSTRequest('{"account":{"brand":"Tassimo", "country":"NL", "email":"existing@email.com", "gender":"Male", "firstName":"T_changed", "lastName":"Name_changed", "languagePreference":"German", "consent":{"consentRegistrationSourceUrl": "https://www.registration.source.com.changed", "privacyPolicyVersion":"v1.0_changed", "consentRegistrationIPAddress": "192.168.0.1", "consentRegistrationDate": "2017-09-27T16:42:10.111Z", "consentText":"very long consent text that nobody reads...", "consentTextVersion": "v1.92", "optInUrl":"https://www.opt.IN.url.com", "optOutUrl":"https://www.opt.OUT.url.com", "consentConfirmationUrl":"https://www.con.CONF.url.com", "sixteenYearsOrOlder": true}, "shippingAddress":{"street":"My Street 123a", "state":"My State", "city":"My City", "postalCode":"11-111a", "country":"FR"} } }');

		// under test:
		AccountRESTResource.FullResponse response = AccountRESTResource.upsertAccount();

		// assertions:
		Boolean allowExtendedUpdate = AccountUpdateMode__c.getOrgDefaults().allowExtendedUpdate__c;
		System.assertEquals( false, allowExtendedUpdate, 'Custom Setting AccountUpdateMode__c.allowExtendedUpdate__c should be unchecked to perform limited fields update. allowExtendedUpdate=' + allowExtendedUpdate );

		List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
		System.assertEquals(3, accountsAfter.size(), 'There should be 3 accounts - no new account should be inserted, only updated. response=' + response);
		System.assertEquals(true, response.success, 'Response should be successfull');
		System.assertEquals(response.message, AccountRESTResource.SUCCESS_ACCOUNT_UPDATED, 'Response message should inform about account update');

		Account accountAfter = AccountSelector.getAccountByExternalId('existing@email.comNLTassimo');
		// fields that should change:
		System.assertEquals('Male', accountAfter.Gender__pc, 'Account Gender should change.');
		System.assertEquals('T_changed', accountAfter.firstName, 'Account firstName should change.');
		System.assertEquals('Name_changed', accountAfter.lastName, 'Account lastName should change.');
		System.assertEquals('https://www.registration.source.com.changed', accountAfter.Consent_Registration_Source_URL__c, 'Account consent registration source url should change.');
		System.assertEquals('v1.0_changed', accountAfter.Privacy_Policy_Version__c, 'Account Privacy Policy Version should change.');
		System.assertEquals('192.168.0.1', accountAfter.Consent_Registration_IP_Address__c, 'Account consent registration IP address should change.');
		// fields that shouldn't change:
		System.assertEquals( 'English', accountAfter.Language__c, 'Account Language should NOT change.');
		System.assertEquals(2018, accountAfter.Consent_Registration_Date__c.yearGmt(), 'Account Consent Registration Date YEAR should NOT change.');
		System.assertEquals(9, accountAfter.Consent_Registration_Date__c.monthGmt(), 'Account Consent Registration Date MONTH should NOT change.');
		System.assertEquals(23, accountAfter.Consent_Registration_Date__c.dayGmt(), 'Account Consent Registration Date DAY should NOT change.');
		System.assertEquals(10, accountAfter.Consent_Registration_Date__c.hourGmt(), 'Account Consent Registration Date HOUR should NOT change.');
		System.assertEquals(32, accountAfter.Consent_Registration_Date__c.minuteGmt(), 'Account Consent Registration Date MINUTE should NOT change.');
		System.assertEquals(56, accountAfter.Consent_Registration_Date__c.secondGmt(), 'Account Consent Registration Date SECOND should NOT change.');
		//NOPE -  milliseconds are lost when stored into database as DateTime... https://success.salesforce.com/ideaView?id=08730000000LhBNAA0
		//System.assertEquals(555, accountAfter.Consent_Registration_Date__c.millisecondGmt(), 'Account Consent Registration Date MILLISECOND should NOT change.');
		System.assertEquals('My consent text...', accountAfter.Consent_Text__c, 'Account consent text should NOT change.');
		System.assertEquals('v1.0', accountAfter.Consent_Text_Version__c, 'Account consent text version should NOT change.');
		System.assertEquals('https://opt.in.pl', accountAfter.Opt_in_URL__c, 'Account opt in URL should NOT change.');
		System.assertEquals('https://opt.out.pl', accountAfter.Opt_out_URL__c, 'Account opt out URL should NOT change.');
		System.assertEquals('https://conf.in.pl', accountAfter.Consent_Confirmation_URL__c, 'Account consent confirmation URL should NOT change.');
		System.assertEquals(true, accountAfter.Sixteen_Years_or_Older__c, 'Account Sixteen Years or Older should be same as in request');
		System.assertEquals('Active', accountAfter.Consent_Status__c, 'Account consent status should NOT change.');
		//Shipping Address:
		//System.assertEquals( 'My Street 123a', accountAfter.ShippingStreet, 'Account Shipping Street should be same as in request.' );
		//System.assertEquals( 'My State', accountAfter.ShippingState, 'Account Shipping State should be same as in request.' );
		//System.assertEquals( 'My City', accountAfter.ShippingCity, 'Account Shipping City should be same as in request.' );
		//System.assertEquals( '11-111a', accountAfter.ShippingPostalCode, 'Account Shipping Postal Code should be same as in request.' );
		//System.assertEquals( 'FR', accountAfter.ShippingCountry, 'Account Shipping Country should be same as in request.' );
	}

	@isTest 
	static void test_updateAccount_extended_mode() {
		// setup:
		Account account = AccountSelector.getAccountByExternalId('existing@email.comNLTassimo');
		account.Consent_Status__c = 'Withdrawn';
		upsert account;
		AccountUpdateMode__c setting = new AccountUpdateMode__c();
		setting.allowExtendedUpdate__c = true;
		insert setting;

		//existing account @see beforeEachTest():
		mockPOSTRequest('{"account":{"brand":"Tassimo", "country":"NL", "email":"existing@email.com", "gender":"Male", "firstName":"T_changed", "lastName":"Name_changed", "languagePreference":"German", "consent":{"consentRegistrationSourceUrl": "https://www.registration.source.com.changed", "privacyPolicyVersion":"v1.0_changed", "consentRegistrationIPAddress": "192.168.0.1", "consentRegistrationDate": "2017-09-27T16:42:10.666Z", "consentText":"very long consent text that nobody reads...", "consentTextVersion": "v1.92", "optInUrl":"https://www.opt.IN.url.com", "optOutUrl":"https://www.opt.OUT.url.com", "consentConfirmationUrl":"https://www.con.CONF.url.com", "sixteenYearsOrOlder": true}, "shippingAddress":{"street":"My Street 123a", "state":"My State", "city":"My City", "postalCode":"11-111a", "country":"FR"} } }');

		// under test:
		AccountRESTResource.FullResponse response = AccountRESTResource.upsertAccount();

		// assertions:
		Boolean allowExtendedUpdate = AccountUpdateMode__c.getOrgDefaults().allowExtendedUpdate__c;
		System.assertEquals( true, allowExtendedUpdate, 'Custom Setting AccountUpdateMode__c.allowExtendedUpdate__c should be checked to perform extended fields update. allowExtendedUpdate=' + allowExtendedUpdate );

		List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
		System.assertEquals(3, accountsAfter.size(), 'There should be 3 accounts - no new account should be inserted, only updated response=' + response);
		System.assertEquals(true, response.success, 'Response should be successfull');
		System.assertEquals(AccountRESTResource.SUCCESS_ACCOUNT_UPDATED, response.message, 'Response message should inform about account update');
		
		Account accountAfter = AccountSelector.getAccountByExternalId('existing@email.comNLTassimo');
		// fields that should change:
		System.assertEquals('Male', accountAfter.Gender__pc, 'Account Gender should change.');
		System.assertEquals('T_changed', accountAfter.firstName, 'Account firstName should change.');
		System.assertEquals('Name_changed', accountAfter.lastName, 'Account lastName should change.');
		System.assertEquals('https://www.registration.source.com.changed', accountAfter.Consent_Registration_Source_URL__c, 'Account consent registration source url should change.');
		System.assertEquals('v1.0_changed', accountAfter.Privacy_Policy_Version__c, 'Account Privacy Policy Version should change.');
		System.assertEquals('192.168.0.1', accountAfter.Consent_Registration_IP_Address__c, 'Account consent registration IP address should change.');
		System.assertEquals(2017, accountAfter.Consent_Registration_Date__c.yearGmt(), 'Account Consent Registration Date YEAR should change.');
		System.assertEquals(9, accountAfter.Consent_Registration_Date__c.monthGmt(), 'Account Consent Registration Date MONTH should change.');
		System.assertEquals(27, accountAfter.Consent_Registration_Date__c.dayGmt(), 'Account Consent Registration Date DAY should change.');
		System.assertEquals(16, accountAfter.Consent_Registration_Date__c.hourGmt(), 'Account Consent Registration Date HOUR should change.');
		System.assertEquals(42, accountAfter.Consent_Registration_Date__c.minuteGmt(), 'Account Consent Registration Date MINUTE should change.');
		System.assertEquals(10, accountAfter.Consent_Registration_Date__c.secondGmt(), 'Account Consent Registration Date SECOND should change.');
		//NOPE -  milliseconds are lost when stored into database as DateTime... https://success.salesforce.com/ideaView?id=08730000000LhBNAA0
		//System.assertEquals(666, accountAfter.Consent_Registration_Date__c.millisecondGmt(), 'Account Consent Registration Date MILLISECOND should change.');
		System.assertEquals('very long consent text that nobody reads...', accountAfter.Consent_Text__c, 'Account consent text should change.');
		System.assertEquals('v1.92', accountAfter.Consent_Text_Version__c, 'Account consent text version should change.');
		System.assertEquals('https://www.opt.IN.url.com', accountAfter.Opt_in_URL__c, 'Account opt in URL should change.');
		System.assertEquals('https://www.opt.OUT.url.com', accountAfter.Opt_out_URL__c, 'Account opt out URL should change.');
		System.assertEquals('https://www.con.CONF.url.com', accountAfter.Consent_Confirmation_URL__c, 'Account consent confirmation URL should change.');
		System.assertEquals(true, accountAfter.Sixteen_Years_or_Older__c, 'Account Sixteen Years or Older should be same as in request');
		System.assertEquals('Registered', accountAfter.Consent_Status__c, 'Account consent status should be changed to Registered.');
		//Shipping Address:
		//System.assertEquals( 'My Street 123a', accountAfter.ShippingStreet, 'Account Shipping Street should be same as in request.' );
		//System.assertEquals( 'My State', accountAfter.ShippingState, 'Account Shipping State should be same as in request.' );
		//System.assertEquals( 'My City', accountAfter.ShippingCity, 'Account Shipping City should be same as in request.' );
		//System.assertEquals( '11-111a', accountAfter.ShippingPostalCode, 'Account Shipping Postal Code should be same as in request.' );
		//System.assertEquals( 'FR', accountAfter.ShippingCountry, 'Account Shipping Country should be same as in request.' );

		// Fields that should NOT change:
		System.assertEquals( 'English', accountAfter.Language__c, 'Account Language should NOT change.');
	}



	@isTest 
	static void test_upsertAccount_returns_error_no_country() {
		// setup:
		// account without required field (no country) 
		mockPOSTRequest('{"account":{"lastName":"ExistingName","email":"existing@email.com","brand":"Jacobs"}}');

		// under test:
		try{
			AccountRESTResource.FullResponse response = AccountRESTResource.upsertAccount();
			// assertions:
			System.assert(false, 'Exception should be thrown and this line should never be reached');
		}
		catch( CalloutException ce ){
			List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
			System.assertEquals(3, accountsAfter.size(), 'There should be 3 accounts - no new account should be inserted');
		}
		catch (Exception e){
			System.assert(false, 'CalloutException should be thrown and this line should never be reached');
		}
	}

	@isTest 
	static void test_upsertAccount_returns_error_no_brand() {
		// setup:
		// account without required field (no brand) 
		mockPOSTRequest('{"account":{"lastName":"ExistingName","email":"existing@email.com","country":"NL"}}');

		// under test:
		try{
			AccountRESTResource.FullResponse response = AccountRESTResource.upsertAccount();
			// assertions:
			System.assert(false, 'Exception should be thrown and this line should never be reached');
		}
		catch( CalloutException ce ){
			List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
			System.assertEquals(3, accountsAfter.size(), 'There should be 3 accounts - no new account should be inserted');
		}
		catch (Exception e){
			System.assert(false, 'CalloutException should be thrown and this line should never be reached');
		}
	}
	
	@isTest 
	static void test_upsertAccount_returns_error_no_email() {
		// setup:
		// account without required field (no email) 
		mockPOSTRequest('{"account":{"lastName":"ExistingName","country":"NL","brand":"Jacobs"}}');

		// under test:
		try{
			AccountRESTResource.FullResponse response = AccountRESTResource.upsertAccount();
			// assertions:
			System.assert(false, 'Exception should be thrown and this line should never be reached');
		}
		catch( CalloutException ce ){
			List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
			System.assertEquals(3, accountsAfter.size(), 'There should be 3 accounts - no new account should be inserted');
		}
		catch (Exception e){
			System.assert(false, 'CalloutException should be thrown and this line should never be reached');
		}
	}

	private static void mockPOSTRequest(String jsonRequestBody){

		RestRequest request = new RestRequest();

		//for the purpose of testing url and headers are not required
		request.httpMethod = 'POST';
		request.requestBody = Blob.valueOf(jsonRequestBody);

		RestContext.request = request;
	}
    
    @isTest 
	static void test_updateAccount_mdc() {
		// setup:
		Account account = AccountSelector.getAccountByExternalId('existing@email.comNLTassimo');
		account.Consent_Status__c = 'Withdrawn';
		upsert account;
		AccountUpdateMode__c setting = new AccountUpdateMode__c();
		setting.allowExtendedUpdate__c = true;
		insert setting;

		//existing account @see beforeEachTest():
		mockPOSTRequest('{"account":{"brand":"Maison du Café","country":"FR","email":"existing@email.com","gender":"Male","firstName":"T_changed","lastName":"Name_changed","languagePreference":"German","BillingStreet":"123 ST","BillingState":"TX","BillingCity":"San Antonio","BillingPostalCode":"12345","BillingCountry":"USA","ShippingStreet":"123 ST","ShippingState":"TX","ShippingCity":"Texas","ShippingPostalCode":"12345","ShippingCountry":"USA","BrewerSelected":"Capsule Brewer","consent":{"consentRegistrationSourceUrl":"https://www.registration.source.com.changed","privacyPolicyVersion":"v1.0_changed","consentRegistrationIPAddress":"192.168.0.1","consentRegistrationDate":"2017-09-27T16:42:10.666Z","consentText":"very long consent text that nobody reads...","consentTextVersion":"v1.92","optInUrl":"https://www.opt.IN.url.com","optOutUrl":"https://www.opt.OUT.url.com","consentConfirmationUrl":"https://www.con.CONF.url.com","sixteenYearsOrOlder":true}}}');

		// under test:
		AccountRESTResource.FullResponse response = AccountRESTResource.upsertAccount();

		// assertions:
		Boolean allowExtendedUpdate = AccountUpdateMode__c.getOrgDefaults().allowExtendedUpdate__c;
		//System.assertEquals( true, allowExtendedUpdate, 'Custom Setting AccountUpdateMode__c.allowExtendedUpdate__c should be checked to perform extended fields update. allowExtendedUpdate=' + allowExtendedUpdate );

		List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
		//ystem.assertEquals(3, accountsAfter.size(), 'There should be 3 accounts - no new account should be inserted, only updated response=' + response);
		//System.assertEquals(true, response.success, 'Response should be successfull');
		//System.assertEquals(AccountRESTResource.SUCCESS_ACCOUNT_UPDATED, response.message, 'Response message should inform about account update');
		
		Account accountAfter = AccountSelector.getAccountByExternalId('existing@email.comNLTassimo');
		// fields that should change:
		//System.assertEquals('Male', accountAfter.Gender__pc, 'Account Gender should change.');
		//System.assertEquals('T_changed', accountAfter.firstName, 'Account firstName should change.');
		//System.assertEquals('Name_changed', accountAfter.lastName, 'Account lastName should change.');
		//System.assertEquals('https://www.registration.source.com.changed', accountAfter.Consent_Registration_Source_URL__c, 'Account consent registration source url should change.');
		//System.assertEquals('v1.0_changed', accountAfter.Privacy_Policy_Version__c, 'Account Privacy Policy Version should change.');
		//System.assertEquals('192.168.0.1', accountAfter.Consent_Registration_IP_Address__c, 'Account consent registration IP address should change.');
		//System.assertEquals(2017, accountAfter.Consent_Registration_Date__c.yearGmt(), 'Account Consent Registration Date YEAR should change.');
		//System.assertEquals(9, accountAfter.Consent_Registration_Date__c.monthGmt(), 'Account Consent Registration Date MONTH should change.');
		//System.assertEquals(27, accountAfter.Consent_Registration_Date__c.dayGmt(), 'Account Consent Registration Date DAY should change.');
		//System.assertEquals(16, accountAfter.Consent_Registration_Date__c.hourGmt(), 'Account Consent Registration Date HOUR should change.');
		//System.assertEquals(42, accountAfter.Consent_Registration_Date__c.minuteGmt(), 'Account Consent Registration Date MINUTE should change.');
		//System.assertEquals(10, accountAfter.Consent_Registration_Date__c.secondGmt(), 'Account Consent Registration Date SECOND should change.');
		//NOPE -  milliseconds are lost when stored into database as DateTime... https://success.salesforce.com/ideaView?id=08730000000LhBNAA0
		//System.assertEquals(666, accountAfter.Consent_Registration_Date__c.millisecondGmt(), 'Account Consent Registration Date MILLISECOND should change.');
		//System.assertEquals('very long consent text that nobody reads...', accountAfter.Consent_Text__c, 'Account consent text should change.');
		//System.assertEquals('v1.92', accountAfter.Consent_Text_Version__c, 'Account consent text version should change.');
		//System.assertEquals('https://www.opt.IN.url.com', accountAfter.Opt_in_URL__c, 'Account opt in URL should change.');
		//System.assertEquals('https://www.opt.OUT.url.com', accountAfter.Opt_out_URL__c, 'Account opt out URL should change.');
		//System.assertEquals('https://www.con.CONF.url.com', accountAfter.Consent_Confirmation_URL__c, 'Account consent confirmation URL should change.');
		//System.assertEquals(true, accountAfter.Sixteen_Years_or_Older__c, 'Account Sixteen Years or Older should be same as in request');
		//System.assertEquals('Registered', accountAfter.Consent_Status__c, 'Account consent status should be changed to Registered.');
		//Shipping Address:
		//System.assertEquals( 'My Street 123a', accountAfter.ShippingStreet, 'Account Shipping Street should be same as in request.' );
		//System.assertEquals( 'My State', accountAfter.ShippingState, 'Account Shipping State should be same as in request.' );
		//System.assertEquals( 'My City', accountAfter.ShippingCity, 'Account Shipping City should be same as in request.' );
		//System.assertEquals( '11-111a', accountAfter.ShippingPostalCode, 'Account Shipping Postal Code should be same as in request.' );
		//System.assertEquals( 'FR', accountAfter.ShippingCountry, 'Account Shipping Country should be same as in request.' );

		// Fields that should NOT change:
		//System.assertEquals( 'English', accountAfter.Language__c, 'Account Language should NOT change.');
	}



}