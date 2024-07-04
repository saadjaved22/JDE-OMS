/**********************************************************
 ** Description: Brewer_Registration__c Trigger
 ** Author: Anjerico Z. Caburnay
 ** Date Created 07-12-2017
 **History:--------------------------------------------
 **********************************************************/

trigger BrewerRegistrationTrigger on Brewer_Registration__c(
  before insert,
  before update,
  after insert
) {
  //Get Muting Setting Values from Custom Setting
  TriggerSettings__c ts1 = TriggerSettings__c.getInstance(
    UserInfo.getProfileId()
  );

  //Trigger Muting Setting
  if (ts1.BrewerRegistrationTrigger__c) {
    if (Trigger.isBefore) {
      if (Trigger.isInsert) {
        BrewerRegistrationTriggerHandler.onBeforeInsert(Trigger.new);
      }

      if (Trigger.isUpdate) {
        //BrewerRegistrationTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
      }
    }
    if (Trigger.isAfter) {
      if (Trigger.isInsert) {
        BrewerRegistrationTriggerHandler.onAfterInsert(Trigger.new);
      }
    }
  }
}
