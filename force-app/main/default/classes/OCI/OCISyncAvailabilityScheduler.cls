global with sharing class OCISyncAvailabilityScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    OCICommerceAPI.getAvailabilityUpdate();
  }
}
