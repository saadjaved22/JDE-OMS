/* ----------------------------------------------------------------------------------------------
   Name: NewsLetter
   Description: 

   Date         Version     Author              Summary of Changes 
   -----------  -------     -----------------   -----------------------------------------
  08-March-2018   1.0       ralph.r.v.gozarin   Intial creation
*/
global class NewsLetter {
	
    global class NewsLetterRecord {
        webservice String NewsletterName;
        webservice Integer NewsletterID;
        webservice Integer ConsumerID;
        webservice Integer SourceID;
        webservice Integer CampaignID;
        webservice DateTime SubscriptionDate;
        webservice DateTime UnsubscribeDate;
        webservice String UnsubscriptionReason;
        webservice String UnsubscriptionReasonEx;
        webservice String ExtendedReason;
		webservice String Reason;
        webservice Boolean IsDeleted;
        
        global NewsLetterRecord(){
            
        }
    }
    
    global class NewsLetterResult {
        webservice String status;
       	webservice List<ValidationError> ArrayOfValidationError;
        webservice List<NewsLetterRecord> lstNewsLetterRecord; 
        
        global NewsLetterResult(){
            
        }
    }
    
    global class NewsLetterSearch {
        webservice String userName;
        webservice Integer newsletterId;
        webservice String status;
        webservice String extendedStatus;
        webservice String campaignName;
        webservice AuditHeader audit;
        
        global NewsLetterSearch(){
            
        }
    }
    
    global class ValidationError{
        webservice String Key;
        webservice String Message;
        webservice String Tag;
        
        global ValidationError(){
            
        }
    }
    
    global class AuditHeader{
        webservice String cashiername;
        webservice String shopnr;
        webservice String shopname;
        
        global AuditHeader(){
            
        }
    }
}