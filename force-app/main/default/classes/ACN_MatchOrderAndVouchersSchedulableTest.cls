/*********************************************************************
Name    :       ACN_MatchOrderAndVouchersSchedulableTest
Date    :       03 August 2017
Author  :       Anjerico Caburnay
Description:    Test class for ACN_MatchOrderAndVouchersSchedulable Batch Schedulable
History : 
*********************************************************************/

@isTest
private class ACN_MatchOrderAndVouchersSchedulableTest {

	private static testMethod void testScheduler() {
        Test.StartTest();
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
                Order__c ord = new Order__c(Name='test order '+y,Customer__c=testAsc.Id,Processed_By_Batch__c=false,Voucher_External_Ids__c='1000'+y,Start_Date__c=Date.today());
                orderList.add(ord);
            }
            insert orderList;
            
            ACN_MatchOrderAndVouchersSchedulable sh1 = new ACN_MatchOrderAndVouchersSchedulable();      
            String sch = '0 0 15 * * ?';
            system.schedule('Test run schedulable', sch, sh1);
        Test.stopTest();
	}

}