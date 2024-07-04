trigger OCI_Stock_Trigger on OCI_Stock__c(after update) {
  if (Trigger.isAfter && Trigger.isUpdate && !System.isFuture()) {
    OCIStockTriggerHelper.handleAfterUpdate(Trigger.new, Trigger.oldMap);
  }
}
