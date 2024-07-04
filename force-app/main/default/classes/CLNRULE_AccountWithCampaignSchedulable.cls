global class CLNRULE_AccountWithCampaignSchedulable implements Schedulable {
  global void execute(SchedulableContext sc) {
    CLNRULE_AccountWithCampaign b = new CLNRULE_AccountWithCampaign();

    database.executebatch(b, 200);
  }
}
