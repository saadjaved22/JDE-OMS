@isTest
private class ACN_MatchOrderAndVouchersTest {
    
    private static testMethod void runBatch() {
        Test.startTest();
        Cleanup_Rules_Settings__c vq = new Cleanup_Rules_Settings__c();
        vq.Vouchers_Query_Limit__c = '5000';
        vq.Order_Query_Limit__c = '5000';
        insert vq;
        
        List<Voucher__c> voucherList = new List<Voucher__c>();
        for(integer x=0;x<=105;x++){
            Voucher__c vouch = new Voucher__c(Name='Test Vouncher '+x,External_Id__c='1000'+x,Redemption_Date__c=Date.today());
            voucherList.add(vouch);
        }
        insert voucherList;
        
        Account testAsc = new Account(LastName='test Account');
        insert testAsc;
        
        List<Order__c> orderList = new List<Order__c>();
        for(integer y=0;y<=5;y++){
            Order__c ord = new Order__c(Name='test order '+y,Customer__c=testAsc.Id,Processed_By_Batch__c=false,Voucher_External_Ids__c='1000'+y,Start_Date__c=Date.today(),External_Id__c='123123'+y);
            orderList.add(ord);
        }
        insert orderList;
        
        system.debug('### Voucher__c: ' + voucherList);
        system.debug('### Order__c: ' + orderList);
        
        Integer qlimit = integer.ValueOf(vq.Order_Query_Limit__c);
        
        List<Order__c> orderCount = [SELECT Id, Voucher_External_Ids__c, Start_Date__c From Order__c WHERE Processed_By_Batch__c = False AND External_Id__c !=null limit :qlimit];
        if(orderCount.size() > 0){
            ACN_MatchOrderAndVouchers runBatch = new ACN_MatchOrderAndVouchers();
            Database.executeBatch(runBatch,2000);
            Test.stopTest();
        }
        
    }
}