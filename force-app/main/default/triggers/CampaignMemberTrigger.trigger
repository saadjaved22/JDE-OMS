trigger CampaignMemberTrigger on CampaignMember(before insert, before update) {
  //Get Muting Setting Values from Custom Setting
  TriggerSettings__c ts1 = TriggerSettings__c.getInstance(
    UserInfo.getProfileId()
  );

  if (ts1.CampaignMemberTrigger__c) {
    System.debug('Trigger Warning 2');
    if (Trigger.isBefore) {
      if (Trigger.isInsert) {
        CampaignMemberTriggerHandler.onBeforeInsert(Trigger.new);
      }

      if (Trigger.isUpdate) {
        CampaignMemberTriggerHandler.onBeforeUpdate(Trigger.new);
      }
    }
  }
}
