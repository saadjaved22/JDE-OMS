/* ----------------------------------------------------------------------------------------------
   Name: GetConsumerDetailsStackTest
   Description: 

   Date         Version     Author              Summary of Changes 
   -----------  -------     -----------------   -----------------------------------------
   14-March-2018   1.0       ralph.r.v.gozarin   Intial creation
*/

@IsTest(SeeAllData = false)
public class GetConsumerDetailsStackTest {
	
    @isTest
    static void testArgumentAreMissing() {
        Consumer.ConsumerSearch cs = new Consumer.ConsumerSearch();
        cs.ConsumerId = 12340005;
		
        //system.debug('1');
		Consumer.ConsumerResult response = GetConsumerDetailsStack.SearchConsumers(null);
        System.assertEquals(Label.ArgumentsMissing, response.status);
        
        //system.debug('2');
        Consumer.ConsumerResult response2 = GetConsumerDetailsStack.SearchConsumers(cs);        
        System.assertEquals(Label.ConsumerNotFound, response2.status);
        
        //system.debug('3');
        cs.EmailPart = 'test.email@\'ii \'OR';
        Consumer.ConsumerResult response3 = GetConsumerDetailsStack.SearchConsumers(cs);       
        //system.debug(response3.status);
        System.assertNotEquals(null, response3.status);
    }
    
    @isTest
    static void testSearchConsumers() {
        Consumer.ConsumerSearch cs = new Consumer.ConsumerSearch();
        cs.LastName = 'Gozarin';
        cs.HouseNumber = 22;
        cs.PostCode = '12365';
        System.assertNotEquals(null, GetConsumerDetailsStack.SearchConsumers(cs));
    }
    
    @isTest
    static void testGetLoyaltyConsumerByConsumerId() {
        Consumer.ConsumerSearch cs = new Consumer.ConsumerSearch();
        cs.ConsumerId = 12345;
        System.assertNotEquals(null, GetConsumerDetailsStack.GetLoyaltyConsumerByConsumerId(cs));
    }
    
    @isTest
    static void testGetLoyaltyConsumerByCardNumber() {
        Consumer.ConsumerSearch cs = new Consumer.ConsumerSearch();
        cs.CardNumber = '12345';
        System.assertNotEquals(null, GetConsumerDetailsStack.GetLoyaltyConsumerByCardNumber(cs));
    }
    
    @isTest
    static void testSearchConsumersByEmailPart() {
        Consumer.ConsumerSearch cs = new Consumer.ConsumerSearch();
        cs.EmailPart = 'ralph.r.v.gozarin@accenture.com';
        System.assertNotEquals(null, GetConsumerDetailsStack.SearchConsumersByEmailPart(cs));
    }
    
    @isTest
    static void testSearchConsumersByUserData() {
        Consumer.ConsumerSearch cs = new Consumer.ConsumerSearch();
        cs.EmailPart = 'ralph.r.v.gozarin@accenture.com';
        System.assertNotEquals(null, GetConsumerDetailsStack.SearchConsumersByUserData(cs));
    }
}