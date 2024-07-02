/**
 * UT for fixes/modifications only.
 *
 * WARNING: those test need metada: Community_Consent_Label__mdt with Label 'Maison du Cafe' to run correctly
 *
 * @author piotr.tugeman@emark.com
 */
@isTest
public class ConsumerAttributes_Test {

    @testSetup
	static void beforeEachTest(){

		Test.startTest();
        // based on current jded2cfull state:
        ConsentUrlEncryption__c encryption = new ConsentUrlEncryption__c();
        encryption.Name = 'Maison du Café';
        encryption.Algorithm__c = 'AES256';
        encryption.Initialization_Vector__c = '7402862816488480';
        encryption.Opt_In_URL_Template__c = 'https://maisonducafecom-acc.jdecoffee.net/Newsletter/Confirmation/?id=EID&e=EXP&cv=CONSVER&pv=PRIVVER&s=SIG&origin=sf';
        encryption.Opt_Out_URL_Template__c = 'https://maisonducafecom-acc.jdecoffee.net/Newsletter/Opt-out/?id=EID&s=SIG&origin=sf';
        encryption.Private_Key__c = 'falcwE3A6lFtyNWiPJoVDeHoH6h/QZ7X';

        insert encryption;

        EncryptionKey__c encrptValue = new EncryptionKey__c(SetupOwnerId = UserInfo.getOrganizationId());
        encrptValue.Algorithm__c = 'AES256';
        encrptValue.IV__c = '7402862816488480';
        encrptValue.Key__c = 'falcwE3A6lFtyNWiPJoVDeHoH6h/QZ7X';
        encrptValue.OptinURLPlaceholder__c = 'ttps://douwe-egberts-acc-nl.jdecoffee.net/Newsletter/Confirmation/?id=EID&e=EXP&cv=CONSVER&pv=PRIVVER&s=SIG&origin=sf';
        encrptValue.OptoutURLPlaceholder__c = 'https://douwe-egberts-acc-nl.jdecoffee.net/Newsletter/Opt-out/?id=EID&s=SIG&origin=sf';
        
        insert encrptValue;

        Account a = new AccountBuilder()
        .setFirstName( 'Test')
        .setLastName( 'Name 1' )
        .setBrand( 'Maison du Café')
        .setCountry( 'NL' )
        .setEmail( 'sfdc+jde+encryption+test@emark.com')
        .build();

        insert a;

		Test.stopTest();
	}

    @isTest
    static void test_generateOPTURLS2_wont_alter_account(){
        // setup:
        Test.startTest();
        Account a = AccountSelector.getAccount( 'sfdc+jde+encryption+test@emark.com', 'NL', 'Maison du Café');

        // under test:
        List<Account> a1After = ConsumerAttributes.generateOPTURLS2( new List<Account>{a} );

        // assertions:
        Test.stopTest();
        System.assertEquals( 'Maison du Café', a1After[0].Brand__c, 'Even though \'é\' in Brand__c was replaced with \'e\' during url generation, Assount.Brand__c should remain unchanged.' );
        System.assertEquals( a.External_Id__c, a1After[0].External_Id__c, 'Eventhou \'é\' in External_Id__c was replaced with \'e\' during url generation, Assount.External_Id__c should remain unchanged.' );
    }

    @isTest
    static void test_generateOPTURLS2_e_opt_out(){
        // setup:
        Test.startTest();
        Account a = AccountSelector.getAccount( 'sfdc+jde+encryption+test@emark.com', 'NL', 'Maison du Café');
        
        // under test:
        List<Account> accountsAfter = ConsumerAttributes.generateOPTURLS2( new List<Account>{a} );

        // assertions:
        Test.stopTest();
        // below was checked with similar algorithm on EPI side for identical input:
        String optOutUrl = 'https://maisonducafecom-acc.jdecoffee.net/Newsletter/Opt-out/?id=F9kR%2F5mkqAaAhzcWEaHjf9KM5lVWgxgqYfTGd59cLn6Mg3T1M3IkWFxfyStunx8zAjTkxyncfNX%2BrQi4YwAYsg%3D%3D&s=1c9519a065a0627ab33cf7d5695722a06ba242a9cecfdb6998ec30b8f7cfa8eb&origin=sf';
        System.assertEquals( optOutUrl, accountsAfter[0].Opt_out_URL__c, 'Generated Opt_out_URL__c should be the same as in EPI.' );
    }

