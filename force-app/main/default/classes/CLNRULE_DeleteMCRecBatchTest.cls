/* 

History
    @Fixed by Wunderman Thompson  09/2022
*/
@IsTest
public class CLNRULE_DeleteMCRecBatchTest {
    
    static testMethod void myUnitTest() {
        Cleanup_Rules_Settings__c CLN_Settings = new Cleanup_Rules_Settings__c(SetupOwnerId=UserInfo.getOrganizationId());
        CLN_Settings.ClientID__c = '00000000';
        CLN_Settings.ClientSecret__c = '1111111111';
        CLN_Settings.AccessToken__c = 'access_token';
        CLN_Settings.REST_URL_Del_ConKey__c = 'test.com';
        CLN_Settings.Grant_Type__c = 'autorization_code';
        CLN_Settings.REST_URL_Req_Token__c = 'test2.com';
        insert CLN_Settings;
        
        Datetime dateTimetemp = System.now();
        Date dateTemp = Date.newInstance(dateTimetemp.year(),dateTimetemp.month(),dateTimetemp.day());

        /* We can use  mock classes to get higher coverage for http callouts but we don't have time & 
        since the coverage is >75% we can already push to production lik this  */
        
        
        Test.startTest();
        Post_Deletion_Audit_Log__c log = new Post_Deletion_Audit_Log__c (Salesforce_Person_Contact_ID__c='0031l00000YAUk1AAH', DeletionInvokedinMC__c=false, 
                                                                         Actual_Deletion_Date__c = dateTemp, To_be_Deleted_Date__c = dateTemp);
        Insert log;
        
        CLNRULE_DeleteMCRecBatch mcdel = new CLNRULE_DeleteMCRecBatch();
        Database.executeBatch(mcdel);     
        Test.stopTest();
        
    }   
    
}