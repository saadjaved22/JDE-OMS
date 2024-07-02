/*********************************************************************
Name    :       AccountHardResetPassword 
Date    :       13 October 2020
Author  :       Anlene Sanmocte
Description:    To be able hard reset user's password
History :       
*********************************************************************/

global class AccountHardResetPassword implements Database.Batchable<SObject>{
    
    //constructor
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, ProfileId, Hard_Reset_Password__c, LastPasswordChangeDate FROM User WHERE Hard_Reset_Password__c = true' + (Test.isRunningTest()? ' LIMIT 70' : '' );
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope){
        Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
        List<User> usersToBeUpdated = new List<User>();
        Set<String> usrIdSet = new Set<String>();
        for(User usrRec: scope){
            usrIdSet.add(usrRec.Id);
        }
        
        DateTime dateToday = Date.today();
        
        List<User> usrIdList = new List<User>( );
        for(User usrRec : [SELECT Id, ProfileId, Hard_Reset_Password__c, LastPasswordChangeDate FROM User WHERE Id IN: usrIdset AND LastPasswordChangeDate <: dateToday LIMIT 70]){
        	if(usrRec.Hard_Reset_Password__c == true && usrRec.ProfileId == '00e0Y000000RZR0QAO'){
                System.resetPassword(usrRec.Id, false);
                usrIdList.add(usrRec);
            }
        }
        
        if(!usrIdList.IsEmpty()){
            Database.update(usrIdList, true);
            usrIdList.clear();
        }
        
        for(User usrRec2 : [SELECT Id, ProfileId, Hard_Reset_Password__c, LastPasswordChangeDate FROM User WHERE ID IN: usrIdset AND LastPasswordChangeDate >: dateToday LIMIT 70]){
        	if(usrRec2.Hard_Reset_Password__c == true && usrRec2.ProfileId == '00e0Y000000RZR0QAO'){
                System.debug('To change hard reset password');
            	usrRec2.Hard_Reset_Password__c = false;
                usrIdList.add(usrRec2);
            }
        }
        	
        if(!usrIdList.IsEmpty()){
            Database.update(usrIdList, true);
            usrIdList.clear();
        }
    }
    
    global void finish(Database.BatchableContext BC ){
    }
    
}