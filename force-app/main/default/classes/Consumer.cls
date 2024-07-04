global class Consumer {
  global class ConsumerRecord {
    webService Integer ID;
    webService String LastName;
    webService String FirstName;
    webService String MiddleName;
    webService String Street;
    webService Integer HouseNumber;
    webService String HouseLetters;
    webService String City;
    webService String PostCode;
    webService String Country;
    webService String Email;
    webService Boolean IsLoyaltyMember;
    webService Boolean HasActiveLoyaltyCard;
    webService Integer AccountNumber;
    webService String Initials;
    webService String Title;
    webService String Gender;
    webService String BirthDate;
    webService String Region;
    webService String Telephone;
    webService String Mobile;

    global ConsumerRecord() {
    }
  }

  global class ConsumerInfo {
    webService Integer ID;
    webService String LastName;
    webService String FirstName;
    webService String MiddleName;
    webService String Street;
    webService Integer HouseNumber;
    webService String HouseLetters;
    webService String City;
    webService String PostCode;
    webService String Country;
    webService String Email;
    webService Boolean IsLoyaltyMember;
    webService Boolean HasActiveLoyaltyCard;
    webService Integer AccountNumber;
    webService String Initials;
    webService String Title;
    webService String Gender;
    webService String BirthDate;
    webService String Region;
    webService String Telephone;
    webService String Mobile;
    webService AuditHeader audit;

    global ConsumerInfo() {
    }
  }
  global class ConsumerResult {
    webService string status;
    webService List<ValidationError> ArrayOfValidationError;
    webService List<ConsumerRecord> listConsumerRecord;

    global ConsumerResult() {
    }
  }

  global class ConsumerSearch {
    webService string LastName;
    webService string PostCode;
    webService Integer HouseNumber;
    webService String emailPart;
    webService string CardNumber;
    webService Integer consumerId;
    webService AuditHeader audit;

    global ConsumerSearch() {
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
