/**
* @author piotr.tugeman@emark.com
* Modified by: angelito.cuello@accenture.com
*/
@isTest
private class AccountBuilder_Test {
	
	@isTest
	static void test_setAccountType() {

		//underTest:
		Account account = new AccountBuilder()
		.setAccountType('Newsletter Subscriber')
		.build();

		//assertions:
		System.assertEquals('Newsletter Subscriber', account.Type__c, 'Account Type should be same as in builder');
	}

	@isTest
	static void test_setBrand() {
		
		//underTest:
		Account account = new AccountBuilder()
		.setBrand('Oreo')
		.build();

		//assertions:
		System.assertEquals('Oreo', account.Brand__c, 'Brand__c should be equal to value from builder');
	}

	@isTest
	static void test_setCountry() {
		
		//underTest:
		Account account = new AccountBuilder()
		.setCountry('NL')
		.build();

		//assertions:
		System.assertEquals('NL', account.Country__c, 'Country__c should be equal to value from builder');
	}

	

	@isTest
	static void test_setEmail() {
		
		//underTest:
		Account account = new AccountBuilder()
		.setEmail('my@email.com')
		.build();

		//assertions:
		System.assertEquals('my@email.com', account.PersonEmail, 'PersonEmail should be equal to value from builder');
	}

	@isTest
	static void test_setGender() {

		//underTest:
		Account account = new AccountBuilder()
		.setGender('Female')
		.build();

		//assertions:
		System.assertEquals('Female', account.Gender__pc, 'Account gender should be same as in builder');
	}

	@isTest
	static void test_setFirstName() {

		//underTest:
		Account account = new AccountBuilder()
		.setFirstName('My Name')
		.build();

		//assertions:
		System.assertEquals('My Name', account.firstName, 'Account firstName should be same as in builder');
	}

	@isTest
	static void test_setLastName() {
		
		//underTest:
		Account account = new AccountBuilder()
		.setLastName('TestName')
		.build();

		//assertions:
		System.assertEquals('TestName', account.LastName, 'LastName should be equal to value from builder');
	}

	@isTest
	static void test_setLanguage() {
		
		//underTest:
		Account account = new AccountBuilder()
		.setLanguage( 'English' ) //string
		.build();

		//assertions:
		System.assertEquals( 'English', account.Language__c, 'Language should be equal to value from builder.' );
	}
        
    @isTest
	static void test_setmachineSelection() {
		
		//underTest:
		Account account = new AccountBuilder()
		.setmachineSelection( 'This is just  a test' ) //string
		.build();

		//assertions:
		System.assertEquals( 'This is just  a test', account.Machine_Selection__c, 'MachineSelection should be equal to value from builder.' );
	}
    
	@isTest
	static void test_setConsentRegistrationSourceUrl() {
		//underTest:
		Account account = new AccountBuilder()
		.setConsentRegistrationSourceUrl('https://www.free.candies.com')
		.build();

		//assertions:
		System.assertEquals('https://www.free.candies.com', account.Consent_Registration_Source_URL__c, 'Account consent registration source url should be same as in builder');
	}

	@isTest
	static void test_setConsentRegistrationDate_GMT() {

		//underTest:
		Account account = new AccountBuilder()
		.setConsentRegistrationDate( '2017-08-21 14:30:01' ) //yyyy-MM-dd HH:mm:ss
		.build();

		//assertions:
		System.assertEquals(2017, account.Consent_Registration_Date__c.yearGmt(), 'Account Consent Registration Date YEAR should be same as in builder');
		System.assertEquals(8, account.Consent_Registration_Date__c.monthGmt(), 'Account Consent Registration Date MONTH should be same as in builder');
		System.assertEquals(21, account.Consent_Registration_Date__c.dayGmt(), 'Account Consent Registration Date DAY should be same as in builder');
		System.assertEquals(14, account.Consent_Registration_Date__c.hourGmt(), 'Account Consent Registration Date HOUR should be same as in builder');
		System.assertEquals(30, account.Consent_Registration_Date__c.minuteGmt(), 'Account Consent Registration Date MINUTE should be same as in builder');
		System.assertEquals(1, account.Consent_Registration_Date__c.secondGmt(), 'Account Consent Registration Date SECOND should be same as in builder');
		System.assertEquals(0, account.Consent_Registration_Date__c.millisecondGmt() , 'Request Datetime MILLISECOND should be same as in builder.');
	}

