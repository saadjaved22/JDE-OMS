/* ----------------------------------------------------------------------------------------------
Name: ConsumerAttributes
Description: 

Date         Version     Author              Summary of Changes 
-----------  -------     -----------------   -----------------------------------------
08-March-2018   1.0       Accenture   Intial creation

@modified/fixed by Emark
*/
public class ConsumerAttributes {
    
    public class EncryptionRecordNotFoundException extends Exception {}
    
    private static Map<String, String> STRINGS_TO_ESCAPE = new Map<String,String>();
    static{
        STRINGS_TO_ESCAPE.put( 'é', 'e' );
    }
    
    /*This method populates General attributes at account level.
This method populates account field values based on the user values received as part of parameter.
*/
    public static Account populateGeneralAttributes(User usr, Date birthDate){
        
        Account acc = new Account();
        acc.FirstName = usr.FirstName;
        acc.LastName  = usr.LastName;
        acc.PersonEmail  = usr.Email;
        acc.PersonBirthdate = birthDate;
        acc.BillingStreet  = usr.Street;
        acc.BillingCity = usr.City;
        acc.BillingPostalCode  = usr.postalCode;
        acc.BillingCountry  = 'NL';//usr.Country;
        acc.Type__c = Label.AccountType;
        acc.External_id__c = usr.Email+Label.Country+Label.Brand;
        acc.PersonMobilePhone = usr.MobilePhone;
        
        acc.Sixteen_Years_or_Older__c = system.today().addYears(-16) > birthDate ? true: false;
        // acc.Gender__pc = gender;
        acc.Language__c = 'Dutch';
        acc.country__c = 'NL';
        acc.Brand__C = Label.Brand;
        acc.RecordTypeId = [SELECT ID,NAME FROM RECORDTYPE WHERE SOBJECTTYPE= 'ACCOUNT' AND NAME ='Person Account'].Id;
        acc.ownerId = Label.CommunityOwnerID; 
        acc.Customer_ID__c = GetConsumerDetailsHelper.getMaxDataMigrationID();
        //system.debug('acc.Data_Migration_Id__c '+acc.Data_Migration_Id__c);
        
        return acc;
    }
        
    /*This method populates GDPR related attributes at account level.
This method populates account field values based on the user values received as part of parameter.
*/
    public static List<Account> populateGDPRAttributes(List<Account> lstAccount,string source,string urlVal, Boolean generateOptInUrls){
        
        List<Account> lstAccounts = new List<Account>(); 
        if(generateOptInUrls){
            lstAccount = generateOPTURLS(lstAccount);
        }
        for(Account acc : lstAccount){
            
            if(Label.SourceDE_NL.equalsIgnoreCase(source)){
                acc.Consent_Text__c = Label.ConsentTextPart1 + '\n'+ Label.ConsentTextPart2 + ' '+Label.PrivacyPolicy +' ' + Label.ConsentTextPart3;
                acc.Consent_Text_Version__c = Label.ConsentTextVersion;
                acc.Privacy_Policy_Version__c = Label.PrivacyPolicyNumber;        
                acc.Consent_Registration_Source_URL__c = urlVal;
            }
            acc.Opt_in_Source__c = source;
            acc.Consent_Status__c = 'Registered';
            acc.Consent_Registration_Date__c = System.now();
            
            //acc.Consent_Registration_IP_Address__c = '';
            
            lstAccounts.add(acc);
        }
        return lstAccounts;
    }
    /*This method populates Account registration related attributes at account level.
This method populates account field values based on the user values received as part of parameter.
*/
    public static List<Account> populateAccountRegistrationAttributes(List<Account> lstAccount, String status, String urlVal,string source){
        List<Account> lstAcc = new List<Account>();
        
    
        
        
        for(Account acc : lstAccount){
            
            if(Label.SourceDE_NL.equalsIgnoreCase(source)){
                acc.Account_Consent_Registration_Source_URL__c  = urlVal;
                acc.Privacy_Policy_Summary__c = Label.PrivacyPolicyNumber;
                
            }
             acc.Account_Registration_Status__c = status;
            
            if(acc.Account_Registration_Source__c == NULL){
             	 acc.Account_Registration_Source__c = source;
            }

            String accountConsentDate = string.valueOf(acc.Account_Consent_Registration_Date__c);
            system.debug('accountConsentDate' + acc.Account_Consent_Registration_Date__c);
            if(acc.Account_Consent_Registration_Date__c == null){
            	acc.Account_Consent_Registration_Date__c = System.now();
            }
            String accountRegistrationDate = string.valueOf(acc.Account_Registration_Date__c);
            system.debug('accountConsentDate' + acc.Account_Registration_Date__c);
            if(acc.Account_Registration_Date__c == null){
            	acc.Account_Registration_Date__c = System.today();

            }
            if(string.isNotBlank(acc.Account_Registration_Email__c)){
                acc.Account_Registration_Email__c = acc.PersonEmail;    
            }
            lstAcc.add(acc);
        }
        
        return lstAcc;
    }
    
