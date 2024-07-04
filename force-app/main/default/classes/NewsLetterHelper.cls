/* ----------------------------------------------------------------------------------------------
   Name: NewsLetterHelper
   Description: 

   Date         Version     Author              Summary of Changes 
   -----------  -------     -----------------   -----------------------------------------
  08-March-2018   1.0       ralph.r.v.gozarin   Intial creation
*/
public class NewsLetterHelper {
  public static NewsLetter.NewsLetterResult getActiveConsumerNewsletterSubscriptions(
    NewsLetter.NewsLetterSearch newsInfo
  ) {
    NewsLetter.NewsLetterResult resp = new NewsLetter.NewsLetterResult();
    NewsLetterService.NewsLetterWrapper newsLtrArgmsResp = new NewsLetterService.NewsLetterWrapper();

    resp.status = Label.SuccessMessage;
    resp.ArrayOfValidationError = null;
    resp.lstNewsLetterRecord = null;

    return resp;
  }

  public static NewsLetter.NewsLetterResult UnsubscribeConsumerFromNewsletter(
    NewsLetter.NewsLetterSearch newsInfo
  ) {
    NewsLetter.NewsLetterResult resp = new NewsLetter.NewsLetterResult();
    NewsLetterService.NewsLetterWrapper newsLtrArgmsResp = new NewsLetterService.NewsLetterWrapper();

    resp.status = Label.SuccessMessage;
    resp.ArrayOfValidationError = null;
    resp.lstNewsLetterRecord = null;

    return resp;
  }

  public static NewsLetter.NewsLetterResult SubscribeConsumerToNewsletter(
    NewsLetter.NewsLetterSearch newsInfo
  ) {
    NewsLetter.NewsLetterResult resp = new NewsLetter.NewsLetterResult();
    NewsLetterService.NewsLetterWrapper newsLtrArgmsResp = new NewsLetterService.NewsLetterWrapper();

    resp.status = Label.SuccessMessage;
    resp.ArrayOfValidationError = null;
    resp.lstNewsLetterRecord = null;

    return resp;
  }
}
