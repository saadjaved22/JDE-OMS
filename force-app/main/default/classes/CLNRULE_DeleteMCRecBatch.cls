/**
*    @author: Alexander Cruz
*    @date: 09.Feb.2018
*    @description: Batch Class that will delete contacts to Marketing Cloud via REST API Call.
*
*    @Revision History
        @author : Wunderman thompson 
        @date: 08/2022
*    
History
    @Fixed by Wunderman Thompson  09/2022
*/
global class CLNRULE_DeleteMCRecBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
  public string Query;

  global CLNRULE_DeleteMCRecBatch() {
    Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
    String queryLimit = settings.Query_Limit__c != null
      ? settings.Query_Limit__c
      : '';
    Query =
      'Select Salesforce_Person_Contact_ID__c, Actual_Deletion_Date__c from Post_Deletion_Audit_Log__c WHERE DeletionInvokedinMC__c = false ' +
      'AND  Actual_Deletion_Date__c <= TODAY ' +
      queryLimit;
    //Query = 'Select Salesforce_Person_Contact_ID__c, Actual_Deletion_Date__c from Post_Deletion_Audit_Log__c WHERE Salesforce_Person_Contact_ID__c  = \'0035E00000NqwdoQAB\'';
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(Query);
  }

  global void execute(
    Database.BatchableContext BC,
    List<Post_Deletion_Audit_Log__c> scope
  ) {
    try {
      // String accessToken = getMarketingCloudOAuthToken(Cleanup_Rules_Settings__c.getInstance().ClientID__c,Cleanup_Rules_Settings__c.getInstance().ClientSecret__c);
      //system.debug(getMarketingCloudOAuthToken(Cleanup_Rules_Settings__c.getInstance().ClientID__c,Cleanup_Rules_Settings__c.getInstance().ClientSecret__c));
      String res = deleteMarketingCloudContact(scope);
      System.debug(res);

      List<Post_Deletion_Audit_Log__c> pdaToBeUpdated = new List<Post_Deletion_Audit_Log__c>();

      for (Post_Deletion_Audit_Log__c p : scope) {
        p.DeletionInvokedinMC__c = true; //Set the markings
        pdaToBeUpdated.add(p);
      }
      System.debug('**pdaToBeUpdated:' + pdaToBeUpdated);

      //Update Account Records
      if (pdaToBeUpdated.size() > 0) {
        System.debug('**Updating Records**');
        Database.SaveResult[] srList = Database.update(pdaToBeUpdated, false);
        //Debug error records
        for (Database.SaveResult sr : srList) {
          if (sr.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug(
              '**Successfully updated PostDeletionAuditLog.PostDeletionAuditLogID: ' +
              sr.getId()
            );
          } else {
            // Operation failed, so get all errors
            for (Database.Error err : sr.getErrors()) {
              System.debug('**The following error has occurred.');
              System.debug(err.getStatusCode() + ': ' + err.getMessage());
            }
          }
        }
      }
    } catch (Exception e) {
      System.debug('**The following error has occurred.');
      System.debug('**Error: ' + e.getMessage());
    }
  }

  global void finish(Database.BatchableContext BC) {
  }

  private static String JSONPostCallForToken(String endPoint, String restBody) {
    Http h = new Http();
    HttpRequest r = new HttpRequest();
    r.setTimeout(60000);
    r.setEndpoint(endPoint);
    r.setMethod('POST');
    r.setHeader('Content-type', 'application/json');
    r.setBody(restBody);
    HttpResponse res = h.send(r);
    System.debug(res.getBody());
    return res.getBody();
  }

  public String JSONPostCallForDeletion(String endPoint, String restBody) {
    Http h = new Http();
    HttpRequest r = new HttpRequest();
    r.setTimeout(60000);
    r.setEndpoint(endPoint);
    r.setMethod('POST');
    r.setHeader('Content-type', 'application/json');
    r.setHeader(
      'Authorization',
      'Bearer ' +
      getMarketingCloudOAuthToken(
        Cleanup_Rules_Settings__c.getInstance().ClientID__c,
        Cleanup_Rules_Settings__c.getInstance().ClientSecret__c
      )
    );
    r.setBody(restBody);
    HttpResponse res = h.send(r);
    System.debug(res.getBody());
    return res.getBody();
  }

  public String getMarketingCloudOAuthToken(
    String clientId,
    String clientSecret
  ) {
    String responseBody = JSONPostCallForToken(
      Cleanup_Rules_Settings__c.getInstance().REST_URL_Req_Token__c,
      JSON.serialize(
        new Map<String, String>{
          'grant_type' => Cleanup_Rules_Settings__c.getInstance().Grant_Type__c,
          'client_id' => clientId,
          'client_secret' => clientSecret,
          'account_id' => Cleanup_Rules_Settings__c.getInstance().Account_Id__c
        }
      )
    );
    return ((Map<String, String>) JSON.deserialize(
        responseBody,
        Map<String, String>.class
      ))
      .get(Cleanup_Rules_Settings__c.getInstance().AccessToken__c);
  }

  public String deleteMarketingCloudContact(
    List<Post_Deletion_Audit_Log__c> conts
  ) {
    Set<String> contactIDtoDel = new Set<String>();
    for (Post_Deletion_Audit_Log__c pdalog : conts) {
      contactIDtoDel.add(pdalog.Salesforce_Person_Contact_ID__c);
    }
    system.debug('contactIDtoDel ' + contactIDtoDel);
    String responseBody = JSONPostCallForDeletion(
      Cleanup_Rules_Settings__c.getInstance().REST_URL_Del_ConKey__c,
      JSONbody(contactIDtoDel)
    );
    system.debug('responseBody ' + responseBody);
    return responseBody;
  }

  public string JSONbody(Set<String> contactIds) {
    string str = '{\"ContactTypeId\":0, \"values\":[';

    for (String s : contactIds) {
      str += ('\"' + s + '\",');
    }

    str = str.removeEnd(',');
    str += '],';
    str += ' \"DeleteOperationType\":\"ContactAndAttributes\"}';

    return str;
  }
}
