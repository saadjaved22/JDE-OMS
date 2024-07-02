/**
* REST endpoint to allow Account Creation
*
* @author piotr.tugeman@emark.com
*/
@RestResource(urlMapping='/v1/personAccount')
global with sharing class AccountRESTResource{
    public static final String SUCCESS_ACCOUNT_CREATED = 'Account created';
    public static final String SUCCESS_ACCOUNT_UPDATED = 'Account updated';
    
    
    @HttpPost
    global static FullResponse upsertAccount(){
        RestRequest request = RestContext.request; //deadend 
        System.debug('Incoming request uri: ' + request.requestURI + ' parh:' + request.resourcePath + 'headers:' + request.headers + ' body: ' + request.requestBody.toString());
        FullResponse response;
        Account requestedAccount = readAccountDataFrom(request);
        Account existingAccount = findInDatabase (requestedAccount);
        
        try{
            // create:
            if (null == existingAccount){
                System.debug('Account with ExternalID=[' + requestedAccount.External_Id__c + '] does NOT exist. Creating new Account');
                saveNewAccount(requestedAccount);
                response = generateResponse(true, requestedAccount, SUCCESS_ACCOUNT_CREATED);
            }
            // update:
            else {
                System.debug('Account with ExternalID=[' + requestedAccount.External_Id__c + '] already exists. Updating with relevant data');
                updateWithNewValues(existingAccount, requestedAccount);
                response = generateResponse (true, requestedAccount, SUCCESS_ACCOUNT_UPDATED);
            }
        }
        catch (AccountException ae){
            System.debug('AccountException catched. Can return relevant response. ae:' + ae + ' for account:' + ae.getAccount() + ' stackTrace:' + ae.getStackTraceString());
            response = generateResponse (false, ae.getAccount(), ae.getMessage());
        }
        
        System.debug('Sending response: ' + response);
        return response;        
    }
    
    @TestVisible
    private static Account readAccountDataFrom(RestRequest request){
        System.debug('request123' + request);
        String requestBody = request.requestBody.toString();
        System.debug('requestBody123' + requestBody);
        FullRequest fullRequest = (FullRequest) JSON.deserialize(requestBody, FullRequest.class);
        System.debug('fullRequest123' + fullRequest);
        RESTRequestAccount restAccount = fullRequest.account;
        System.debug('restAccount123' + restAccount);
        
        checkMandatoryFields(restAccount);
        
        AccountBuilder accountBuilder = new AccountBuilder()
            .setAccountType(restAccount.accountType)
            .setBrand(restAccount.brand)
            .setCountry(restAccount.country)
            .setEmail(restAccount.email)
            .setGender(restAccount.gender)
            .setFirstName(restAccount.firstName)
            .setLastName(restAccount.lastName)
            .setLanguage(restAccount.languagePreference)
            .setBrewerSelected(restAccount.BrewerSelected)
            .setSingleOptIn(restAccount.singleOptIn)
            .setmachineSelection(restAccount.machineSelection);
            
            if (null != restAccount.consent){
                accountBuilder.setConsentRegistrationSourceUrl(restAccount.consent.consentRegistrationSourceUrl)
                    .setConsentRegistrationDate(restAccount.consent.consentRegistrationDate)
                    .setConsentText(restAccount.consent.consentText)
                    .setConsentTextVersion(restAccount.consent.consentTextVersion)
                    .setPrivacyPolicyVersion(restAccount.consent.privacyPolicyVersion)
                    .setConsentRegistrationIPAddress(restAccount.consent.consentRegistrationIPAddress)
                    .setOptInUrl(restAccount.consent.optInUrl)
                    .setOptOutUrl(restAccount.consent.optOutUrl)
                    .setConsentConfirmationUrl(restAccount.consent.consentConfirmationUrl)
                    .setSixteenYearsOrOlder(restAccount.consent.sixteenYearsOrOlder);
            }
        
        if(restAccount.brand == 'Maison du Café' && restAccount.country == 'FR' && restAccount.BrewerSelected != null && 
           (restAccount.BillingStreet != null || restAccount.BillingState != null || restAccount.BillingCity != null || restAccount.BillingPostalCode != null || 
            restAccount.BillingCountry != null || restAccount.ShippingStreet != null || restAccount.ShippingState != null || restAccount.ShippingCity != null || 
            restAccount.ShippingPostalCode != null || restAccount.ShippingCountry != null)){
                AccountBuilder.setBillingStreet(restAccount.BillingStreet);
                AccountBuilder.setBillingState(restAccount.BillingState);
                AccountBuilder.setBillingCity(restAccount.BillingCity);
                AccountBuilder.setBillingPostalCode(restAccount.BillingPostalCode);
                AccountBuilder.setBillingCountry(restAccount.BillingCountry);
                AccountBuilder.setShippingStreet(restAccount.ShippingStreet);
                AccountBuilder.setShippingState(restAccount.ShippingState);
                AccountBuilder.setShippingCity(restAccount.ShippingCity);
                AccountBuilder.setShippingPostalCode(restAccount.ShippingPostalCode);
                AccountBuilder.setShippingCountry(restAccount.ShippingCountry);
            }
        
        Account requestedAccount = accountBuilder.build();        
        return requestedAccount;
    }
    
    private static void checkMandatoryFields( RESTRequestAccount restAccount){
        if (String.isEmpty(restAccount.country)){
            throw new CalloutException('Can\'t create Account - country is mandatory. Country from request:' + restAccount.country);
        }
        if (String.isEmpty(restAccount.brand)){
            throw new CalloutException('Can\'t create Account - brand is mandatory. Brand from request:' + restAccount.brand);
        }
        
        if (String.isEmpty(restAccount.email)){
            throw new CalloutException('Can\'t create Account - email is mandatory. Email from request:' + restAccount.email);
        }
    }
    
    /**
	* @return null if Account not found in database
	*/
    @TestVisible
    private static Account findInDatabase (Account account){
        Account existingAccount = AccountSelector.getAccountByExternalId(account.External_Id__c);
        return existingAccount;
    }
    
    /**
	* Overwrites only selected fields.
	*/
    private static void updateWithNewValues(Account existingAccount, Account requestedAccount){
        
        Account updatedAccount;
        if (shouldDoExtendedUpdate(existingAccount)){
            updatedAccount = doExtendedUpdate(existingAccount, requestedAccount);
        }
        else {
            updatedAccount = doLimitedUpdate(existingAccount, requestedAccount);
        }
        
        System.debug('Upserting Account:' + updatedAccount );
        upsert updatedAccount;
    }
    
    /** @return true when:
	* A) global switch is UPDATE
	* OR
	* B) existing account status is: empty, Withdrawn, Pending Confirmation, Expired, Registered
	*/
    private static Boolean shouldDoExtendedUpdate(Account existingAccount){
        
        Boolean allowExtendedUpdate = AccountUpdateMode__c.getOrgDefaults().allowExtendedUpdate__c;
        if (allowExtendedUpdate){
            System.debug('Account is eligible for extended update because Custom Setting AccountUpdateMode__c.allowExtendedUpdate__c is:' + allowExtendedUpdate);
            return true;
        }
        
        String consentStatus = existingAccount.Consent_Status__c;
        if (String.isEmpty(consentStatus)
            || 'EXPIRED' == consentStatus.toUpperCase()
            || 'PENDING CONFIRMATION' == consentStatus.toUpperCase()
            || 'REGISTERED' == consentStatus.toUpperCase()
            || 'WITHDRAWN' == consentStatus.toUpperCase()
           ){
               System.debug('Account is eligible for extended update because its Consent Status is:' + consentStatus);
               return true;
           }
        
        System.debug('Account is NOT eligible for extended update because its Consent Status is:' + consentStatus + ' and Custom Setting AccountUpdateMode__c.allowExtendedUpdate__c is:' + allowExtendedUpdate);
        return false;
    }
    
    private static Account doExtendedUpdate(Account existingAccount, Account requestedAccount){
        
        existingAccount = doLimitedUpdate(existingAccount, requestedAccount);
        //A new criteria added for the FACM functionality
        if(null != requestedAccount.Consent_Registration_Date__c){
            existingAccount.Consent_Registration_Date__c = requestedAccount.Consent_Registration_Date__c;
        }
        if(String.isNotBlank(requestedAccount.Consent_Text__c)){
            existingAccount.Consent_Text__c = requestedAccount.Consent_Text__c;
            existingAccount.Consent_Status__c = AccountBuilder.CONSENT_STATUS_REGISTERED;
        }
        if(String.isNotEmpty(requestedAccount.Consent_Text_Version__c)){
            existingAccount.Consent_Text_Version__c = requestedAccount.Consent_Text_Version__c;
        }
        if(String.isNotEmpty(requestedAccount.Opt_in_URL__c)){
            existingAccount.Opt_in_URL__c = requestedAccount.Opt_in_URL__c;
        }
        if(String.isNotEmpty(requestedAccount.Opt_out_URL__c)){
            existingAccount.Opt_out_URL__c = requestedAccount.Opt_out_URL__c;
        }
        if(String.isNotEmpty(requestedAccount.Consent_Confirmation_URL__c)){
            existingAccount.Consent_Confirmation_URL__c = requestedAccount.Consent_Confirmation_URL__c;
        }
        
        return existingAccount;
    }
    
    private static Account doLimitedUpdate(Account existingAccount, Account requestedAccount){
        
        if(null != requestedAccount.Consent_Registration_Date__c){
            existingAccount.New_Registered_Date__c = requestedAccount.Consent_Registration_Date__c;
        }
        if(String.isNotEmpty(requestedAccount.Gender__pc)){
            existingAccount.Gender__pc = requestedAccount.Gender__pc;
        }
        if(String.isNotEmpty(requestedAccount.firstName)){
            existingAccount.firstName = requestedAccount.firstName;
        }
        if(String.isNotEmpty(requestedAccount.lastName)){
            existingAccount.lastName = requestedAccount.lastName;
        }
        if(String.isNotEmpty(requestedAccount.Consent_Registration_Source_URL__c)){
            existingAccount.Consent_Registration_Source_URL__c = requestedAccount.Consent_Registration_Source_URL__c;
        }
        if(String.isNotEmpty(requestedAccount.Privacy_Policy_Version__c)){
            existingAccount.Privacy_Policy_Version__c = requestedAccount.Privacy_Policy_Version__c;
        }
        if(String.isNotEmpty(requestedAccount.Consent_Registration_IP_Address__c)){
            existingAccount.Consent_Registration_IP_Address__c = requestedAccount.Consent_Registration_IP_Address__c;
        }
        if(null != requestedAccount.Sixteen_Years_or_Older__c){
            existingAccount.Sixteen_Years_or_Older__c = requestedAccount.Sixteen_Years_or_Older__c;
        }
        
        // Update Shipping Address
        if(String.isNotEmpty(requestedAccount.ShippingStreet)){
            existingAccount.ShippingStreet = requestedAccount.shippingStreet;
        }
        if(String.isNotEmpty(requestedAccount.ShippingState)){
            existingAccount.ShippingState = requestedAccount.ShippingState;
        }
        if(String.isNotEmpty(requestedAccount.ShippingCity)){
            existingAccount.ShippingCity = requestedAccount.ShippingCity;
        }
        if(String.isNotEmpty(requestedAccount.ShippingPostalCode)){
            existingAccount.ShippingPostalCode = requestedAccount.ShippingPostalCode;
        }
        if(String.isNotEmpty(requestedAccount.ShippingCountry)){
            existingAccount.ShippingCountry = requestedAccount.ShippingCountry;
        }
        
        return existingAccount;
    }
    
    private static void saveNewAccount(Account account){
        if(String.isNotBlank(account.Consent_Text__c) && account.Single_Opt_in__c == false){
            account.Consent_Status__c = AccountBuilder.CONSENT_STATUS_REGISTERED;
        }
        if(String.isNotBlank(account.Consent_Text__c) && account.Single_Opt_in__c == true){
            account.Consent_Status__c = AccountBuilder.CONSENT_STATUS_CONFIRMED;
        }
        System.debug('insert acc:' + account);
        insert account;
    }
    
    
    @TestVisible
    private static FullResponse generateResponse(Boolean success, Account account, String message){
        FullResponse response = new FullResponse();
        RESTResponseAccount responseAccount = new RESTResponseAccount();
        responseAccount.externalId = account.External_Id__c;
        response.account = responseAccount;
        response.success = success;
        response.message = message;
        return response;
    }
    //==========Inner classes used for serialization/deserialization of request/response bodies =========================================
    public class FullRequest{
        private RESTRequestAccount account;
    }
    
    public class RESTRequestAccount{
        private String accountType;
        private String brand;
        private String country;
        private String email;
        private String gender;
        private String firstName;
        private String lastName;
        private String languagePreference;
        private String BrewerSelected;
        private String ShippingStreet;
        private String ShippingState;
        private String ShippingCity;
        private String ShippingPostalCode;
        private String ShippingCountry;
        private String BillingStreet;
        private String BillingState;
        private String BillingCity;
        private String BillingPostalCode;
        private String BillingCountry;
        private RESTRequestConsent consent;
        private RESTRequestShippingAddress shippingAddress;
        private Boolean singleOptIn;
        private String machineSelection;
    }
    
    public class RESTRequestConsent{
        private String consentRegistrationSourceUrl;
        private String consentRegistrationDate;
        private String consentText;
        private String consentTextVersion;
        private String privacyPolicyVersion;
        private String consentRegistrationIPAddress;
        private String optInUrl;
        private String optOutUrl;
        private String consentConfirmationUrl;
        private Boolean sixteenYearsOrOlder;
    }
    
    public class RESTRequestShippingAddress{ 
        public String ShippingStreet; 
        public String state; 
        public String city; 
        public String postalCode; 
        public String country;
    }
    
    global class FullResponse{
        public Boolean success;
        public String message;
        public RESTResponseAccount account;
    }
    
    public class RESTResponseAccount {
        public String externalId;
    }
}