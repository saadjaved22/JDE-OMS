/**
* @author piotr.tugeman@emark.com
*/
public with sharing class AccountBuilder {
    
    //Customer related:
    private String accountType;
    private String brand;
    private String country;
    private String email;
    private String gender;
    private String firstName;
    private String lastName;
    private String language;
    private String machineSelection;
    
    //Consent Related:
    private String consentRegistrationSourceUrl;
    private Datetime consentRegistrationDate;
    private String consentText;
    private String consentTextVersion;
    private String consentStatus;
    private String privacyPolicyVersion;
    private String consentRegistrationIPAddress;
    private String optInUrl;
    private String optOutUrl;
    private String consentConfirmationUrl;
    private Boolean sixteenYearsOrOlder;
    
    //Shipping Address related:
    private String shippingStreet;
    private String shippingState;
    private String shippingCity;
    private String shippingPostalCode;
    private String shippingCountry;
    
    //Brewer Registration
    private String brewerSelected;
    
    //Billing Address related:
    private String billingStreet;
    private String billingState;
    private String billingCity;
    private String billingPostalCode;
    private String billingCountry;
    
    //SOI
    private Boolean singleOptIn;
    
    //Other:
    private Id accountRecordType;
    private static final Id ACCONT_RECORD_TYPE_PERSON = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    public static final String CONSENT_STATUS_CONFIRMED = 'Confirmed';
    public static final String CONSENT_STATUS_REGISTERED = 'Registered';//TODO: use picklist value ?
    
    
    
    public AccountBuilder() {
        //always create accounts with RecordType 'PersonAccount'
        setAccountRecordTypePerson();
    }
    
    private AccountBuilder setAccountRecordTypePerson(){
        this.accountRecordType = ACCONT_RECORD_TYPE_PERSON;
        return	this;
    }
    
    public AccountBuilder setConsentStatus( String consentStatus ){
        this.consentStatus=consentStatus;
        return this;
    }
    
    public AccountBuilder setAccountType( String accountType ){
        this.accountType=accountType;
        return this;
    }
    
    public AccountBuilder setBrand( String brandAPIName ){
        this.brand=brandAPIName;
        return this;
    }
    
    public AccountBuilder setCountry( String country ){
        this.country = country;
        return this;
    }
    
    public AccountBuilder setEmail( String email ){
        this.email = email;
        return this;
    }
    
    public AccountBuilder setGender( String gender ){
        this.gender=gender;
        return this;
    }
    
    public AccountBuilder setFirstName( String firstName ){
        this.firstName=firstName;
        return this;
    }
    
    public AccountBuilder setLastName( String lastName ){
        this.lastName = lastName;
        return this;
    }
    
    public AccountBuilder setLanguage( String language ){
        this.language = language;
        return this;
    }
    
    public AccountBuilder setConsentRegistrationSourceUrl( String consentRegistrationSourceUrl ){
        this.consentRegistrationSourceUrl=consentRegistrationSourceUrl;
        return this;
    }
    
    public AccountBuilder setMachineSelection( String machineSelection ){
		this.machineSelection=machineSelection;
		return this;
	}
   
    /**
* consentRegistrationDate 3 formats supported: 
* 'yyyy-MM-dd HH:mm:ss'
* ISO 8601:
* 'yyyy-MM-ddTHH:mm:ssZ'
* 'yyyy-MM-ddTHH:mm:ss.SSSZ'
*/
    public AccountBuilder setConsentRegistrationDate( String consentRegistrationDate ){
        this.consentRegistrationDate = DateTimeUtil.valueOfGmt( consentRegistrationDate );
        return this;
    }
    
    public AccountBuilder setConsentText( String consentText ){
        this.consentText=consentText;
        return this;
    }
    
    public AccountBuilder setConsentTextVersion( String consentTextVersion ){
        this.consentTextVersion=consentTextVersion;
        return this;
    }
    
    public AccountBuilder setPrivacyPolicyVersion( String privacyPolicyVersion ){
        this.privacyPolicyVersion=privacyPolicyVersion;
        return this;
    }
    
    public AccountBuilder setConsentRegistrationIPAddress( String consentRegistrationIPAddress ){
        this.consentRegistrationIPAddress=consentRegistrationIPAddress;
        return this;
    }
    
    public AccountBuilder setOptInUrl( String optInUrl ){
        this.optInUrl=optInUrl;
        return this;
    }
    
    public AccountBuilder setOptOutUrl( String optOutUrl ){
        this.optOutUrl=optOutUrl;
        return this;
    }
    
    public AccountBuilder setConsentConfirmationUrl( String consentConfirmationUrl ){
        this.consentConfirmationUrl=consentConfirmationUrl;
        return this;
    }
    
    public AccountBuilder setSixteenYearsOrOlder( Boolean sixteenYearsOrOlder ){
        this.sixteenYearsOrOlder=sixteenYearsOrOlder;
        return this;
    }
    
    public AccountBuilder setBrewerSelected (String BrewerSelected){
        this.BrewerSelected = BrewerSelected;
        return this;
    }
    
    public AccountBuilder setBillingStreet(String BillingStreet){
        this.BillingStreet = BillingStreet;
        return this;
    }
    
    public AccountBuilder setBillingState(String BillingState){
        this.BillingState = BillingState;
        return this;
    }
    
    public AccountBuilder setBillingCity(String BillingCity){
        this.BillingCity = BillingCity;
        return this;
    }
    
    public AccountBuilder setBillingPostalCode(String BillingPostalCode){
        this.BillingPostalCode = BillingPostalCode;
        return this;
    }
    
    public AccountBuilder setBillingCountry(String BillingCountry){
        this.BillingCountry = BillingCountry;
        return this;
    }
    
    public AccountBuilder setShippingStreet( String ShippingStreet ){
        this.ShippingStreet = ShippingStreet;
        return this;
    }
    
    public AccountBuilder setShippingState( String ShippingState ){
        this.ShippingState = ShippingState;	
        return this;
    }
    
    public AccountBuilder setShippingCity( String ShippingCity ){
        this.ShippingCity = ShippingCity;
        return this;
    }
    
    public AccountBuilder setShippingPostalCode( String ShippingPostalCode ){
        this.ShippingPostalCode = shippingPostalCode;
        return this;
    }
    
    public AccountBuilder setShippingCountry( String ShippingCountry ){
        this.ShippingCountry = ShippingCountry;
        return this;
    }
    
     public AccountBuilder setSingleOptIn(Boolean singleOptIn){
        this.singleOptIn = singleOptIn;
        return this;
    }
    
    public Account build(){
        
        Account acc = new Account();
        
        //Customer related:
        if ( String.isNotEmpty(this.accountType) ){
            acc.Type__c = this.accountType;
        }
        
        if ( String.isNotEmpty(this.country) ){
            acc.Country__c = this.country;
        }
        
        if ( String.isNotEmpty(this.brand) ){
            acc.Brand__c = this.brand;
        }
        
        if ( String.isNotEmpty(this.email) ){
            acc.PersonEmail = this.email;
        }
        
        if ( String.isNotEmpty(this.gender) ){
            acc.Gender__pc = this.gender;
        }
        if ( String.isNotEmpty(this.firstName) ){
            acc.firstName = this.firstName;
        }
        
        acc.lastName = this.lastName;
        
        if ( String.isNotEmpty( this.language ) ){
            acc.Language__c = this.language;
        }
        if ( String.isNotEmpty( this.machineSelection ) ){
			acc.Machine_Selection__c = this.machineSelection;
		}

        //Consent related:		
        if ( String.isNotEmpty(this.consentRegistrationSourceURL) ){
            acc.Consent_Registration_Source_URL__c = this.consentRegistrationSourceURL;
        }
        if ( null != this.consentRegistrationDate ){
            acc.Consent_Registration_Date__c = this.consentRegistrationDate;
        }
        if ( String.isNotEmpty(this.consentText) ){
            acc.Consent_Text__c = this.consentText;
        }
        if ( String.isNotEmpty(this.consentTextVersion) ){
            acc.Consent_Text_Version__c = this.consentTextVersion;
        }
        if ( String.isNotBlank( this.consentStatus ) ){
            acc.Consent_Status__c = this.consentStatus;
        }
        if ( String.isNotEmpty(this.privacyPolicyVersion) ){
            acc.Privacy_Policy_Version__c = this.privacyPolicyVersion;
        }
        if ( String.isNotEmpty(this.consentRegistrationIPAddress) ){
            acc.Consent_Registration_IP_Address__c = this.consentRegistrationIPAddress;
        }
        if ( String.isNotEmpty(this.optInURL) ){
            acc.Opt_in_URL__c = this.optInURL;
        }
        if ( String.isNotEmpty(this.optOutUrl) ){
            acc.Opt_out_URL__c = this.optOutUrl;
        }
        if ( String.isNotEmpty(this.consentConfirmationUrl) ){
            acc.Consent_Confirmation_URL__c = this.consentConfirmationUrl;
        }
        if ( null != this.sixteenYearsOrOlder ){
            acc.Sixteen_Years_or_Older__c = this.sixteenYearsOrOlder;
        }
        
        if( String.isNotEmpty(this.BrewerSelected)){
            acc.Brewers_Selected__c = this.BrewerSelected;
        }
        
        //Billing Address related:
        if(String.isNotEmpty(this.BillingStreet)){
            acc.BillingStreet = this.BillingStreet;
        }
        
        if(String.isNotEmpty(this.BillingState)){
            acc.BillingState = this.BillingState;
        }
        
        if(String.isNotEmpty(this.BillingCity)){
            acc.BillingCity = this.BillingCity;
        }
        
        if(String.isNotEmpty(this.BillingPostalCode)){
            acc.BillingPostalCode = this.BillingPostalCode;
        }
        
        if(String.isNotEmpty(this.BillingCountry)){
            acc.BillingCountry = this.BillingCountry;
        }
        //Shipping Address related:
        if ( String.isNotEmpty( this.ShippingStreet ) ){
            acc.ShippingStreet = this.ShippingStreet;
        }
        if ( String.isNotEmpty( this.ShippingState ) ){
            acc.ShippingState = this.ShippingState;
        }
        if ( String.isNotEmpty( this.ShippingCity ) ){
            acc.ShippingCity = this.ShippingCity;
        }
        if ( String.isNotEmpty( this.ShippingPostalCode ) ){
            acc.ShippingPostalCode = this.ShippingPostalCode;
        }
        if ( String.isNotEmpty( this.ShippingCountry ) ){
            acc.ShippingCountry = this.ShippingCountry;
        }
        
        //single opt in:
        if ( null != this.singleOptIn ){
            acc.Single_Opt_in__c = this.singleOptIn;
        }
        
        //Fields not mapped directly:
        acc.RecordTypeID = this.accountRecordType;
        acc.External_Id__c = this.email + this.country + this.brand;
        return acc;     
    }
}