    @isTest
    static void test_generateOPTURLS2_e_opt_in(){
        // setup:
        Test.startTest();
        Community_Consent_Label__mdt currentSetup = [SELECT Label, Consent_Text_Version__c,Privacy_Policy_Version__c FROM Community_Consent_Label__mdt WHERE Label='Maison du Cafe'];
        Account a = AccountSelector.getAccount( 'sfdc+jde+encryption+test@emark.com', 'NL', 'Maison du Café');

        // under test:
        List<Account> accountsAfter = ConsumerAttributes.generateOPTURLS2( new List<Account>{a} );

        // assertions:
        String ticks = accountsAfter[0].Opt_in_URL__c.split( '&' )[1].split( '=' )[1];
        //manual SIG encryption (without é)::
        String salted = 'sfdc+jde+encryption+test@emark.comNLMaison du Cafe' + ticks + currentSetup.Consent_Text_Version__c + currentSetup.Privacy_Policy_Version__c;
        List<ConsentUrlEncryption__c> encryptions = [SELECT Private_Key__c FROM ConsentUrlEncryption__c WHERE Name='Maison du Café'];
        Blob signature = Crypto.generateMac('HmacSHA256', Blob.valueOf( salted ), Blob.valueOf( encryptions[0].Private_Key__c ) );
        String sigWithoutE = EncodingUtil.convertToHex( signature ).replace('-','').toLowerCase();
        //getting SIG ecryption from generated url: 
        String sig = accountsAfter[0].Opt_in_URL__c.split( '&' )[4].split( '=' )[1];
        Test.stopTest();

        System.assertEquals( sigWithoutE, sig, 'Generated SIG in Opt_in_URL__c should be the same as generated without \'é\'.' );
    }

    @IsTest
    static void testPopulateAccountAddressRegistrationAttributes(){
        Id userId = UserInfo.getUserId();
        User u = [SELECT Name,Street, City, postalCode FROM User WHERE Id = :userId];
        Account a = new Account(Name = 'testAccountZ',BillingStreet = null, BillingCity = null, BillingPostalCode = null, BillingCountry = null);
        List<Account> accList = new List<Account>{a};

        Test.startTest();
            List<Account> pAccList = ConsumerAttributes.populateAccountAddressRegistrationAttributes(accList, 'NL', u);
            System.assert(pAccList.size() > 0);
        Test.stopTest();
        
    }
    @IsTest
    static void TestpopulateGeneralAttributes(){
        Account a = new Account (Name = 'test',Customer_ID__c = 1);
        insert a;
        User u = new User(LastName ='TestL', FirstName ='TestF', Email ='test@test.com', Street = 'test',City ='Test land',Country='test land',MobilePhone ='0000000');
        Test.startTest();
            Account acc = ConsumerAttributes.populateGeneralAttributes(u,Date.today().addDays(-20));
        Test.stopTest();

        System.assert(acc != null);
        
    }

    @IsTest
    static void testPopulateGDPRAttributes(){
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account acc = new Account(LastName ='test accc');
        acc.recordTypeId = recordTypeId;
        acc.Consent_Text__c =null;
        acc.Consent_Text_Version__c = null;
        acc.Privacy_Policy_Version__c = null;
        acc.Consent_Registration_Source_URL__c = null;
        acc.Opt_in_Source__c = null;
        acc.Consent_Status__c = null;
        acc.Consent_Registration_Date__c = null;
        acc.External_Id__c = 'test@tet.com.DE NL';
        insert acc;

        Test.startTest();
          List<Account> accList =   ConsumerAttributes.populateGDPRAttributes(new List<Account>{acc}, Label.SourceDE_NL, 'urlVal', true);
        Test.stopTest();

        System.assert(accList[0].Opt_in_Source__c == Label.SourceDE_NL);
        System.assert(accList[0].Consent_Status__c == 'Registered');
        System.assert(accList[0].Consent_Registration_Date__c != null);
        
    }

    @IsTest
    static void testPopulateAccountRegistrationAttributes(){
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account acc = new Account(LastName ='test accc');
        acc.recordTypeId = recordTypeId;
        acc.Account_Consent_Registration_Source_URL__c =null;
        acc.Privacy_Policy_Summary__c = null;
        acc.Account_Registration_Status__c = null;
        acc.Account_Consent_Registration_Date__c = null;
        acc.Account_Registration_Date__c = null;
        acc.Account_Registration_Email__c = 'test@gmail.com';
        acc.PersonEmail = 'test@test.com';
        acc.External_Id__c = 'test@tet.com.DE NL';
        insert acc;

        Test.startTest();
          List<Account> accList =   ConsumerAttributes.populateAccountRegistrationAttributes(new List<Account>{acc},'Active', 'urlVal', Label.SourceDE_NL);
        Test.stopTest();

        System.assert(accList[0].Account_Consent_Registration_Source_URL__c  == 'urlVal' );
        System.assert(accList[0].Privacy_Policy_Summary__c == Label.PrivacyPolicyNumber);
        System.assert(accList[0].Account_Registration_Status__c == 'Active');
        System.assert(accList[0].Account_Registration_Email__c == accList[0].PersonEmail);

        
    }
    
