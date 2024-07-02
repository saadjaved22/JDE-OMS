global class CLNRULE_AccountWithCampaign implements Database.Batchable<SObject>{
    
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
        List<Account> acctScope = new List<Account>([SELECT Id, Deletion_Flag__c, Account_Registration_Status__c, Double_Opt_in_Reminder_Email_Send_Date__c, Double_Opt_in_Reminder_Send_Date__c FROM Account WHERE Id IN: accIdSet]);
        List<CampaignMember> campMemList = [SELECT Id, Contact.AccountId, Campaign.EndDate, Campaign.CreatedDate, Campaign.Id FROM CampaignMember WHERE Contact.AccountId IN: accIdSet AND Campaign.EndDate != null ORDER BY Campaign.EndDate desc LIMIT 1];
        Map<Id, CampaignMember> campMemMap = new Map<Id, CampaignMember>();
        for(CampaignMember campRec : campMemList){
            campMemMap.put(campRec.Contact.AccountId, campRec);  
        }
        List<Account> accListInsert = new List<Account>();
        for(Account accRec : [SELECT Id, Account_Deletion_Date__c,Account_Registration_Status__c, Consent_Status__c, Consent_Withdrawn_Date__c, isHardBounced__pc,
                              Deletion_Flag__c, Deletion_Reason__c, To_be_Deleted_Date__c, Request_to_be_Forgotten__c, Double_Opt_in_Reminder_Email_Send_Date__c, Double_Opt_in_Reminder_Send_Date__c, Double_Opt_in_Email_Send_Date__c FROM Account WHERE Id IN: accIdSet]){   
                                  if(campMemMap.containsKey(accRec.Id) && !campMemMap.IsEmpty()){
                                      CampaignMember campMem = campMemMap.get(accRec.Id);
                                      if(accRec.Deletion_Flag__c == False && accRec.Account_Registration_Status__c != 'Active'  && accRec.Consent_Status__c == 'Withdrawn' && accRec.Consent_Withdrawn_Date__c != null && campMem.Campaign.EndDate < date.today().addMonths(-3)){
                                          accRec.Deletion_Flag__c = True;
                                          accRec.Deletion_Reason__c = Label.DelReason_Consent_Withdrawn;
                                          accRec.To_be_Deleted_Date__c = Date.valueOf(accRec.Consent_Withdrawn_Date__c).addDays(Integer.valueOf(settings.Days_for_Consumer_Deletes_Account__c));
                                          accListInsert.add(accRec);           
                                      }else if(accRec.Request_to_be_Forgotten__c == True && accRec.Deletion_Flag__c == False && accRec.Account_Registration_Status__c == 'Deactivated' && accRec.Consent_Status__c == 'Withdrawn' && campMem.Campaign.EndDate < date.today().addMonths(-1)){
                                          accRec.Deletion_Flag__c = True;
                                          accRec.Deletion_Reason__c = Label.DelReason_Request_to_be_Forgotten;
                                          accRec.To_be_Deleted_Date__c = date.Today().addDays(Integer.valueOf(settings.Days_for_Request_to_be_Forgotten__c));
                                          accListInsert.add(accRec);
                                      }else if(accRec.Deletion_Flag__c == false && accRec.Request_to_be_Forgotten__c == True && accRec.Account_Registration_Status__c != 'Active' && accRec.Consent_Status__c == Null && campMem.Campaign.EndDate < date.today().addMonths(-3)){
                                          accRec.Deletion_Flag__c = true;
                                          accRec.To_be_Deleted_Date__c = date.today().addDays(Integer.valueOf(settings.Days_for_Request_to_be_Forgotten__c));
                                          accRec.Deletion_Reason__c = Label.DelReason_No_Commercial_Consent;
                                          accListInsert.add(accRec);
                                      }else if(accRec.Request_to_be_Forgotten__c == True && accRec.Deletion_Flag__c == False && accRec.Account_Registration_Status__c == 'Deactivated' && accRec.Consent_Status__c == 'Withdrawn' && campMem.Campaign.EndDate < date.today().addMonths(-3)){
                                          accRec.Deletion_Flag__c = True;
                                          accRec.Deletion_Reason__c = Label.DelReason_Request_to_be_Forgotten;
                                          accRec.To_be_Deleted_Date__c = date.Today().addDays(Integer.valueOf(settings.Days_for_Request_to_be_Forgotten__c));
                                          accListInsert.add(accRec);
                                      }
                                  }
                              }
        
        //Update Account Records
        if(!accListInsert.isEmpty()){
            Database.update(accListInsert, false);
        }
    }
    
    //Method to execute after running batch job
    global void finish(Database.BatchableContext BC){
        
    }
}