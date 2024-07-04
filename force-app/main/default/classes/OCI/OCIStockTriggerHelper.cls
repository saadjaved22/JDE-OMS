public with sharing class OCIStockTriggerHelper {
  public static void handleAfterUpdate(
    List<OCI_Stock__c> newStockItems,
    Map<Id, OCI_Stock__c> oldStockItems
  ) {
    Set<String> locations = new Set<String>();

    for (OCI_Stock__c stockItem : newStockItems) {
      OCI_Stock__c oldStockItem = oldStockItems.get(stockItem.Id);

      if (stockItem.SafetyStockCount__c != oldStockItem.SafetyStockCount__c) {
        locations.add(stockItem.LocExtRef__c);
      }
    }

    if (!locations.isEmpty() && locations.size() < 100) {
      // todo: bulkify for unlikely usecase of updating for more than 100 locations in one go.
      for (String location : locations) {
        OCICommerceAPI.updateSafetyStockToOCI(location);
        OCICommerceAPI.requestRefresh(location);
      }
    }
  }
}
