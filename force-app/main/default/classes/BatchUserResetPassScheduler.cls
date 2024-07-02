global class BatchUserResetPassScheduler implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchUserHardResetPassword usrPswrdRst = new BatchUserHardResetPassword();
        database.executeBatch(usrPswrdRst, 70);
    }
}