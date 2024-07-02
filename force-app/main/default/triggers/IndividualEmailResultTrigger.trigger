/**********************************************************
** Description: IndividualEmailResultTrigger Trigger
** Author: Anjerico Z. Caburnay
** Date Created 28-12-2017
**History:--------------------------------------------
**********************************************************/

trigger IndividualEmailResultTrigger on et4ae5__IndividualEmailResult__c (before insert, before update, after insert, after update) {
    
    //Get Muting Setting Values from Custom Setting
    TriggerSettings__c ts1 = TriggerSettings__c.getInstance(UserInfo.getProfileId());
    
    //Trigger Muting Setting
    if(ts1.IndividualEmailResultTrigger__c){
        if (Trigger.isBefore){
            if(Trigger.isInsert){
                IndividualEmailResultTriggerHandler.onBeforeInsert(trigger.new);
            }
            
            if(Trigger.isUpdate){
                IndividualEmailResultTriggerHandler.onBeforeUpdate(trigger.new);
            }
        }
        
        if (Trigger.isAfter){
            if(Trigger.isInsert){
                IndividualEmailResultTriggerHandler.onAfterInsert(trigger.new);
            }
            
            if(Trigger.isUpdate){
                IndividualEmailResultTriggerHandler.onAfterUpdate(trigger.new);
            }
        }
    }
    

}