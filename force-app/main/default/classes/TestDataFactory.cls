/* ----------------------------------------------------------------------------------------------
   Name: TestDataFactory
   Description: All Test Data records
   Date         Version     Author              Summary of Changes 
   -----------  -------     -----------------   -----------------------------------------
   15-March-2018   1.0       ralph.r.v.gozarin   Intial creation
*/
@isTest(seeAllData = false)
public with sharing class TestDataFactory {

    public static EncryptionKey__c setCustomSetting(){
        //EncryptionKey__c encrypnKey;     
        EncryptionKey__c encrypnKey = EncryptionKey__c.getOrgDefaults();

        encrypnKey.Algorithm__c = 'AES256';
        encrypnKey.IV__c = '7402862816488480';
        encrypnKey.Key__c = 'falcwE3A6lFtyNWiPJoVDeHoH6h/QZ7X';
        encrypnKey.OptinURLPlaceholder__c = 'https://denl-test.jdecoffee.net/Newsletter/Confirmation/?id=EID&e=EXP&cv=CONSVER&pv=PRIVVER&s=SIG&origin=sf';
        encrypnKey.OptoutURLPlaceholder__c = 'https://denl-test.jdecoffee.net/Newsletter/Opt-out/?id=EID&s=SIG&origin=sf';
        upsert encrypnKey EncryptionKey__c.Id;


        return encrypnKey;
    }

    public static ProcessBuilderSettings__c setProcessBuilderSettings(){
        ProcessBuilderSettings__c prcSettings = ProcessBuilderSettings__c.getOrgDefaults();

        prcSettings.AccountProcessBuilder__c = false;
        prcSettings.LoyaltyProcessBuilder__c = false;
        prcSettings.IndividualEmailResultProcessBuilder__c = false;
        prcSettings.LoyaltyTransactionProcessBuilder__c = true;
        upsert prcSettings ProcessBuilderSettings__c.Id;
        system.debug('prc settings '+prcSettings);
        return prcSettings;
    }

    public static List<User> TestCreateUser(Integer i, Boolean isEmailPostFix){
        Map<String,Profile> mapProfile  = new Map<String,Profile>();
        mapProfile =  DELoyaltyCommunityHelper.mapProfileDetail(new Set<String> {Label.DECommunityProfile});
        List<User> lstUser = new List<User>();
        String email = '';

        for (Integer x=i; x>=0; x--) {
            if (isEmailPostFix){
                email = '_jde' + i + '@douweegberts.com.de.nl';
            } else {
                email = 'jde' + i + '@douweegberts.com.de.nl';
            }

            User user = new User(
                Alias = 'JDEUser' + i,
                Email = email,            
                EmailEncodingKey = 'UTF-8',
                LastName = 'User' + i,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = mapProfile.get(Label.DECommunityProfile).Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = email,
                isActive = true
            );
            lstUser.add(user);
        }

        return lstUser;
    }

    public static List<Account> testAccountData(){ 
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(
            new Account(
                FirstName = 'Test',
                LastName = 'User',
                PersonEmail = 'jde1@douweEgberts.com',
                Gender__pc = 'Male',
                PersonBirthdate = System.today().addYears(-18),
                BillingPostalCode = '12365',
                BillingStreet = 'Mckinley hill:22:A',
                BillingCity = 'Taguig',
                Phone = '12345567465',
                Sixteen_Years_or_Older__c = True,
                Data_Migration_Id__c = '123456',
                Customer_ID__c = 123456,
                External_Id__c = 'jde1@douweEgberts.comNLDouwe Egberts',
                Account_Consent_Registration_Date__c =  system.today(),
                Type__c = 'Loyalty',
                Consent_Status__c = 'Active',
                Brand__c = Label.Brand, //Douwe Egberts
                OwnerId = Label.CommunityOwnerID,
                RecordTypeId  = [SELECT ID FROM RECORDTYPE WHERE SOBJECTTYPE = 'ACCOUNT' AND NAME = 'Person Account'].Id
            )
		);

        lstAccount.add(
            new Account(
                FirstName = 'test',
                LastName = 'User 2',
                PersonEmail = 'jde2@douweEgberts.com',
                Gender__pc = 'Male',
                PersonBirthdate = System.today().addYears(-18),
                BillingPostalCode = '12365',
                BillingStreet = 'Mckinley hill:100:E',
                BillingCity = 'Taguig',
                Phone = '12345567465',
                Sixteen_Years_or_Older__c = True,
                Data_Migration_Id__c = '1234567',
                Customer_ID__c = 1234567,
                External_Id__c = 'jde2@douweEgberts.comNLDouwe Egberts' ,
                Type__c = 'Loyalty',
                Consent_Status__c = 'Withdrawn',
                Consent_Registration_Date__c = system.today(),
                Brand__c = Label.Brand, //Douwe Egberts
                OwnerId = Label.CommunityOwnerID,
                RecordTypeId  = [SELECT ID FROM RECORDTYPE WHERE SOBJECTTYPE = 'ACCOUNT' AND NAME = 'Person Account'].Id
            )
        );

        lstAccount.add(
            new Account(
                FirstName = 'test',
                LastName = 'User 3',
                PersonEmail = 'jde3@douweEgberts.com',
                Gender__pc = 'Male',
                PersonBirthdate = system.today().addDays(-20),
                BillingPostalCode = '12365',
                BillingStreet = 'Mckinley hill',
                BillingCity = 'Taguig',
                Phone = '12345567465',
                Sixteen_Years_or_Older__c = True,
                Data_Migration_Id__c = '12345678',
                Customer_ID__c = 12345678,
                External_Id__c = 'jde3@douweEgberts.comNLDouwe Egberts' ,
                Type__c = 'Loyalty',
                Consent_Status__c = 'Active',
                Consent_Registration_Date__c = system.today(),
                Brand__c = Label.Brand, //Douwe Egberts
                OwnerId = Label.CommunityOwnerID,
                RecordTypeId  = [SELECT ID FROM RECORDTYPE WHERE SOBJECTTYPE = 'ACCOUNT' AND NAME = 'Person Account'].Id
            )
          );

            lstAccount.add(
            new Account(
                FirstName = 'test',
                LastName = 'User 4',
                PersonEmail = 'jde4@douweEgberts.com',
                Gender__pc = 'Male',
                PersonBirthdate = system.today().addDays(-20),
                BillingPostalCode = '12365',
                BillingStreet = 'Mckinley hill',
                BillingCity = 'Taguig',
                Phone = '12345567465',
                Sixteen_Years_or_Older__c = True,
                Data_Migration_Id__c = '123456789',
                Customer_ID__c = 123456789,
                External_Id__c = 'jde4@douweEgberts.comNLDouwe Egberts' ,
                Type__c = 'Loyalty',
                Consent_Status__c = 'Active',
                Consent_Registration_Date__c = system.today(),
                Brand__c = Label.Brand, //Douwe Egberts
                OwnerId = Label.CommunityOwnerID,
                RecordTypeId  = [SELECT ID FROM RECORDTYPE WHERE SOBJECTTYPE = 'ACCOUNT' AND NAME = 'Person Account'].Id
            )
        );

        insert lstAccount;
        return lstAccount;
	}


    public static List<Loyalty__c> testLoyaltyData(List<Account> lstacc) {
        List<Loyalty__c> lstLoyal = new List<Loyalty__c>();
        Integer cnt = 1;

        for(Account acc: lstacc) {
            Loyalty__c loyal = new Loyalty__c(
                External_Id__c = '12' + crypto.getRandomInteger(),
                //Loyalty_Account_Number__c = '12345' + cnt,
                Loyalty_Card_Number__c = '12' + crypto.getRandomInteger(),
                Loyalty_Card_Created_Date__c = Date.today(),
                Loyalty_Card_Status__c = 'Active',
                Loyalty_Card_Blocked_Date__c = Date.today().addYears(1),
                Loyalty_Consumer__c = acc.Id
            );
            cnt++;
            lstLoyal.add(loyal);
        }


        insert lstLoyal;
        lstLoyal = [SELECT ID,NAME,External_Id__c,Loyalty_Card_Number__c,
                    		Loyalty_Card_Created_Date__c,Loyalty_Card_Status__c,Loyalty_Card_Blocked_Date__c,
                   			Loyalty_Consumer__c 
                    FROM Loyalty__c
                    WHERE ID IN :lstLoyal];
        system.debug('lstLoyal '+lstLoyal);
        return lstLoyal;
    }
}