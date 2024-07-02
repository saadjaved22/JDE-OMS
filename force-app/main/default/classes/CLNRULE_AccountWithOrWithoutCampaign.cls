/************************************************************************************************************************************************** 
@author: Wunderman Thompson :  Abderrezak FENOUCHE 
*    @date: 09/2022
*    @description: Batch Class result merging the CLNRULE_AccountWithCampaign & CLNRULE_AccountWithoutCampaign and using the relation CampaignMembers__r
        this batch requires the field customer__c in CampaignMembers object to be populated

**************************************************************************************************************************************************/
global without sharing class CLNRULE_AccountWithOrWithoutCampaign implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
        String queryLimit = settings.Query_Limit__c != Null ? settings.Query_Limit__c : '';
        return Database.getQueryLocator('SELECT Id, Type__c, IsCustomerPortal,CreatedDate, PersonContactId, Deletion_Flag__c, '+
                                        'Consent_Status__c, Consent_Withdrawn_Date__c, isHardBounced__pc, Deletion_Reason__c, To_be_Deleted_Date__c, '+
                                        'Request_to_be_Forgotten__c, Account_Deletion_Date__c, '+
                                        '(SELECT Id, Campaign.EndDate FROM  CampaignMembers__r ORDER BY Campaign.EndDate DESC LIMIT 1) '+
                                        'FROM Account WHERE  Deletion_Flag__c = FALSE '+
                                        'AND (Consent_Status__c =\'Withdrawn\' OR Consent_Status__c = NULL)'+ 
                                        'AND Type__c != \'Loyalty\' AND Type__c != \'Registered\' AND IsCustomerPortal = false '+queryLimit);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope){
        Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
        List<Account> accountsToBeUpdated = new List<Account>();
        for(Account acc : scope){
            /***********  Accounts with Campaign ************/
            if(acc.CampaignMembers__r.size() > 0){
                Date LastCampaignEndDate = acc.CampaignMembers__r[0].Campaign.EndDate;
                Date last3Months = Date.today().addMonths(-3);
                
                if(acc.Request_to_be_Forgotten__c == True  ){
                    /*****Updated****/
                    // Request_to_be_Forgotten To be deleted: immediately after request to be forgotten (max 1 day delay)
                    acc.Deletion_Flag__c = True;
                    acc.Deletion_Reason__c = Label.DelReason_Request_to_be_Forgotten;
                    acc.To_be_Deleted_Date__c = date.Today().addDays(Integer.valueOf(settings.Days_for_Request_to_be_Forgotten__c));
                    acc.IsCustomerPortal = false;
                    accountsToBeUpdated.add(acc);
                }else if( acc.Consent_Status__c == 'Withdrawn' && acc.Consent_Withdrawn_Date__c != null && LastCampaignEndDate <last3Months ){
                    /*****Updated****/
                    // Commercial consent withdrawn  ( no inactive DTC/DE/MDC account) 
                    // -> To be deleted: 1 day delay max
                    acc.Deletion_Flag__c = True;  
                    acc.Deletion_Reason__c = Label.DelReason_Consent_Withdrawn;
                    acc.To_be_Deleted_Date__c = Date.valueOf(acc.Consent_Withdrawn_Date__c).addDays(Integer.valueOf(settings.Days_for_Consumer_Withdraws__c));
                    accountsToBeUpdated.add(acc);           
                }else if(acc.Consent_Status__c == Null && LastCampaignEndDate < last3Months ){
                    /*****Updated ( no inactive DTC/DE/MDC account)****/
                    // No commercial consent – campaign participation -> To be deleted: after 3 months after campaign end date. 
                    acc.Deletion_Flag__c = true;
                    acc.To_be_Deleted_Date__c = date.today();
                    acc.Deletion_Reason__c = Label.DelReason_No_Commercial_Consent;
                    accountsToBeUpdated.add(acc);
                }
                /* ******** to be checked againg with Miguel */
                /* else if(acc.Consent_Status__c == Null && LastCampaignEndDate < last3Months
                            && (acc.Type__c == 'Loyalty' || acc.Type__c == 'Registered' || acc.IsCustomerPortal == true)){
                    // No commercial consent : DE /MDC or DTC
                    acc.Consent_Status__c = 'Expired';
                    accountsToBeUpdated.add(acc);
                } */
            }else{
                /***********  Accounts without Campaign ************/
                if(acc.Request_to_be_Forgotten__c == True ){
                    /*****Updated****/
                    //Request_to_be_Forgotten To be deleted: immediately after request to be forgotten (max 1 day delay)
                    acc.Account_Deletion_Date__c	= date.Today();
                    acc.Consent_Withdrawn_Date__c = DateTime.Now();
                    acc.Deletion_Flag__c = True;
                    acc.Deletion_Reason__c = Label.DelReason_Request_to_be_Forgotten;
                    acc.To_be_Deleted_Date__c = date.Today().addDays(Integer.valueOf(settings.Days_for_Request_to_be_Forgotten__c));
                    acc.IsCustomerPortal = false;
                    accountsToBeUpdated.add(acc);
                }else if(acc.Consent_Status__c == 'Withdrawn' && acc.Consent_Withdrawn_Date__c != null){
                    /*****Updated****/
                    //Commercial consent withdrawn (no or inactive DTC account) 
                    // -> To be deleted: immediately after withdrawal consent (max 1 day delay)  
                    acc.Deletion_Flag__c = True;
                    acc.Deletion_Reason__c = Label.DelReason_Consent_Withdrawn;
                    acc.To_be_Deleted_Date__c = Date.valueOf(acc.Consent_Withdrawn_Date__c).addDays(Integer.valueOf(settings.Days_for_Consumer_Withdraws__c));
                    accountsToBeUpdated.add(acc);
                }else if(acc.Consent_Status__c == Null && acc.CreatedDate < Date.today() ){
                    /*****Updated****/
                    // No commercial consent NON DTC/portal users – campaign participation -> To be deleted: after 3 months after campaign end date. 
                    acc.Deletion_Flag__c = true;
                    acc.To_be_Deleted_Date__c = date.today();
                    acc.Deletion_Reason__c = Label.DelReason_No_Commercial_Consent;
                    accountsToBeUpdated.add(acc);
                }
                /* ******** to be checked againg with Miguel */
                /* else if( acc.Consent_Status__c == Null && acc.CreatedDate < Date.today()
                        && (acc.Type__c == 'Loyalty' || acc.Type__c == 'Registered' || acc.IsCustomerPortal == true)){
                    // No commercial consent : DE /MDC or DTC
                    acc.Consent_Status__c = 'Expired';
                    accountsToBeUpdated.add(acc);
                } */
            }
        }

        System.debug('**accountsToBeUpdated:'+ accountsToBeUpdated);
        
        //Update Account Records
        if(!accountsToBeUpdated.isEmpty()){
            System.debug('**Updating Records**');
            Database.update(accountsToBeUpdated, false);
            System.debug('Update Sucessful: ' + accountsToBeUpdated);  
        }
    }

    global void finish(Database.BatchableContext BC){
        
    }
}