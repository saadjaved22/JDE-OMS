@isTest(seeAllData = false)
public class LoyaltyStackTest {
    
    public static EncryptionKey__c encryptionKey = new EncryptionKey__c();
    static List<Loyalty__c> lstloyal;
    
    static {
        encryptionKey = TestDataFactory.setCustomSetting();
        TestDataFactory.setProcessBuilderSettings();
        List<Account> lstacc = TestDataFactory.testAccountData();
        lstloyal = TestDataFactory.testLoyaltyData(lstacc);
    }
    
    @isTest
    static void testLoyaltyInfoisNull(){
        LoyaltyDetails.LoyaltyResponse resp = LoyaltyStack.GetDigitalPointsBalance(null);
        system.assertEquals(Label.ArgumentsMissing, resp.status);
        
        LoyaltyDetails.LoyaltyResponse resp2 = LoyaltyStack.TransactPoints(null);
        system.assertEquals(Label.ArgumentsMissing, resp2.status);
        
        LoyaltyDetails.LoyaltyResponse resp3 = LoyaltyStack.UsePointsForPurchase(null);
        system.assertEquals(Label.ArgumentsMissing, resp3.status);
    }
    
    @isTest
    static void testLoyaltyConsumerNotFound(){
        LoyaltyDetails.LoyaltyInfo loyal = new LoyaltyDetails.LoyaltyInfo();
        loyal.accountNumber = 12300;
        LoyaltyDetails.LoyaltyResponse resp = LoyaltyStack.GetDigitalPointsBalance(loyal);
        //system.assertEquals(Label.ConsumerNotFound, resp.status);
    }
    
    @isTest
    static void testGetDigitalPointsBalanceSuccess(){
        LoyaltyDetails.LoyaltyResponse resp = LoyaltyStack.GetDigitalPointsBalance(loyaltyParams());
        //system.assertEquals(Label.SuccessMessage, resp.status);
    }
    
    @isTest
    static void testTransactPointsSuccess(){
        LoyaltyDetails.LoyaltyInfo loyalInfo = loyaltyParams();
        loyalInfo.mutationType = 'Deposit';
		loyalInfo.regularPointsAmount = 20;
        LoyaltyDetails.LoyaltyResponse resp = LoyaltyStack.TransactPoints(loyalInfo);
        //system.assertEquals(Label.SuccessMessage, resp.status);
        
        loyalInfo = loyaltyParams();
        loyalInfo.mutationType = 'Deposit';
		loyalInfo.regularPointsAmount = 0;
        resp = LoyaltyStack.TransactPoints(loyalInfo);
        //system.assertEquals(Label.SuccessMessage, resp.status);
        
        
        loyalInfo.mutationType = 'Correction';
        loyalInfo.regularPointsAmount = 2;
        LoyaltyDetails.LoyaltyResponse correctionResp = LoyaltyStack.TransactPoints(loyalInfo);
        //system.assertEquals(Label.SuccessMessage, correctionResp.status);
        
        loyalInfo.pointsAmount = 3;
        LoyaltyDetails.LoyaltyResponse resp2 = LoyaltyStack.UsePointsForPurchase(loyalInfo);
    }
    
    
    @isTest
    static void testInsufficientBalanceCorrection(){
        LoyaltyDetails.LoyaltyInfo loyalInfo = loyaltyParams();
        loyalInfo.mutationType = 'Deposit';
		loyalInfo.regularPointsAmount = 2;
        LoyaltyDetails.LoyaltyResponse resp = LoyaltyStack.TransactPoints(loyalInfo);
        //system.assertEquals(Label.SuccessMessage, resp.status);
        
        loyalInfo.mutationType = 'Redeem';
        loyalInfo.regularPointsAmount = 4;
        
        LoyaltyDetails.LoyaltyResponse correctionResp = LoyaltyStack.UsePointsForPurchase(loyalInfo);
        
        Account a = new Account();
        a.LastName = 'Test';
        a.personEmail = 'Test@jde12.com';
        a.External_Id__c = 'Test@jde12.comNLDouwe Egberts';
        a.Brand__c='Douwe Egberts';
        a.Type__c='Loyalty';
        insert a;
        
        Loyalty__c lyl = new Loyalty__c();
        lyl.Loyalty_Consumer__c = a.Id;
        lyl.External_Id__c = 'Test@jde12.comNLDouwe Egberts';
        
        insert lyl;
        
        
        loyalInfo.accountNumber = 1234;
        loyalInfo.referenceID = 'Test Reference';
        loyalInfo.specification = 'Test specification';
        loyalInfo.mutationType = 'Deposit';
		loyalInfo.regularPointsAmount = 2;
        LoyaltyStackHelper.createTransaction(loyalInfo,lyl); 
        
    }
	
    
    @isTest
    static void testTransactionMoreThan50000() {
        ProcessBuilderSettings__c prcSettings = ProcessBuilderSettings__c.getOrgDefaults();
        LoyaltyDetails.LoyaltyInfo loyalInfo = loyaltyParams();
        loyalInfo.regularPointsAmount = 50;
        loyalInfo.mutationType = 'Deposit';
        
        LoyaltyStack.TransactPoints(loyalInfo);
        
        loyalInfo.regularPointsAmount = 50001;
        loyalInfo.mutationType = 'Transfer';
        LoyaltyDetails.LoyaltyResponse resp2 = LoyaltyStack.TransactPoints(loyalInfo);
        //system.assertEquals(Label.ArgumentsMissing, resp2.status);
    }
    
    @isTest
    static void populateValidationErrors() {
        
        LoyaltyDetails.ValidationError loyVal = new LoyaltyDetails.ValidationError();
        List<LoyaltyDetails.ValidationError> lstloyVal = new List<LoyaltyDetails.ValidationError>();
        lstloyVal.add(loyVal);
    }
    @isTest
    static void populateAuthenticationHeader() {
        LoyaltyDetails.AuditHeader loyAuthHdr = new LoyaltyDetails.AuditHeader();
        List<LoyaltyDetails.AuditHeader> lstAuthHdr = new List<LoyaltyDetails.AuditHeader>();
        lstAuthHdr.add(loyAuthHdr);
    }
    
    private static LoyaltyDetails.LoyaltyInfo loyaltyParams(){
        LoyaltyDetails.LoyaltyInfo loyal = new LoyaltyDetails.LoyaltyInfo();
        loyal.accountNumber = Integer.valueOf(lstloyal[0].Name);
        loyal.referenceID = 'SAMPLE-01';
		loyal.specification = 'REF-102';
        return loyal;
    }
}