@isTest(SeeAllData=False)
public class MaskingUserRecordTest {
    
    public static List<Account> lstAccount = new List<Account>(); 
    public static List<User> lstUser = new List<User>();
    
    private static testMethod void testMaskingUser(){
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account account1 = new Account();
        account1.RecordTypeId = recordTypeId;
        account1.LastName = 'Testing';
        account1.PersonEmail = account1.LastName + '@gmail.com';
        account1.CurrencyIsoCode = 'EUR';
        lstAccount.add(account1);
        insert lstAccount;
        
        Set<ID> setAccId = new Set<ID>();
        for(Account acc : lstAccount){
            try{
                setAccId.add(acc.Id);  
            }
            
            catch(Exception ex){                
            }
        }
        
        Profile p= [SELECT id FROM Profile WHERE Name = 'MdC External Identity User'];
        System.debug('Profile: ' + p.Id);
        for(Account acc : [SELECT Id, FirstName, LastName, PersonEmail, IsCustomerPortal, Type__c, Brand__c, Consent_Status__c, PersonContactId FROM Account WHERE Id IN: setAccId]){
            System.debug('Person Contact ID: ' + acc.PersonContactId);
            User usr = new User( Firstname= acc.FirstName,
                           Lastname = acc.LastName,
                           EmailEncodingKey = 'UTF-8',
                           Email = acc.PersonEmail,
                           ProfileId = p.Id,
                           Username = acc.PersonEmail + '.fr',
                           alias = 'T',
                           LanguageLocaleKey = 'en_US',
                           TimeZoneSidKey = 'America/Los_Angeles',
                           CommunityNickname = CommunityUsersFactory.createRandomDigits(7),
                           IsActive = True
                           );
            usr.LocaleSidKey ='en_US';
            usr.ContactId = acc.PersonContactId;
            lstUser.add(usr);
        }
        
        insert lstUser;
    }
    
   
    //static void createUser{
        //lstAccount = TestDataFactory.testAccountData();
        //lstUser = TestDataFactory.TestCreateUser(4, True);
    //}
   
    @isTest
    static void DeactivateUser(){
        Test.startTest();
        testMaskingUser();
        MaskingUser.MaskCommunityUserForAccount(lstAccount);
        
        Test.stopTest();
    }
}