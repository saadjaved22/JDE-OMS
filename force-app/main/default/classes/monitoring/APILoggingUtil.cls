public with sharing class APILoggingUtil {
    // class to create ProcessException records for various Apex error situations (mainly exceptions)

    // general errors that are logged without an exception
     // in case of failed inserts, obviously the sObj attached should be the 'parent' object, not the failed insert (which is rolled back)
     public static void createProcessException(String message, String description, sObject sObj, String category, String transactionId) {
        ProcessException pe = new ProcessException();
        pe.AttachedToId = sObj.id;
        pe.Message = message.left(255);
        pe.Description = description.left(2000);
        pe.Category = category;
        pe.TransactionId__c = transactionId;
        insert pe; // error handling on the creation of an exception report seems a bit over the top...
    }


    // errors from API callouts and callins
    public static void createProcessException(String message, String description, sObject sObj, String category, String transactionId, HttpRequest req, HttpResponse res) {
        ProcessException pe = new ProcessException();
        pe.AttachedToId = sObj.id;
        pe.Message = message.left(255);
        pe.Description = description.left(2000);
        pe.Category = category;
        pe.TransactionId__c = transactionId;
        pe.Payload__c = req.getBody();
        pe.StatusCode__c = res.getStatusCode();
        pe.Response__c = res.getBody();
        insert pe; // error handling on the creation of an exception report seems a bit over the top...
    }
}