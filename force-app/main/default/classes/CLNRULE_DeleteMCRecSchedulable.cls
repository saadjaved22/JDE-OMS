/*********************************************************************
Name    :       CLNRULE_DeleteMCRecSchedulable
Date    :       22.Feb.2018
Author  :       Alexander Cruz
Description:    Schedulable class for CLNRULE_DeleteMCRecBatch class that will run every day
History : 
History
    @Fixed by Wunderman Thompson  09/2022
*********************************************************************/

global class CLNRULE_DeleteMCRecSchedulable implements Schedulable {
  global void execute(SchedulableContext sc) {
    CLNRULE_DeleteMCRecBatch b = new CLNRULE_DeleteMCRecBatch();

    database.executebatch(b, 200);
  }
}
