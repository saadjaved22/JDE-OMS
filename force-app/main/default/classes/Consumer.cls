global class Consumer{

 global class ConsumerRecord {
        webservice Integer ID;
        webservice String LastName;
        webservice String FirstName;
        webservice String MiddleName;
        webservice String Street;
        webservice Integer HouseNumber;
        webservice String HouseLetters;
        webservice String City;
        webservice String PostCode;
        webservice String Country;
        webservice String Email;
        webservice Boolean IsLoyaltyMember;
        webservice Boolean HasActiveLoyaltyCard;
        webservice Integer AccountNumber;
        webservice String Initials;
        webservice String Title;
        webservice String Gender;
        webservice String BirthDate;
        webservice String Region;
        webservice String Telephone;
        webservice String Mobile;
     
        global ConsumerRecord(){
            
        }
     

  }
    
    global class ConsumerInfo{
        webservice Integer ID;
        webservice String LastName;
        webservice String FirstName;
        webservice String MiddleName;
        webservice String Street;
        webservice Integer HouseNumber;
        webservice String HouseLetters;
        webservice String City;
        webservice String PostCode;
        webservice String Country;
        webservice String Email;
        webservice Boolean IsLoyaltyMember;
        webservice Boolean HasActiveLoyaltyCard;
        webservice Integer AccountNumber;
        webservice String Initials;
        webservice String Title;
        webservice String Gender;
        webservice String BirthDate;
        webservice String Region;
        webservice String Telephone;
        webservice String Mobile;
        webservice AuditHeader audit;
        
        global ConsumerInfo(){
            
        }

  }
      global class ConsumerResult{
        webservice string status;
       	webservice List<ValidationError> ArrayOfValidationError;
        webservice List<ConsumerRecord> listConsumerRecord;
        
        global ConsumerResult(){
            
        }
     }
  
     global class ConsumerSearch{
        webservice string LastName;
        webservice string PostCode;
        webservice Integer HouseNumber;
        webservice String emailPart;
        webservice string CardNumber;
        webservice Integer consumerId;
        webservice AuditHeader audit;
         
        global ConsumerSearch(){
            
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