    public static List<Account> populateAccountAddressRegistrationAttributes(List<Account> lstAccount, String NL, User usr){
        List<Account> accAdd = new List<Account>();
        for(Account accAddress : lstAccount){
            if(accAddress.BillingStreet == null && accAddress.BillingCity == null && accAddress.BillingPostalCode == null){ 
                accAddress.BillingStreet = usr.Street;
                accAddress.BillingCity = usr.City;
                accAddress.BillingPostalCode = usr.postalCode;
                accAddress.BillingCountry = 'NL'; 
                accAdd.add(accAddress); 
            }
            
        }
        
        return accAdd;
    }
    
    /*This method generates opt in and opt out urls for loyalty consumer accounts.
This method makes use of crypto interface to encrypt method to enrypt url.
*/
    public static List<Account> generateOPTURLS(List<Account> lstAccount){
        EncryptionKey__c encrptValue = EncryptionKey__c.getOrgDefaults();
        List<Account> lstAcc = new list<Account> ();
        
        for(Account acc: lstAccount){
            string optIn = encrptValue.OptinURLPlaceholder__c;
            string optOut = encrptValue.OptoutURLPlaceholder__c; 
            
            Long baseTicks  = 621355968000000000L;
            
            Long ticks  = ((system.now().addDays(Integer.valueOf(Label.ExpirationDays)).getTime()) * 10000) + baseTicks; // check aspiration time
            
            Blob cryptoKey  = Blob.valueOf(encrptValue.Key__c); 
            Blob iV = Blob.valueOf(encrptValue.IV__c);
            
            Blob data = Blob.valueOf(acc.External_Id__c);
            Blob encryptedData = Crypto.encrypt(encrptValue.Algorithm__c, cryptoKey, iV, data);
            
            optIn = optIn.replace('EID', EncodingUtil.urlEncode(EncodingUtil.base64encode(encryptedData),'UTF-8'));
            optOut = optOut.replace('EID', EncodingUtil.urlEncode(EncodingUtil.base64encode(encryptedData),'UTF-8'));
            
            optIn = optIn.replace('EXP', String.valueOf(ticks));
            optIn = optIn.replace('CONSVER', Label.ConsentTextVersion);
            optIn = optIn.replace('PRIVVER', Label.PrivacyPolicyNumber);
            
            
            String saltOptIn = String.valueOf(acc.External_Id__c)+string.valueOf(ticks)+Label.ConsentTextVersion+Label.PrivacyPolicyNumber;
            String saltOptOut = String.valueOf(acc.External_Id__c);
            
            Blob signatureOptIn = crypto.generateMac('HmacSHA256',
                                                     Blob.valueOf(saltOptIn), Blob.valueOf(encrptValue.Key__c));
            Blob signatureOptOut = crypto.generateMac('HmacSHA256',
                                                      Blob.valueOf(saltOptOut), Blob.valueOf(encrptValue.Key__c));
            
            optIn = optIn.replace('SIG',(EncodingUtil.convertToHex(signatureOptIn)).replace('-','').toLowerCase());
            optOut = optOut.replace('SIG',(EncodingUtil.convertToHex(signatureOptOut)).replace('-','').toLowerCase());
            
            acc.Opt_out_URL__c = optOut;
            acc.Opt_in_URL__c = optIn;
            
            lstAcc.add(acc);   
        }
        return lstAcc;
    }
    
