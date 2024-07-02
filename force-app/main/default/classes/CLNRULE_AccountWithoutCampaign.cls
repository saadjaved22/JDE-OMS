global class CLNRULE_AccountWithoutCampaign implements Database.Batchable<SObject>{
    
    //constructor
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, PersonContactId, Deletion_Flag__c, ContactID__pc FROM Account WHERE Deletion_Flag__c = FALSE');
    }
    
    //Method to execute to run batch job logic
    global void execute(Database.BatchableContext BC, List<Account> scope){
        Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
        List<Account> accountsToBeUpdated = new List<Account>();
        Set<String> accIdSet = new Set<String>();
        for(Account accRec : scope){
            accIdSet.add(accRec.Id);
        }
        
        
        //Getting all available Campaigns for Accounts SELECTED
        List<CampaignMember> campMemList = [SELECT Id, Contact.AccountId, Campaign.EndDate, Campaign.CreatedDate FROM CampaignMember WHERE Contact.AccountId IN: accIdSet AND Campaign.EndDate != null ORDER BY Campaign.EndDate];
        //Map<Id, CampaignMember> campMemMap = new Map<Id, CampaignMember>();
        
        //Declaration of ID Set
        Set<Id> campMemSet = new Set<Id>();
        //Looping within Campaign List to Transfer data from List to Set
        for(CampaignMember campRec : campMemList){
            //campMemMap.put(campRec.Contact.AccountId, campRec);
            
            //Add row data to set
            campMemSet.add(campRec.Contact.AccountId);
            
        }
        //Table that will be used to see which accounts are to be updated
        List<Account> accListInsert = new List<Account>();
        for(Account accRec : [SELECT Id, Account_Deletion_Date__c,Account_Registration_Status__c, Consent_Status__c, Consent_Withdrawn_Date__c, isHardBounced__pc,
                              Deletion_Flag__c, Deletion_Reason__c, To_be_Deleted_Date__c, Request_to_be_Forgotten__c, Double_Opt_in_Reminder_Email_Send_Date__c, Double_Opt_in_Reminder_Send_Date__c, Double_Opt_in_Email_Send_Date__c FROM Account WHERE Id IN: accIdSet]){   
                                                                 
                                  //Check if account ID is not existing within set data
                                  if(!campMemSet.contains(accRec.Id)){
                                      if(accRec.Request_to_be_Forgotten__c == True && accRec.Deletion_Flag__c == False && accRec.Account_Registration_Status__c == 'Deactivated' && accRec.Consent_Status__c == 'Withdrawn'){
                                          accRec.Account_Deletion_Date__c	= date.Today();
                                          accRec.Consent_Withdrawn_Date__c = DateTime.Now();
                                          accRec.Deletion_Flag__c = True;
                                          accRec.Deletion_Reason__c = Label.DelReason_Request_to_be_Forgotten;
                                          accRec.To_be_Deleted_Date__c = date.Today().addDays(Integer.valueOf(settings.Days_for_Request_to_be_Forgotten__c));
                                          accListInsert.add(accRec);
                                         
                                      }else if(accRec.Deletion_Flag__c == False && accRec.Account_Registration_Status__c == 'Deactivated' && accRec.Account_Deletion_Date__c != null && accRec.Consent_Status__c == 'Withdrawn'){
                                          accRec.Deletion_Flag__c = True;
                                          accRec.Deletion_Reason__c = Label.DelReason_Consumer_Delete_Account;
                                          accRec.To_be_Deleted_Date__c = Date.valueOf(accRec.Account_Deletion_Date__c).addDays(Integer.valueOf(settings.Days_for_Consumer_Deletes_Account__c));
                                          accListInsert.add(accRec);
                                         
                                      }else if(accRec.Deletion_Flag__c == False && accRec.Account_Registration_Status__c != 'Active' && accRec.Consent_Status__c == 'Withdrawn' && accRec.Consent_Withdrawn_Date__c != null){
                                          
                                          accRec.Deletion_Flag__c = True;
                                          accRec.Deletion_Reason__c = Label.DelReason_Consent_Withdrawn;
                                          accRec.To_be_Deleted_Date__c = Date.valueOf(accRec.Consent_Withdrawn_Date__c).addDays(Integer.valueOf(settings.Days_for_Consumer_Withdraws__c));
                                          accListInsert.add(accRec); 
                                          
                                      
                                      }
                                  }
                              }
    

        
        //Update Account Records
        if(!accListInsert.isEmpty()){
            Database.update(accListInsert, true);
            
        }
    }
    
    //Method to execute after running batch job
    global void finish(Database.BatchableContext BC){
        
    }
}