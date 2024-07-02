/* ----------------------------------------------------------------------------------------------
   Name: NewsLetterStackTest
   Description: 

   Date         Version     Author              Summary of Changes 
   -----------  -------     -----------------   -----------------------------------------
   15-March-2018   1.0       ralph.r.v.gozarin   Intial creation
*/

@isTest
public class NewsLetterStackTest {
	
    static {
    	List<Account> lstacc = TestDataFactory.testAccountData();
        List<Loyalty__c> lstloyal = TestDataFactory.testLoyaltyData(lstacc);
        TestDataFactory.setProcessBuilderSettings();
    }
     
   @isTest
    static void testNewsLetterRecord(){
        
        NewsLetter.NewsLetterRecord newsLtrRecord = new NewsLetter.NewsLetterRecord();
        NewsLetter.NewsLetterResult newsLtrRes = new NewsLetter.NewsLetterResult();
        NewsLetter.ValidationError newlValErr = new NewsLetter.ValidationError();
        NewsLetter.AuditHeader newlAudHdr = new NewsLetter.AuditHeader();
        
    }
    
    @isTest
    static void testGetActiveConsumerNewsletterSubscriptions() {
        NewsLetter.NewsLetterSearch newsLetterInfo = new NewsLetter.NewsLetterSearch();
        newsLetterInfo.userName = 'jde4@douweEgberts.com';	
        NewsLetter.NewsLetterResult response = NewsLetterStack.GetActiveConsumerNewsletterSubscriptions(newsLetterInfo);
        system.assertEquals(Label.SuccessMessage, response.status);
    }
    
    @isTest
    static void testUnsubscribeConsumerFromNewsletter() {
        NewsLetter.NewsLetterSearch newsLetterInfo = new NewsLetter.NewsLetterSearch();
        newsLetterInfo.newsletterId = 3;
        newsLetterInfo.userName = 'jde4@douweEgberts.com';
        NewsLetter.NewsLetterResult response = NewsLetterStack.UnsubscribeConsumerFromNewsletter(newsLetterInfo);
        system.assertEquals(Label.SuccessMessage, response.status);
    }
    
    @isTest
    static void testSubscribeConsumerToNewsletter() {
        NewsLetter.NewsLetterSearch newsLetterInfo = new NewsLetter.NewsLetterSearch();
        newsLetterInfo.newsletterId = 3;
        newsLetterInfo.userName = 'jde4@douweEgberts.com';
        newsLetterInfo.campaignName = 'anyName';
        NewsLetter.NewsLetterResult response = NewsLetterStack.SubscribeConsumerToNewsletter(newsLetterInfo);
        system.assertEquals(Label.SuccessMessage, response.status);
    }
    
}