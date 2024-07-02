global class ACN_MatchOrderAndVouchers implements Database.Batchable<sObject>{
    

   global Database.QueryLocator start(Database.BatchableContext BC){
        Cleanup_Rules_Settings__c ol = Cleanup_Rules_Settings__c.getInstance();
		Integer orderlimit = integer.ValueOf(ol.Order_Query_Limit__c);
        return Database.getQueryLocator('SELECT Id, Voucher_External_Ids__c, Start_Date__c From Order__c WHERE Processed_By_Batch__c = False AND External_Id__c != null limit :orderlimit'); 
   }

   global void execute(Database.BatchableContext BC, List<Order__c> scope){
        Map<Id, Order__c> orderMap = new Map<Id, Order__c>(scope);
        List<String> voucherIds = new List<String>();
        Cleanup_Rules_Settings__c vq = Cleanup_Rules_Settings__c.getInstance();
		Integer voucherlimit = integer.ValueOf(vq.Vouchers_Query_Limit__c);
       	Map<String, Order__c> voucherordermap = new Map<String, Order__c>();
       
        system.debug('### Order Map: ' +orderMap);
        
        for(Order__c ord: orderMap.values()){
            if(ord.Voucher_External_Ids__c!=null){
                voucherIds.addAll(ord.Voucher_External_Ids__c.Split(','));
                voucherordermap.put(ord.Voucher_External_Ids__c, ord);
            }
        }
        
        Map<Id, Voucher__c> voucherMap = new Map<Id, Voucher__c>([SELECT Id, External_Id__c, Redemption_Date__c FROM Voucher__c WHERE External_Id__c IN: voucherIds LIMIT 9000]);

        
        Map<Id, Order__c> ordersToUpdate = new Map<Id, Order__c>();
        Map<Id, Voucher__c> vouchersToUpdate = new Map<Id, Voucher__c>();
       
       for(Voucher__c vch: voucherMap.values()){
           if(vch.External_Id__c!=null){
               if(voucherordermap.containsKey(vch.External_Id__c)){
                   Voucher__c vchAdd = new Voucher__c(Id = vch.Id,
                                                      Order__c = voucherordermap.get(vch.External_Id__c).Id,
                                                      Redemption_Date__c = voucherordermap.get(vch.External_Id__c).Start_Date__c);
                   vouchersToUpdate.put(vch.Id, vchAdd);
                   
                   Order__c ordUpt = new Order__c( Id = voucherordermap.get(vch.External_Id__c).Id,
                                                  Processed_By_Batch__c = true);
                   ordersToUpdate.put(voucherordermap.get(vch.External_Id__c).Id, ordUpt);
               }
           }
       }
       
       
        
        if(!vouchersToUpdate.isEmpty()){
            update ordersToUpdate.values();
            update vouchersToUpdate.values();
        }
    }

   global void finish(Database.BatchableContext BC){
       Cleanup_Rules_Settings__c queryLim = Cleanup_Rules_Settings__c.getInstance();
       Integer qlimit = integer.ValueOf(queryLim.Order_Query_Limit__c);
       List<Order__c> orderCount = [SELECT Id, Voucher_External_Ids__c, Start_Date__c From Order__c WHERE Processed_By_Batch__c = False AND External_Id__c != null limit :qlimit];
       if(orderCount.size() > 0){
           ACN_MatchOrderAndVouchers match = new ACN_MatchOrderAndVouchers();
           Database.executeBatch(match,2000);
       }
   }
}