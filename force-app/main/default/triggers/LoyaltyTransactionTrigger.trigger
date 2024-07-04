trigger LoyaltyTransactionTrigger on Loyalty_Transaction__c(
  before insert,
  before update,
  after insert
) {
  //Get Muting Setting Values from Custom Setting
  TriggerSettings__c ts1 = TriggerSettings__c.getInstance(
    UserInfo.getProfileId()
  );

  if (ts1.LoyaltyTransactionTrigger__c) {
    if (Trigger.isBefore) {
      if (Trigger.isInsert) {
        LoyaltyTransactionTriggerHandler.onBeforeInsert(Trigger.new);
      }

      if (Trigger.isUpdate) {
        //LoyaltyTransactionTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
      }
    }
    if (Trigger.isAfter) {
      if (Trigger.isInsert) {
        LoyaltyTransactionTriggerHandler.onAfterInsert(Trigger.new);
      }
    }
  }
}
