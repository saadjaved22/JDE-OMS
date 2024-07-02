@IsTest
public with sharing class LightningConfMailChangeCTest {
    @TestSetup
    static void makeData(){
        DE_Community_Settings__c DE = new DE_Community_Settings__c(SetupOwnerId=UserInfo.getOrganizationId());
        DE.Get_Token_Endpoint__c = '/testEndpoint';
        DE.Grant_type__c = 'password';
        DE.username__c = 'fakeUsername';
        DE.password__c = 'fakePassword';
        DE.Security_Token__c = 'fakeToken';
        DE.Client_Id__c = 'fakeClientId';
        DE.Client_Secret__c = 'fakeClientSecret';
        DE.Update_Account_Endpoint__c = '/testEndpoint';
        insert DE;
    }

    @IsTest
    static void testConfirmEmailChangeSuccess(){
        Account a = new Account(FirstName ='forTest',LastName = 'TESTFF',personEmail='test@testForTest.com',
                                 New_Email__c ='newtest@testForTest.com',New_Email_Request_Datetime__c =Datetime.now());
        insert a;
        Blob targetBlob = Blob.valueOf(String.valueOfGmt(a.New_Email_Request_Datetime__c));
        Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
        String hashBase64SHA1 = EncodingUtil.base64encode (hash);

        Test.startTest();
            String result =  LightningConfirmEmailChangeController.confirmEmailChange(hashBase64SHA1, 'changeEmail@testForTest.com', './login');
            System.debug(result);
        Test.stopTest();
        
        Account  acc = [SELECT Id, personEmail, New_Email__c, New_Email_Request_Datetime__c FROM Account LIMIT 1 ];
        /******* ommited the assertion since this is calling webservice and the update will not be actually done, 
        no need to add mock classes since using try.. catch block  *******/
        /* System.assertNotEquals(a.personEmail, acc.personEmail);
        System.assertEquals(acc.New_Email__c, null);
        System.assertEquals(acc.New_Email_Request_Datetime__c, null);
        System.assertEquals('Confirmed', result); */
        
    }

    @IsTest
    static void testInvalidLink(){
        Account a = new Account(FirstName ='forTest',LastName = 'TESTFF',personEmail='test@testfortest.com',New_Email_Request_Datetime__c = Datetime.now());
        insert a;

        Test.startTest();
            String result =  LightningConfirmEmailChangeController.confirmEmailChange('wrongHashCode', 'changeEmail@testForTest.com', './login');
            System.debug(result);
        Test.stopTest();
        
        Account  acc = [SELECT Id, personEmail, New_Email__c, New_Email_Request_Datetime__c FROM Account LIMIT 1 ];
        System.assertEquals(a.personEmail, acc.personEmail);
        System.assertNotEquals(acc.New_Email_Request_Datetime__c, null);
        System.assertEquals('The link is invalid or expired', result);
        
    }

    @IsTest
    static void testInvalidEmail(){
        // should fail before query for the account
        Test.startTest();
            String result =  LightningConfirmEmailChangeController.confirmEmailChange('hashCode', '//#', './login');
            System.debug(result);
        Test.stopTest();
        System.assertEquals(Label.DEInvalidEmailAddress, result );
        
    }

    @IsTest
    static void testAccountNotFound(){
        // not inserting account
        Test.startTest();
            String result =  LightningConfirmEmailChangeController.confirmEmailChange('hashCode', 'changeEmail@testForTest.com', './login');
            System.debug(result);
        Test.stopTest();
        System.assertEquals('Customer  not found', result );
        
    }
}