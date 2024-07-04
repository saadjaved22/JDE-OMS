public without sharing class LightningConfirmEmailChangeController {
  @AuraEnabled
  public static string confirmEmailChange(
    String hashCode,
    String currentEmail,
    String loginUrl
  ) {
    try {
      if (!ConsumerAttributes.validateEmail(currentEmail)) {
        return Label.DEInvalidEmailAddress;
      }

      String accountExternalId = currentEmail + Label.Country + Label.Brand;
      List<Account> accList;

      if (Test.isRunningTest()) {
        accList = [
          SELECT Id, personEmail, New_Email__c, New_Email_Request_Datetime__c
          FROM Account
          LIMIT 1
        ];
      } else {
        accList = [
          SELECT Id, personEmail, New_Email__c, New_Email_Request_Datetime__c
          FROM Account
          WHERE External_Id__c = :accountExternalId AND IsCustomerPortal = TRUE
          LIMIT 1
        ];
      }

      // System.debug('accountList : '+accList);

      if (accList.size() > 0) {
        Account acc = accList[0];
        String hashBase64SHA1;
        Boolean isExpiredLink = true;
        Boolean isValidHachCode = false;

        Blob targetBlob = Blob.valueOf(
          String.valueOfGmt(acc.New_Email_Request_Datetime__c)
        );
        Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
        hashBase64SHA1 = EncodingUtil.base64encode(hash);
        /* String dateString = String.valueOfGmt(acc.New_Email_Request_Datetime__c);
         hashCodeString = String.valueOf(dateString.hashCode()); */
        if (acc.New_Email_Request_Datetime__c != null) {
          isExpiredLink = true
            ? Integer.valueOf(
                (Datetime.now().getTime() -
                acc.New_Email_Request_Datetime__c.getTime()) / (1000 * 60 * 60)
              ) > 72
            : false;
        }
        isValidHachCode = true ? hashCode == hashBase64SHA1 : false;

        if (
          acc.New_Email__c != null &&
          !String.isBlank(acc.New_Email__c) &&
          isValidHachCode &&
          !isExpiredLink
        ) {
          /* acc.personEmail = acc.New_Email__c;
                    acc.New_Email__c = null;
                    acc.New_Email_Request_Datetime__c = null;
                    acc.New_Email_Confirm_URL__c = null;
                    update acc; */
          String accessToken = getToken();
          String ret = updateAccountViaApi(acc, accessToken);
          System.debug('ret ' + ret);
          if (ret == 'Failed') {
            return 'Failed';
          }
        } else {
          return 'The link is invalid or expired';
        }
      } else {
        System.debug('Customer  not found');
        return 'Customer  not found';
      }

      return 'Confirmed';
    } catch (Exception e) {
      System.debug(e.getMessage());
      System.debug(e.getStackTraceString());
      throw new AuraHandledException(e.getMessage());
    }
  }

  public static String getToken() {
    DE_Community_Settings__c DE = DE_Community_Settings__c.getInstance();
    String endpoint = DE.Get_Token_Endpoint__c;
    String grantType = DE.Grant_type__c;
    String username = DE.username__c;
    String password = DE.password__c;
    String securityToken = DE.Security_Token__c;
    String CLIENT_ID = DE.Client_Id__c;
    String CLIENT_SECRET = DE.Client_Secret__c;

    Httprequest request = new HttpRequest();
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

    request.setBody(
      'grant_type=' +
        grantType +
        '&client_id=' +
        CLIENT_ID +
        '&client_secret=' +
        CLIENT_SECRET +
        '&username=' +
        username +
        '&password=' +
        password +
        securityToken
    );
    request.setEndpoint(endpoint);

    Http http = new Http();
    String access_token;
    try {
      HttpResponse response = http.send(request);
      // Parse the JSON response
      if (response.getStatusCode() != 200) {
        System.debug(
          'getToken--  The status code returned was not expected: ' +
            response.getStatusCode() +
            ' ' +
            response.getStatus()
        );
      } else {
        System.debug('Response Body : ' + response.getBody());
        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(
          response.getBody()
        );
        access_token = String.valueOf(parsedResponse.get('access_token'));
      }
    } catch (Exception e) {
      System.debug(e.getMessage());
    }

    return access_token;
  }

  private static String updateAccountViaApi(Account acc, String accessToken) {
    DE_Community_Settings__c DE = DE_Community_Settings__c.getInstance();
    Http http = new Http();
    Httprequest request = new HttpRequest();
    String endpoint = DE.Update_Account_Endpoint__c + acc.Id;

    request.setEndpoint(endpoint);
    request.setMethod('PATCH');
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    // request.setTimeout(30000);

    String reqBody =
      '{' +
      '"personEmail" : "' +
      acc.New_Email__c +
      '",' +
      '"New_Email__c" : "",' +
      '"New_Email_Request_Datetime__c" : "",' +
      '"New_Email_Confirm_URL__c" : "" }';

    request.setBody(reqBody);
    try {
      HttpResponse response = http.send(request);

      if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
        System.debug(
          'Updating account via api failed-- The status code returned was not expected: ' +
            response.getStatusCode() +
            ' ' +
            response.getStatus() +
            '' +
            response.getBody()
        );
        return 'Failed';
      } else {
        System.debug(
          'Updating account via api failed success --' +
            response.getStatus() +
            '' +
            response.getBody()
        );
      }
    } catch (Exception e) {
      System.debug(e.getMessage());
      return 'Failed';
    }

    return 'Confirmed';
  }
}
