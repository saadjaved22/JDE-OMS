trigger VoucherTrigger on Voucher__c(
  before insert,
  before update,
  after insert
) {
  //Get Muting Setting Values from Custom Setting
  TriggerSettings__c ts1 = TriggerSettings__c.getInstance(
    UserInfo.getProfileId()
  );

  if (ts1.VoucherTrigger__c) {
    if (Trigger.isBefore) {
      if (Trigger.isInsert) {
        VoucherTriggerHandler.onBeforeInsert(Trigger.new);
      }

      if (Trigger.isUpdate) {
        //VoucherTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
      }
    }
    if (Trigger.isAfter) {
      if (Trigger.isInsert) {
        VoucherTriggerHandler.onAfterInsert(Trigger.new);
      }
    }
  }
}
