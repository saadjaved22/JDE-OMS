/* ----------------------------------------------------------------------------------------------
   Name: NewsLetterStack
   Description: 

   Date         Version     Author              Summary of Changes 
   -----------  -------     -----------------   -----------------------------------------
  08-March-2018   1.0       ralph.r.v.gozarin   Intial creation
*/
global class NewsLetterStack {
	
    webservice static NewsLetter.NewsLetterResult GetActiveConsumerNewsletterSubscriptions(NewsLetter.NewsLetterSearch newsLetterInfo) {
       return NewsLetterHelper.GetActiveConsumerNewsletterSubscriptions(newsLetterInfo); 
    } 
    
    webservice static NewsLetter.NewsLetterResult UnsubscribeConsumerFromNewsletter(NewsLetter.NewsLetterSearch newsLetterInfo) {
        return NewsLetterHelper.unsubscribeConsumerFromNewsletter(newsLetterInfo);
    }
    
    webservice static NewsLetter.NewsLetterResult SubscribeConsumerToNewsletter(NewsLetter.NewsLetterSearch newsLetterInfo) {
        return NewsLetterHelper.subscribeConsumerToNewsletter(newsLetterInfo);
    }
}