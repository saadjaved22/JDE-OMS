public with sharing class Splunk implements Queueable, Database.AllowsCallouts {
  String internalCMDTName;
  Id internalentityId;
  ID internalProcessExceptionID;
  String internalPENumber;
  String internalPEtransactionID;
  public Splunk(
    String CMDTName,
    Id entityId,
    ID ProcessExceptionID,
    String PENumber,
    String PEtransactionID
  ) {
    internalCMDTName = CMDTName;
    internalentityId = entityId;
    internalProcessExceptionID = ProcessExceptionID;
    internalPENumber = PENumber;
    internalPEtransactionID = PEtransactionID;
  }

  public void execute(QueueableContext context) {
    createLog(
      internalCMDTName,
      internalentityId,
      internalProcessExceptionID,
      internalPENumber,
      internalPEtransactionID
    );
  }

  // CMDTName is required, rest is optional
  private void createLog(
    String CMDTName,
    Id entityId,
    ID ProcessExceptionID,
    String PENumber,
    String PEtransactionID
  ) {
    // entityId can be lots of objects, get the type and the proper readable name
    String entityType = entityId.getSObjectType().getDescribe().getName();
    System.debug('entityType: ' + entityType);
    //get the order this is related to, if it is passed
    Order order = null;
    String fulfilmentOrderId = '';

    //get the matching custom metadata (CMD)
    Splunk_configuration__mdt cmd = Splunk_configuration__mdt.getInstance(
      CMDTName
    );
    List<referenceFieldsWrapper> referenceFieldsList = new List<referenceFieldsWrapper>();

    // create the payload
    Splunk.logDO log = new Splunk.logDO();
    log.category = 'B2C';
    log.environment = environment__c.getOrgDefaults().type__c; // get the environment value from the custom setting
    log.origin = 'Salesforce';
    log.timestamp =
      Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + 'Z';
    referenceFieldsWrapper referenceField = new referenceFieldsWrapper();
    log.transactionID = PEtransactionID;

    ProcessException pe;
    //checking if error log is coming from Order or Fulfilment Order or Shipment
    if (entityType == 'FulfillmentOrder') {
      FulfillmentOrder forder = [
        SELECT Id, Fulfillment_Order_Id__c, OrderSummaryId
        FROM FulfillmentOrder
        WHERE Id = :entityId
        LIMIT 1
      ];
      fulfilmentOrderId = forder.Fulfillment_Order_Id__c;
      OrderSummary orderSummary = [
        SELECT id, OriginalOrderId
        FROM OrderSummary
        WHERE ID = :forder.OrderSummaryId
        LIMIT 1
      ];
      order = [
        SELECT
          Id,
          SalesChannelCountryCode__c,
          SalesChannel.SalesChannelName,
          OrderReferenceNumber
        FROM Order
        WHERE Id = :orderSummary.OriginalOrderId
        LIMIT 1
      ];
      log.entityType = 'ShipmentId';
      log.businessObject = 'Shipment Request';
      log.businessProcess = 'Delivery';
      log.direction = 'IN';
      log.partner = '';
      log.entityId = order.OrderReferenceNumber;
      referenceField.referenceName = 'OrderId';
      referenceField.referenceValue = order.OrderReferenceNumber;
      referenceFieldsList.add(referenceField);
      log.referenceFields = referenceFieldsList;
    } else if (entityType == 'Order') {
      order = [
        SELECT
          Id,
          SalesChannelCountryCode__c,
          SalesChannel.SalesChannelName,
          OrderReferenceNumber
        FROM Order
        WHERE Id = :entityId
        LIMIT 1
      ];
      log.businessObject = 'Order Creation';
      log.entityType = 'OrderId';
      log.businessProcess = 'Order';
      log.direction = 'IN';
      log.entityId = order.OrderReferenceNumber;
      log.country = order.SalesChannelCountryCode__c;
      log.partner = order.SalesChannel.SalesChannelName;
    } else if (entityType == 'OCI_Commerce_API__c') {
      // if the reservation fails, we create this object type (since there is no order to link to)
      pe = [
        SELECT
          Id,
          Category,
          Message,
          Description,
          CreatedDate,
          ExternalReference
        FROM ProcessException
        WHERE id = :ProcessExceptionID
        LIMIT 1
      ];
      String[] externalReferences = pe.ExternalReference.split('\\|');
      log.businessObject = 'Order Creation';
      log.entityType = 'OrderId';
      log.businessProcess = 'Order';
      log.direction = 'IN';
      if (externalReferences.size() > 1) {
        log.entityId = externalReferences[1];
        log.partner = externalReferences[0];
      }
    } else if (
      entityType == 'OrderSummary' &&
      CMDTName == 'Process_Exception'
    ) {
      OrderSummary orderSummary = [
        SELECT id, OriginalOrderId
        FROM OrderSummary
        WHERE ID = :entityId
        LIMIT 1
      ];
      order = [
        SELECT
          Id,
          SalesChannelCountryCode__c,
          SalesChannel.SalesChannelName,
          OrderReferenceNumber
        FROM Order
        WHERE Id = :orderSummary.OriginalOrderId
        LIMIT 1
      ];
      pe = [
        SELECT Id, Category, Message, Description, CreatedDate
        FROM ProcessException
        WHERE id = :ProcessExceptionID
        LIMIT 1
      ];
      log.entityType = CMDTName;
      log.businessProcess = pe.Category;
      log.businessObject = entityType;
      log.direction = 'IN';
      log.entityId = ProcessExceptionID;
      log.country = order.SalesChannelCountryCode__c;
      log.partner = order.SalesChannel.SalesChannelName;
      log.timestamp =
        pe.CreatedDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + 'Z';
    } else if (entityType == 'Shipment') {
      Shipment shipment = [
        SELECT OrderSummaryId
        FROM Shipment
        WHERE Id = :entityId
        LIMIT 1
      ];
      OrderSummary orderSummary = [
        SELECT id, OriginalOrderId
        FROM OrderSummary
        WHERE ID = :shipment.OrderSummaryId
        LIMIT 1
      ];
      FulfillmentOrder forder = [
        SELECT Id, Fulfillment_Order_Id__c, OrderSummaryId
        FROM FulfillmentOrder
        WHERE OrderSummaryId = :orderSummary.id
        LIMIT 1
      ];
      fulfilmentOrderId = forder.Fulfillment_Order_Id__c;
      order = [
        SELECT
          Id,
          SalesChannelCountryCode__c,
          SalesChannel.SalesChannelName,
          OrderReferenceNumber
        FROM Order
        WHERE Id = :orderSummary.OriginalOrderId
        LIMIT 1
      ];
      fulfilmentOrderId = forder.Fulfillment_Order_Id__c;
      log.entityType = 'ShipmentId';
      log.direction = 'OUT';
      log.businessObject = 'Shipment Update';
      log.businessProcess = 'Delivery';
      log.entityId = fulfilmentOrderId;
      referenceField.referenceName = 'OrderId';
      referenceField.referenceValue = order.OrderReferenceNumber;
      referenceFieldsList.add(referenceField);
      log.referenceFields = referenceFieldsList;
    }

    log.executionId = String.valueOf(entityId);
    log.status = cmd.status__c;

    // process exceptions have a bit different data to log than successful actions; so some info comes from the ProcessException record rather than from the CMD
    if (CMDTName == 'Process_Exception') {
      // logging of an error in the process (from flow or Apex)
      if (pe == null) {
        pe = [
          SELECT id, Category, Message, Description
          FROM ProcessException
          WHERE id = :ProcessExceptionID
          LIMIT 1
        ];
      }

      log.stage = pe.Message;
      log.message = pe.Description;
    } else {
      // logging of a successful creation of a business object
      log.businessProcess = cmd.businessProcess__c;
      log.stage = cmd.stage__c;
      log.businessObject = cmd.businessObject__c;
    }
    outerLogDO oLog = new outerLogDO();
    oLog.event = log;
    String payload = JSON.serialize(oLog);
    String payloadSliced = payload.replace('"transactionID"', '"transaction"'); // transaction is a reserved word... hence the replacement

    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:Solace/TI/B2B/IN/SPLUNK/' + PEtransactionId);
    req.setMethod('POST');
    req.setHeader('Accept', 'application/json');
    req.setHeader('Content-Type', 'application/json');
    req.setBody(payload);
    System.debug(payload);
    Http http = new Http();
    HttpResponse res = http.send(req);

    if (res.getStatusCode() != 200) {
      // TODO: error handling (what do you do if error logging fails? :))
      Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(
        res.getBody()
      );
    }
  }

  // DO wrapper for logging payload
  public class outerLogDO {
    public logDO event;
  }
  public class logDO {
    public String category;
    public String entityId;
    public String entityType;
    public String environment;
    public String country;
    public String origin;
    public String businessProcess;
    public String stage;
    public String status;
    public String businessObject;
    public String timestamp;
    public String executionId;
    public String transactionID;
    public String partner;
    public String message;
    public String direction;
    public referenceFieldsWrapper[] referenceFields;
  }

  public class referenceFieldsWrapper {
    public String referenceName;
    public String referenceValue;
  }
}
