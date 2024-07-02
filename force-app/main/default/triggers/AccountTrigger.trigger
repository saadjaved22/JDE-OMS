/**********************************************************
** Description: Account Trigger
** Author: Anjerico Z. Caburnay
** Date Created 06-20-2017
**History:--------------------------------------------
**********************************************************/

trigger AccountTrigger on Account (before insert, before update, after insert, after update, before delete) {
    
    //Get Muting Setting Values from Custom Setting
    TriggerSettings__c ts1 = TriggerSettings__c.getInstance(UserInfo.getProfileId());
    
    //Trigger Muting Setting
    if(ts1.PersonAccountTrigger__c){
        if (Trigger.isBefore){
            if(Trigger.isInsert){
                AccountTriggerHandler.onBeforeInsert(trigger.new);
            }
            
            if(Trigger.isDelete){
                AccountTriggerHandler.onBeforeDelete(trigger.old);
            }
            
            if(Trigger.isUpdate){
                AccountTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
            }
        }
        if (Trigger.isAfter){
            if(trigger.isInsert){
                AccountTriggerHandler.onAfterInsert(trigger.new, trigger.oldMap, trigger.newMap);
            }
            if(Trigger.isUpdate){
                AccountTriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap, trigger.newMap);
            }
        }
    }
    

}