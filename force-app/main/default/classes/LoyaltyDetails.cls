/*
 * AUTHOR: Accenture
 * DESCRIPTION: This method hold the inner class and their attributes.
 */
global class LoyaltyDetails {
  /*This class hold attributes of response type*/
  global class LoyaltyResponse {
    webService string Status;
    webService Long Balance;
    webService Long RegularPointsUsed;
    webService Long BonusPointsUsed;
    webService List<ValidationError> ArrayOfValidationError;

    global LoyaltyResponse() {
    }
  }
  /*This class hold attributes of request type*/
  global class LoyaltyInfo {
    webService Integer accountNumber;
    webService string mutationType;
    webService string referenceID;
    webService string specification;
    webService Integer regularPointsAmount;
    webService Integer bonusPointsAmount;
    webService Integer pointsAmount;
    webService AuditHeader audit;

    global LoyaltyInfo() {
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
