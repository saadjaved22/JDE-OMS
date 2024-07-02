global without sharing class ForceDeleteConsumer {
    webservice static String forceDeleteAction(Id accountId){
        string status = 'Failed';
        forceDeleteConsumerSetting__c forceDeleteConsumer = forceDeleteConsumerSetting__c.getInstance();
                
        if(!forceDeleteConsumer.Access_to_force_deletion_process__c){
            status = forceDeleteConsumer.Insufficient_access_error__c;
            return status;
        }
        
        Id userId;
        Account accountRec = new Account();
        accountRec.Id = accountId;
            Id contactId = [Select contactID__pc from Account where id =: accountId LIMIT 1].contactID__pc;
        List<User> userList = [Select ID, IsPortalEnabled, IsActive from User where contactId =: contactId Limit 1];
        if (userList.size() > 0)
        {
            User userRec = userList.get(0);
			userRec.Force_Delete_User__c = True;            
            Update userRec;
            status = forceDeleteConsumer.Successfully_deleted_text__c;
        }else {
            Delete accountRec;
            status = forceDeleteConsumer.Successfully_deleted_text__c;
        }
        return status;
    }
    
    @future
    webservice static void deleteAccount(Id accountId){
        Account accountRec = new Account(Id = accountId);
        if(Test.isRunningTest()){return;}
        Delete accountRec;
    }  
    @InvocableMethod
    webservice static void deleteAccountPB(List<Account> accountList){
       deleteAccount(accountList[0].Id);
    }  
}