	@isTest
	static void test_setConsentRegistrationDate_ISO_8061() {

		//underTest:
		Account account = new AccountBuilder()
		.setConsentRegistrationDate( '2017-08-21T14:30:01Z' ) //yyyy-MM-ddTHH:mm:ssZ
		.build();
		
		//assertions:
		System.assertEquals(2017, account.Consent_Registration_Date__c.yearGmt(), 'Account Consent Registration Date YEAR should be same as in builder');
		System.assertEquals(8, account.Consent_Registration_Date__c.monthGmt(), 'Account Consent Registration Date MONTH should be same as in builder');
		System.assertEquals(21, account.Consent_Registration_Date__c.dayGmt(), 'Account Consent Registration Date DAY should be same as in builder');
		System.assertEquals(14, account.Consent_Registration_Date__c.hourGmt(), 'Account Consent Registration Date HOUR should be same as in builder');
		System.assertEquals(30, account.Consent_Registration_Date__c.minuteGmt(), 'Account Consent Registration Date MINUTE should be same as in builder');
		System.assertEquals(1, account.Consent_Registration_Date__c.secondGmt(), 'Account Consent Registration Date SECOND should be same as in builder');
		System.assertEquals(0, account.Consent_Registration_Date__c.millisecondGmt() , 'Request Datetime MILLISECOND should be same as in builder.');
	}

	@isTest
	static void test_setConsentRegistrationDate_ISO_8061_with_milliseconds() {

		//underTest:
		Account account = new AccountBuilder()
		.setConsentRegistrationDate( '2017-08-21T14:30:01.666Z' ) //yyyy-MM-ddTHH:mm:ss.SSSZ
		.build();
		
		//assertions:
		System.assertEquals(2017, account.Consent_Registration_Date__c.yearGmt(), 'Account Consent Registration Date YEAR should be same as in builder');
		System.assertEquals(8, account.Consent_Registration_Date__c.monthGmt(), 'Account Consent Registration Date MONTH should be same as in builder');
		System.assertEquals(21, account.Consent_Registration_Date__c.dayGmt(), 'Account Consent Registration Date DAY should be same as in builder');
		System.assertEquals(14, account.Consent_Registration_Date__c.hourGmt(), 'Account Consent Registration Date HOUR should be same as in builder');
		System.assertEquals(30, account.Consent_Registration_Date__c.minuteGmt(), 'Account Consent Registration Date MINUTE should be same as in builder');
		System.assertEquals(1, account.Consent_Registration_Date__c.secondGmt(), 'Account Consent Registration Date SECOND should be same as in builder');
		System.assertEquals(666, account.Consent_Registration_Date__c.millisecondGmt() , 'Request Datetime MILLISECOND should be same as in builder.');
	}

	@isTest
	static void test_setConsentText() {

		//underTest:
		Account account = new AccountBuilder()
		.setConsentText('You agree to everything!')
		.build();

		//assertions:
		System.assertEquals('You agree to everything!', account.Consent_Text__c, 'Account consent text should be same as in builder');
	}

	@isTest
	static void test_setConsentTextVersion() {

		//underTest:
		Account account = new AccountBuilder()
		.setConsentTextVersion('v3.14')
		.build();

		//assertions:
		System.assertEquals('v3.14', account.Consent_Text_Version__c, 'Account consent text version should be same as in builder');
	}

	@isTest
	static void test_setPrivacyPolicyVersion() {

		//underTest:
		Account account = new AccountBuilder()
		.setPrivacyPolicyVersion('1.0')
		.build();

		//assertions:
		System.assertEquals('1.0', account.Privacy_Policy_Version__c, 'Account Privacy Policy Version should be same as in builder');
	}

	@isTest
	static void test_setConsentRegistrationIPAddress() {
		//underTest:
		Account account = new AccountBuilder()
		.setConsentRegistrationIPAddress('192.168.0.0')
		.build();

		//assertions:
		System.assertEquals('192.168.0.0', account.Consent_Registration_IP_Address__c, 'Account consent registration IP address should be same as in builder');
	}

