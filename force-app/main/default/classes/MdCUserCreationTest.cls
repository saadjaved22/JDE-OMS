@isTest(SeeAllData=False)
public class MdCUserCreationTest {
    
    public static List<Account> lstAccount = new List<Account>(); 
    public static List<User> lstUser = new List<User>();
    
    private static testMethod void insertRecord(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.LoyaltyTransactionTrigger__c = True;
        insert ts1;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        accRec.Type__c = 'Loyalty';
        accRec.Brand__c = 'Maison du Café';
        accRec.Consent_Status__c = 'Active';
        lstAccount.add(accRec);
        insert lstAccount;
        //insert accRec;
        
        /*Profile portalProfile = [SELECT Id, Name FROM Profile WHERE Name = 'MdC External Identity User'];
        User user = new User(
        Username = System.now().millisecond() + 'test12345@test.com',
        ContactId = con.Id,
        ProfileId = portalProfile.Id,
        Alias = 'test123',
        Email = 'test12345@test.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'McTesty',
        CommunityNickname = 'test12345',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US',
        isActive = true
        );
        Database.insert(user);  */   
        
        Test.startTest();
        //if(accRec.IsCustomerPortal = false){
            MdcUserCreation.createUserRecord(lstAccount);
        //}
        Test.stopTest();
    }
}