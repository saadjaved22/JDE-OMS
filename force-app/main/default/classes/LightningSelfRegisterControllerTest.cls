@IsTest
public with sharing class LightningSelfRegisterControllerTest {
 
    static {
        List<Account> lstacc = TestDataFactory.testAccountData();
        List<Loyalty__c> lstloyal = TestDataFactory.testLoyaltyData(lstacc);
        TestDataFactory.setCustomSetting();
        TestDataFactory.setProcessBuilderSettings();
    }
    
    /* Verifies that IsValidPassword method with various password combinations. */
    @IsTest
    static void testIsValidPassword() {
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true);
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false);
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', null) == false);
        System.assert(LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false);
    }

    @IsTest
    static void testSiteAsContainerEnabled() {
        System.assertNotEquals(null, LightningSelfRegisterController.siteAsContainerEnabled('https://portaleu1-developer-edition.eu11.force.com'));
    }
    
    /* Verifies the selfRegistration method flow with various invalid inputs */
    @IsTest
    static void testSelfRegistration() {
        Map < String, String > paramsMap = initializeParams();
        System.assertNotEquals(null, paramsMap);
        /* System.assertEquals(Label.GenderMissing, 
                            LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         '', paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'))); */
        
        
        System.assertEquals(Label.Site.lastname_is_required, 
                            LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent')));
        
        System.assertEquals(Label.Site.email_is_required, 
                            LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent')));
        
        System.assertEquals(Label.Site.email_is_required, 
                            LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null, 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                          paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent')));

        System.assertEquals(Label.DEInvalidEmailAddress, 
                            LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), 'testuser@1', paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent')));
        
        System.assertEquals(Label.DateOfBirthMissing, 
                            LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                          '', paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent')));
        
        System.assertEquals(Label.InvalidDate, 
                            LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         '03-Mar-1992', paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent')));
        
        System.assertEquals(Label.site.passwords_dont_match, 
                            LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), 
                                                                         paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent')));
        
        System.assertNotEquals(null, 
                               LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), 
                                                                            paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), 
                                                                            paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                            paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                            paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                            paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent')));
    }
    
    
    /* Verifies the selfRegistration flow for valid inputs */
    @IsTest
    static void testSelfRegisterWithProperCredentials() {
        Map < String, String > paramsMap = initializeParams();
        LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), 
                                                     paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                     paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                     paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                     paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                     paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));
    }
    
    
    
    @IsTest
    static void testGetNullExtraFields() {
        System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields(null));
    }
    
    @IsTest
    static void testGetNonEmptyExtraFields() {
        System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields('field1'));
    }
    
    /* Verifies validation of extraFields within the Self Registration flow */
    @IsTest
    static void testGetExtraFieldsInSelfRegistration() {
        List < Map < String, Object >> fieldlist = new List < Map < String, Object >> ();
        Map < String, String > paramsMap = initializeParams();
        Map < String, Object > fieldMap = new Map < String, Object > ();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);
        System.assertNotEquals(null, 
                               LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), 
                                                                            paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                            extraFields, paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                            paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                            paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                            paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent')));
    }
    
    @IsTest
    static void LightningSelfRegisterControllerInstantiation() {
        LightningSelfRegisterController controller = new LightningSelfRegisterController();
        System.assertNotEquals(controller, null);
    }
    
    @isTest
    static void LightningSelfRegisterControllerArgumentsMissing(){
        Map < String, String > paramsMap = initializeParams();
		
        LightningSelfRegisterController.selfRegister('firstNameCharacterMoreThan40firstNameCharacterMoreThan40', paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         '', paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));
        
        LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'),
                                                     'firstNameCharacterMoreThan40firstNameCharacterMoreThan40firstNameCharacterMoreThan40firstNameCharacterMoreThan40', 
                                                     paramsMap.get('email'), paramsMap.get('password'), 
                                                     paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                     paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                     '', paramsMap.get('postcode'), 
                                                     paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                     paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));
        
        LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         '2015-03-15', paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));
        
		LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         String.valueOf(System.today().addDays(2)), paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));        
        
        LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         'abcd',  paramsMap.get('commercialConsent'));        
        
        LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), '', paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));        
        
		string streetMoreThan200Chars ='StreetMoreThan200CharsStreetMoreThan200CharsStreetMoreThan200CharsStreetMoreThan200CharsStreetMoreThan200CharsStreetMoreThan200CharsStreetMoreThan200CharsStreetMoreThan200CharsStreetMoreThan200CharsDone';
        LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), streetMoreThan200Chars, paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));                
        
        LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         '', paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));
		LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         'abcd', paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));        
    	LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), '', 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));
		LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), 'abcd', 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));        
    
    	LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), '', 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));
    	
    	LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), 
                                                     					'CityNameCharacterMoreThan40CityNameCharacterMoreThan40', 
                                                                         paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));
    
    	LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), 
                                                                         paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), 
                                                                         paramsMap.get('extraFields'), paramsMap.get('startUrl'), Boolean.valueOf(paramsMap.get('includePassword')), 
                                                                         paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                                         paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                                         paramsMap.get('mobileNumber'), paramsMap.get('commercialConsent'));
    }
    
    @isTest
    static void LightningSelfRegisterControllerSuccessRecord(){
     	Map < String, String > paramsMap = initializeParams();
		
        LightningSelfRegisterController.selfRegister('firstName', paramsMap.get('lastName'), paramsMap.get('email'), '', 
                                                     '', null, paramsMap.get('regConfirmUrl'), null,
                                                     paramsMap.get('startUrl'), false, 
                                                     paramsMap.get('birthdate'), paramsMap.get('postcode'), 
                                                     paramsMap.get('houseNumber'), paramsMap.get('streetName'), paramsMap.get('cityName'), 
                                                     paramsMap.get('mobileNumber'),  paramsMap.get('commercialConsent'));   
    }
    
    @IsTest
    static void testSetExperienceId() {
        System.assertNotEquals(null, LightningSelfRegisterController.setExperienceId('test1'));
    }
    
    /* Helper method to initialize the parameters required for SelfRegistration. */
    public static Map < String, String > initializeParams() {
        Map < String, String > paramsMap = new Map < String, String > ();
        String firstName = 'test';
        String lastName = 'User';
        String email = 'testUser@salesforce.com';
        String password = 'testuser123';
        String confirmPasswordCorrect = 'testuser123';
        String confirmPasswordWrong = 'wrongpassword';
        String accountId = 'testuser123';
        String regConfirmUrl = 'http://registration-confirm.com';
        String extraFields = null;
        String startUrl = 'http://my.company.salesforce.com';
        String includePassword = 'True';
        // String gender = 'Male'; 
        String birthdate = '1992-03-15';
        String postcode = '1236 AC';
        String houseNumber = '22 A'; 
        String streetName = 'Mckinley hill';
        String cityName = 'Taguig'; 
        String mobileNumber = '+31610927815'; 
        String sixTnYrsOld = 'True';
        String commercialConsent = 'True';
        
        paramsMap.put('firstName', firstName);
        paramsMap.put('lastName', lastName);
        paramsMap.put('email', email);
        paramsMap.put('password', password);
        paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
        paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
        paramsMap.put('accountId', accountId);
        paramsMap.put('regConfirmUrl', regConfirmUrl);
        paramsMap.put('extraFields', extraFields);
        paramsMap.put('startUrl', startUrl);
        paramsMap.put('includePassword', includePassword);
        // paramsMap.put('gender', gender);
        paramsMap.put('birthdate', birthdate);
        paramsMap.put('postcode', postcode);
        paramsMap.put('houseNumber', houseNumber);
        paramsMap.put('streetName', streetName);
        paramsMap.put('cityName', cityName);
        paramsMap.put('mobileNumber', mobileNumber);
        paramsMap.put('sixTnYrsOld', sixTnYrsOld);
        paramsMap.put('commercialConsent', commercialConsent);
        return paramsMap;
    }
}