/**********************************************************
 ** Description: Account Trigger
 ** Author: Anjerico Z. Caburnay
 ** Date Created 06-20-2017
 **History:--------------------------------------------
 **********************************************************/

trigger AccountTrigger on Account(
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
  //Get Muting Setting Values from Custom Setting
  TriggerSettings__c ts1 = TriggerSettings__c.getInstance(
    UserInfo.getProfileId()
  );

  //Trigger Muting Setting
  if (ts1.PersonAccountTrigger__c) {
    if (Trigger.isBefore) {
      if (Trigger.isInsert) {
        AccountTriggerHandler.onBeforeInsert(Trigger.new);
      }

      if (Trigger.isDelete) {
        AccountTriggerHandler.onBeforeDelete(Trigger.old);
      }

      if (Trigger.isUpdate) {
        AccountTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
      }
    }
    if (Trigger.isAfter) {
      if (Trigger.isInsert) {
        AccountTriggerHandler.onAfterInsert(
          Trigger.new,
          Trigger.oldMap,
          Trigger.newMap
        );
      }
      if (Trigger.isUpdate) {
        AccountTriggerHandler.onAfterUpdate(
          Trigger.new,
          Trigger.oldMap,
          Trigger.newMap
        );
      }
    }
  }

}
