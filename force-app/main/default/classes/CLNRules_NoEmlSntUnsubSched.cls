global  class CLNRules_NoEmlSntUnsubSched   implements Schedulable{
    global void execute(SchedulableContext sc) {
        CLNRules_NoEmailSentUnsubscribe testBatch = new CLNRules_NoEmailSentUnsubscribe();
        DataBase.executeBatch(testBatch);
    }
}