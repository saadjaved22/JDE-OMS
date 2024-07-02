/*
 * AUTHOR: Accenture
 * DESCRIPTION: This method hold the inner class and their attributes.
*/
global class LoyaltyDetails {
    /*This class hold attributes of response type*/
    global class LoyaltyResponse{
        webservice string Status;
		webservice Long Balance;
	    webservice Long RegularPointsUsed;
    	webservice Long BonusPointsUsed;
       	webservice List<ValidationError> ArrayOfValidationError;
        
        global LoyaltyResponse(){
            
        }
    }
    /*This class hold attributes of request type*/
    global class LoyaltyInfo{
        webservice  Integer accountNumber;
        webservice  string mutationType;
        webservice  string referenceID;
        webservice  string specification;
        webservice  Integer regularPointsAmount;
        webservice  Integer bonusPointsAmount;
        webservice Integer pointsAmount;
        webservice AuditHeader audit;
        
        global LoyaltyInfo(){
            
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