    /**
* New version of @method generateOPTURLS(). 
* Makes use of metadata and custom settings for URL generation instead of hardcoded labels.
*/
    public static List<Account> generateOPTURLS2(List<Account> accountsForUrls) {
        Map<String, ConsentUrlEncryption__c> encryptionRecords = ConsentUrlEncryptionSelector.getConsentUrlEncryptions();
        Map<String, Community_Consent_Label__mdt> consentLabels = CommunityConsentLabelsSelector.getCommunityConsentLabels();
        List<Account> accountsToUpdate = new List<Account>();
        
        for(Account account : accountsForUrls){
            ConsentUrlEncryption__c encryption;
            Community_Consent_Label__mdt consent;
            if( String.isBlank( account.Brand__c ) && encryptionRecords.containsKey( 'Douwe Egberts' ) && consentLabels.containsKey( 'Douwe Egberts' ) ) {
                encryption = encryptionRecords.get( 'Douwe Egberts' );
                consent = consentLabels.get( 'Douwe Egberts' );
            } else if ( String.isNotBlank( account.Brand__c ) && encryptionRecords.containsKey( account.Brand__c ) && consentLabels.containsKey( escape( account.Brand__c ) ) ){
                encryption = encryptionRecords.get( account.Brand__c );
                consent = consentLabels.get( escape( account.Brand__c ) );
            } else {
                throw new EncryptionRecordNotFoundException( 'Could not match an encryption record for consent URLs' );
            }
            
            Account accountWithUrls = generateOPTURLS2( account, encryption, consent );
            accountsToUpdate.add( accountWithUrls );
        }
        
        return accountsToUpdate;
    }
    
    private static String escape( String text ){
        String escaped = text;
        
        for ( String key : STRINGS_TO_ESCAPE.keySet() ){
            String value = STRINGS_TO_ESCAPE.get( key );
            escaped = escaped.replace( key, value );
        }
        
        return escaped;
    }
    
    private static Account generateOPTURLS2( Account account, ConsentUrlEncryption__c encryption, Community_Consent_Label__mdt consent ){
        
        Long baseTicks  = 621355968000000000L;
        Long ticks  = ((System.now().addDays(Integer.valueOf(Label.ExpirationDays)).getTime()) * 10000) + baseTicks;            
        
        Blob encryptedData = Crypto.encrypt(
            encryption.Algorithm__c, 
            Blob.valueOf(encryption.Private_Key__c), 
            Blob.valueOf(encryption.Initialization_Vector__c), 
            Blob.valueOf(account.External_Id__c)
        );
        
        // Generate opt-in url:
        String optInUrl = encryption.Opt_In_URL_Template__c;
        
        optInUrl = optInUrl.replace( 'EID', EncodingUtil.urlEncode( EncodingUtil.base64encode( encryptedData ) , 'UTF-8' ) );
        optInUrl = optInUrl.replace( 'EXP', String.valueOf( ticks ) );
        optInUrl = optInUrl.replace( 'CONSVER', consent.Consent_Text_Version__c );
        optInUrl = optInUrl.replace( 'PRIVVER', consent.Privacy_Policy_Version__c );
        
        String optInSalt = escape( account.External_Id__c ) 
            + String.valueOf(ticks) 
            + consent.Consent_Text_Version__c 
            + consent.Privacy_Policy_Version__c;
        Blob optInSignature = Crypto.generateMac(
            'HmacSHA256',
            Blob.valueOf( optInSalt ),
            Blob.valueOf( encryption.Private_Key__c )
        );
        optInUrl = optInUrl.replace( 'SIG', EncodingUtil.convertToHex( optInSignature ).replace( '-', '' ).toLowerCase() );
        
        account.Opt_in_URL__c = optInUrl;
        
        // Generate opt-out url:
        String optOutUrl = encryption.Opt_Out_URL_Template__c;
        
        optOutUrl= optOutUrl.replace('EID', EncodingUtil.urlEncode(EncodingUtil.base64encode(encryptedData),'UTF-8'));
        
        String optOutSalt = escape( account.External_Id__c );
        Blob optOutSignature = Crypto.generateMac(
            'HmacSHA256',
            Blob.valueOf( optOutSalt ),
            Blob.valueOf( encryption.Private_Key__c )
        );
        optOutUrl = optOutUrl.replace('SIG', EncodingUtil.convertToHex(optOutSignature).replace('-','').toLowerCase());
        
        account.Opt_out_URL__c = optOutUrl;
        
        return account;
    }
    
    /*Regex method to validate email address*/
    public static Boolean validateEmail(String email) {
        Boolean res = true;
        
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]+'; 
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        
        
        if (!MyMatcher.matches()) 
            res = false;
        return res; 
    }
    
    /*This method implements regex to validate the value based on the regex string received as part of parameter*/
    public static Boolean validateRegex(string regex, string value){
        Boolean res = false;
        
        //String regex = '^([0-9]{4})([A-Za-z]{2})?$|^([0-9]{4}) ([A-Za-z]{2})?$'; 
        Pattern MyPattern = Pattern.compile(regex);
        Matcher MyMatcher = MyPattern.matcher(value);
        if (!MyMatcher.matches()){
            res = true;
        }
        return res;
    }
}