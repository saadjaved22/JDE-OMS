trigger ProcessExceptionTrigger on PRocessException(after insert) {
  // todo if more complexity is added: create trigger setting & handler
  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      for (ProcessException pe : Trigger.new) {
        Splunk splunk;
        if (pe.Shipment__c != null) {
          splunk = new Splunk(
            'Process_Exception',
            pe.Shipment__c,
            pe.id,
            pe.ProcessExceptionNumber,
            pe.TransactionId__c
          );
        } else {
          splunk = new Splunk(
            'Process_Exception',
            pe.AttachedToId,
            pe.id,
            pe.ProcessExceptionNumber,
            pe.TransactionId__c
          );
        }
        System.enqueueJob(splunk);
      }
    }
  }
}
