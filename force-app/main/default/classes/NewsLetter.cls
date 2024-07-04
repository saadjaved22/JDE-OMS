/* ----------------------------------------------------------------------------------------------
   Name: NewsLetter
   Description: 

   Date         Version     Author              Summary of Changes 
   -----------  -------     -----------------   -----------------------------------------
  08-March-2018   1.0       ralph.r.v.gozarin   Intial creation
*/
global class NewsLetter {
  global class NewsLetterRecord {
    webService String NewsletterName;
    webService Integer NewsletterID;
    webService Integer ConsumerID;
    webService Integer SourceID;
    webService Integer CampaignID;
    webService DateTime SubscriptionDate;
    webService DateTime UnsubscribeDate;
    webService String UnsubscriptionReason;
    webService String UnsubscriptionReasonEx;
    webService String ExtendedReason;
    webService String Reason;
    webService Boolean IsDeleted;

    global NewsLetterRecord() {
    }
  }

  global class NewsLetterResult {
    webService String status;
    webService List<ValidationError> ArrayOfValidationError;
    webService List<NewsLetterRecord> lstNewsLetterRecord;

    global NewsLetterResult() {
    }
  }

  global class NewsLetterSearch {
    webService String userName;
    webService Integer newsletterId;
    webService String status;
    webService String extendedStatus;
    webService String campaignName;
    webService AuditHeader audit;

    global NewsLetterSearch() {
    }
  }

  global class ValidationError {
    webService String Key;
    webService String Message;
    webService String Tag;

    global ValidationError() {
    }
  }

  global class AuditHeader {
    webService String cashiername;
    webService String shopnr;
    webService String shopname;

    global AuditHeader() {
    }
  }
}