	@isTest
	static void test_setOptInUrl() {

		//underTest:
		Account account = new AccountBuilder()
		.setOptInUrl('https://www.some.site.com')
		.build();

		//assertions:
		System.assertEquals('https://www.some.site.com', account.Opt_in_URL__c, 'Account opt in URL should be same as in builder');
	}

	@isTest
	static void test_setOptOutUrl() {

		//underTest:
		Account account = new AccountBuilder()
		.setOptOutUrl('https://www.goodbye.com')
		.build();

		//assertions:
		System.assertEquals('https://www.goodbye.com', account.Opt_out_URL__c, 'Account opt out URL should be same as in builder');
	}

	@isTest
	static void test_setConsentConfirmationUrl() {
		//underTest:
		Account account = new AccountBuilder()
		.setConsentConfirmationUrl('https://www.do.not.click.com')
		.build();

		//assertions:
		System.assertEquals('https://www.do.not.click.com', account.Consent_Confirmation_URL__c, 'Account consent confirmation url should be same as in builder');
	}

	@isTest
	static void test_setSixteenYearsOrOlder_true() {
		//underTest:
		Account account = new AccountBuilder()
		.setSixteenYearsOrOlder( true )
		.build();

		//assertions:
		System.assertEquals(true, account.Sixteen_Years_or_Older__c, 'Account Sixteen Years or Older should be same as in builder');
	}

	@isTest
	static void test_setSixteenYearsOrOlder_false() {
		//underTest:
		Account account = new AccountBuilder()
		.setSixteenYearsOrOlder( false )
		.build();

		//assertions:
		System.assertEquals(false, account.Sixteen_Years_or_Older__c, 'Account Sixteen Years or Older should be same as in builder');
	}

	@isTest
	static void test_build_createsPersonalAccount() {
		
		//underTest:
		Account account = new AccountBuilder()
		.setLastName('PersonalTest')
		.build();

		//assertions:
		System.assertEquals('PersonalTest', account.LastName, 'LastName should be equal to value from builder');
		Id personRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
		System.assertEquals(personRecordType, account.RecordTypeID, 'Account should be created as PersonAccount');
	}

	@isTest
	static void test_build_setsExternalId() {
		
		//underTest:
		Account account = new AccountBuilder()
		.setEmail('my@email.com')
		.setCountry('NL')
		.setBrand('Milka')
		.build();

		//assertions:
		System.assertEquals('my@email.comNLMilka', account.External_Id__c, 'External_Id should be set as email+country+brand (without delimiters)');
		
	}

	@isTest
	static void test_setShippingStreet() {
		//underTest:
		Account account = new AccountBuilder()
		.setShippingStreet( 'SomeStreet 123a' )
		.build();

		//assertions:
		System.assertEquals( 'SomeStreet 123a', account.ShippingStreet, 'Account Shipping Street should be same as in builder.' );
	}

	@isTest
	static void test_setShippingState() {
		//underTest:
		Account account = new AccountBuilder()
		.setShippingState( 'The Highest State' )
		.build();

		//assertions:
		System.assertEquals( 'The Highest State', account.ShippingState, 'Account Shipping State should be same as in builder.' );
	}

	@isTest
	static void test_setShippingCity() {
		//underTest:
		Account account = new AccountBuilder()
		.setShippingCity( 'My City' )
		.build();

		//assertions:
		System.assertEquals( 'My City', account.ShippingCity, 'Account Shipping City should be same as in builder.' );
	}

	@isTest
	static void test_setShippingPostalCode() {
		//underTest:
		Account account = new AccountBuilder()
		.setShippingPostalCode( '999-99A' )
		.build();

		//assertions:
		System.assertEquals( '999-99A', account.ShippingPostalCode, 'Account Shipping Postal Code should be same as in builder.' );
	}

	@isTest
	static void test_setShippingCountry() {
		//underTest:
		Account account = new AccountBuilder()
		.setShippingCountry( 'My Country' )
		.build();

		//assertions:
		System.assertEquals( 'My Country', account.ShippingCountry, 'Account Shipping Country should be same as in builder.' );
	}
	
}