    @IsTest
    static void testValidEmail(){
        String mail = 'test@tgmail.com';
        String wrongMail = '!:;!:;!:@;:!;!';
        
        Test.startTest();
            Boolean v1 =  ConsumerAttributes.validateEmail(mail);
            Boolean v2 =  ConsumerAttributes.validateEmail(wrongMail);
        Test.stopTest();
        System.assert(v1 == true);
        System.assert(v2 == false);
        
    }
    
    @IsTest
    static void testValidateRegex(){
        String mail = 'test@tgmail.com';
        String wrongMail = '!:;!:;!:@;:!;!';
        String regex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]+'; 
        Test.startTest();
            Boolean v1 =  ConsumerAttributes.validateRegex(regex, mail);
            Boolean v2 =  ConsumerAttributes.validateRegex(regex, wrongMail);
        Test.stopTest();
        System.assert(v1 == false);
        System.assert(v2 == true);
        
    }

    @IsTest
    static void testGenerateFacebookOPTURLS2(){
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account acc = new Account(Name ='test accc',External_Id__c ='test@external.com',Opt_out_URL__c = Null);
        acc.recordTypeId = recordTypeId;
        List<Account> accList = new List<Account>{acc};
        List<ConsentUrlEncryption__c> cueList = new List<ConsentUrlEncryption__c>();
        cueList.add(new ConsentUrlEncryption__c( Name = 'Facebook - Moccona AU', Algorithm__c ='AES256', Initialization_Vector__c ='7402862816488480',
                    Opt_In_URL_Template__c = 'https://moccona-au-acc.jdecoffee.net/newsletter/confirmation-page/?id=EID&e=EXP&cv=CONSVER&pv=PRIVVER&s=SIG&origin=sf',
                    Opt_Out_URL_Template__c = 'https://moccona-au-acc.jdecoffee.net/newsletter/opt-out/?id=EID&s=SIG&origin=sf', 
                    Private_Key__c='falcwE3A6lFtyNWiPJoVDeHoH6h/QZ7X'));
        cueList.add(new ConsentUrlEncryption__c( Name = 'Facebook - Moccona NZ', Algorithm__c ='AES256', Initialization_Vector__c ='7402862816488480',
                    Opt_In_URL_Template__c = 'https://moccona-nz-acc.jdecoffee.net/newsletter/confirmation-page/?id=EID&e=EXP&cv=CONSVER&pv=PRIVVER&s=SIG&origin=sf',
                    Opt_Out_URL_Template__c = 'https://moccona-nz-acc.jdecoffee.net/newsletter/opt-out/?id=EID&s=SIG&origin=sf', 
                    Private_Key__c ='falcwE3A6lFtyNWiPJoVDeHoH6h/QZ7X'));
        cueList.add(new ConsentUrlEncryption__c( Name = 'Facebook - LOr AU', Algorithm__c ='AES256', Initialization_Vector__c ='7402862816488480',
                    Opt_In_URL_Template__c = 'https://lorespressocomau-acc.jdecoffee.net/newsletter/confirmation/?id=EID&e=EXP&cv=CONSVER&pv=PRIVVER&s=SIG&origin=sf',
                    Opt_Out_URL_Template__c = 'https://lorespressocomau-acc.jdecoffee.net/newsletter/opt-out/?id=EID&s=SIG&origin=sf', 
                    Private_Key__c='falcwE3A6lFtyNWiPJoVDeHoH6h/QZ7X'));
        cueList.add(new ConsentUrlEncryption__c( Name = 'Facebook - LOr NZ', Algorithm__c ='AES256', Initialization_Vector__c ='7402862816488480',
                    Opt_In_URL_Template__c = 'https://lorespressonz-acc.jdecoffee.net/newsletter/confirmation/?id=EID&e=EXP&cv=CONSVER&pv=PRIVVER&s=SIG&origin=sf',
                    Opt_Out_URL_Template__c = 'https://lorespressonz-acc.jdecoffee.net/newsletter/opt-out/?id=EID&s=SIG&origin=sf', 
                    Private_Key__c='falcwE3A6lFtyNWiPJoVDeHoH6h/QZ7X'));
        insert cueList;
		/*
        Test.startTest();
            List<Account> pAccList = ConsumerAttributes.generateFacebookOPTURLS2(accList);
            System.assert(pAccList.size() > 0);
        Test.stopTest();   
		*/
    }
}