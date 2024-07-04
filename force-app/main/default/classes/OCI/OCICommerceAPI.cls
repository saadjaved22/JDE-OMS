public with sharing class OCICommerceAPI {
  /*
        This class keeps the availability of stock in sync between OCI and core, in the object OCI_Stock__c.

        getAvailabilityUpdate () is meant to be scheduled at regular intervals, as its normal execution is
            based on the deltaToken from the previous call.
            If no deltaToken is set, it requests a new export, which is then fetched in the next scheduled call.
            This can be done differently of course, by trying the actual file download until it succeeds, but there
            is no need for that if this is scheduled regularly (e.g., every 15 mins).

        resetAvailability () simply removes all OCI_Stock__c records.

        updateSafetyStock () is called from screenflow and updates the ConnectAPI. Safety Stock for all SKUs in a Location, and writes it back to OCI.

		updateSafetyStockToOCI () is doing the actual update to OCI using the . Also called from trigger on OCI_Stock
    */

  @future(callout=true)
  public static void getAvailabilityUpdate() {
    // stored in custom object; custom settings do not allow text > 255 chars, and custom MDT does not allow DML...
    // IMPORTANT: make sure every org has exactly one record of this object!!!
    OCI_Commerce_API__c APIsettings = [
      SELECT id, organisationID__c, deltaToken__c, exportID__c
      FROM OCI_Commerce_API__c
      LIMIT 1
    ];

    if (APIsettings.deltaToken__c != null) {
      // if there is a deltaToken, fetch the  delta
      getAvailabilityDelta(APIsettings);
    } else {
      if (APIsettings.exportID__c != null) {
        // else, if there is an exportID, get the export
        getAvailabilityExport(APIsettings);
      } else {
        requestAvailabilityExport(APIsettings); // else, request an export
      }
    }
    update APISettings; // update the deltaToken and/or exportID
  }

  // in case something is wrong, simply delete all availability records and fetch anew.
  public static void resetAvailability() {
    List<OCI_Stock__c> stock = [SELECT Id FROM OCI_Stock__c];

    delete stock;
    OCI_Commerce_API__c APIsettings = [
      SELECT id, deltaToken__c
      FROM OCI_Commerce_API__c
      LIMIT 1
    ];
    APIsettings.deltaToken__c = null;
    update APIsettings;
  }

  @invocableMethod(
    Callout=true
    label='Update Safety Stock in Warehouse'
    description='Update the Safety Stock for all SKUs in a warehouse'
  )
  public static void updateSafetyStock(List<safetyStockAtLocation> sSAtLocs) {
    if (sSAtLocs.size() == 1) {
      List<OCI_Stock__c> stockList = [
        SELECT id, SKU__c, safetyStockCount__c
        FROM OCI_Stock__c
        WHERE location__r.ExternalReference = :sSAtLocs[0].location
      ];
      for (OCI_Stock__c stockItem : stockList) {
        stockItem.safetyStockCount__c = sSAtLocs[0].safetyStock;
      }
      update (stockList);
      updateSafetyStockToOCI(sSAtLocs[0].location);
    } else {
      // should only be called with one location at the time, to avoid DML limits. Since it is only called from a screenflow with an explicit one location select,
      // this does not pose any issues.
    }
  }

  public class safetyStockAtLocation {
    @InvocableVariable(
      required=true
      label='External Reference of the warehouse/location'
    )
    public String location;

    @InvocableVariable(
      required=true
      label='New safety stock value for all SKUs in the warehouse/location'
    )
    public Integer safetyStock;
  }

  // for some unknown reason, the ConnectAPI call fails if this is not a @future method...
  @future(callout=true)
  public static void updateSafetyStockToOCI(String location) {
    List<OCI_Stock__c> stockList = [
      SELECT id, SKU__c, safetyStockCount__c
      FROM OCI_Stock__c
      WHERE location__r.ExternalReference = :location
    ];
    if (stocklist.size() > 0) {
      String now = datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
      String uploadString = '{"location":"' + location + '","mode":"UPDATE"}\n';
      for (OCI_Stock__c stockItem : stocklist) {
        uploadString +=
          '{"recordId":"' +
          generateUID() +
          '", "sku":"' +
          stockItem.sku__c +
          '", "effectiveDate": "' +
          now +
          '", "safetyStockCount": ' +
          stockItem.safetyStockCount__c +
          '}\n';
      }
      System.debug(uploadString);
      Blob jsonBlob = Blob.valueof(uploadString);
      ConnectApi.BinaryInput input = new ConnectApi.BinaryInput(
        jsonBlob,
        'application/json',
        'file.json'
      );
      // the result of the ConnectAPI method is useless at the time, since it always returns success even if there is an error...
      if (!Test.isRunningTest()) {
        ConnectApi.OCIUploadInventoryAvailabilityOutputRepresentation output = ConnectApi.OmnichannelInventoryService.submitInventoryAvailabilityUpload(
          input
        );
        System.debug(output);
      }
    }
  }

  public static String generateUID() {
    // generates a random UID of 17 digits, starting with POSIX time
    return String.valueof(datetime.now().getTime()) +
      String.valueOf(Math.roundToLong(Math.Random() * 999999)).leftPad(7, '0');
  }

  @future(callout=true)
  public static void requestRefresh(String location) {
    List<OCI_Stock__c> stockList = [
      SELECT id, SKU__c, safetyStockCount__c
      FROM OCI_Stock__c
      WHERE location__r.ExternalReference = :location
    ];
    if (stockList != null) {
      // get all locationGroups this location belongs to (in MVP, always one, but later, may be more)
      List<LocationGroupAssignment> lgas = [
        SELECT LocationGroup.ExternalReference
        FROM LocationGroupAssignment
        WHERE Location.ExternalReference = :location
      ];

      // create the string for all groups
      String groupsString = '';
      for (LocationGroupAssignment lga : lgas) {
        groupsString += '"' + lga.LocationGroup.ExternalReference + '",';
      }
      groupsString = groupsString.removeEnd(',');

      // create the string for all skus (they are from the location, so every group will have them all by definition)
      String skuString = '';
      for (OCI_Stock__c stockItem : stockList) {
        skuString += '"' + stockItem.SKU__c + '",';
      }
      skuString = skuString.removeEnd(',');
      String payload =
        '{ "skus": [' +
        skuString +
        '], "groups": [' +
        groupsString +
        '] }';
      System.debug('payload: ' + payload);

      // make callout to Solae for stock refresh event
      HttpRequest req = new HttpRequest();
      req.setEndpoint(
        'callout:Solace/TI/RTL/DTC/inventory/refresh/v1/Salesforce'
      );
      req.setMethod('POST');
      req.setHeader('Accept', 'application/json');
      req.setHeader('Content-Type', 'application/json');
      req.setBody(payload);
      Http http = new Http();
      HttpResponse res = http.send(req);
      System.debug('response code:' + res.getStatusCode());
      //TODO after MVP: error handling of callout. Cannot call future for Splunk callout from future, so needs refactio
      //if (res.getStatusCode() != 200 ) {
      //APILoggingUtil.createProcessException('Solace inventory/refresh failed','Safety stock was updated, but callout to Solace failed', stockList[0], 'OCI Sync', 'oci-sync');
      //}
    }
  }

  /******************************************************************************************
    Private methods
******************************************************************************************/

  private static void getAvailabilityDelta(OCI_Commerce_API__c APIsettings) {
    HttpRequest req = new HttpRequest();
    // todo: named credentials
    req.setEndpoint(
      'callout:OCI_Commerce_API/availability/v1/organizations/' +
        getOrganisationID() +
        '/availability-records/actions/get-deltas'
    );
    req.setMethod('POST');
    req.setHeader('Accept', 'application/json');
    req.setHeader('Content-Type', 'application/json');
    req.setBody('{"deltaToken":"' + APIsettings.deltaToken__c + '"}');
    HttpResponse res = doCommerceAPICallout(req);

    switch on res.getStatusCode() {
      when 200 {
        //success
        DeltaResponse deltaRes = (DeltaResponse) JSON.deserialize(
          res.getBody(),
          DeltaResponse.class
        );
        System.debug('delta response: ' + res.getBody());
        System.debug('delta response: ' + deltaRes);
        upsertAvailability(deltaRes.records);
        // todo: if 'shouldQueryAgain' call again with same deltaToken
        // if (deltaRes.shouldQueryAgain) {
        //    getAvailabilityDelta (APIsettings);
        // }
        APIsettings.deltaToken__c = deltaRes.nextDeltaToken;
      }
      when 410 {
        // gone; Delta link has expired
        APIsettings.deltaToken__c = null;
      }
      when 429 {
        // Too Many Requests
        // should never happen, and if it does, just wait for next scheduled round
      }
      when 403 {
        // forbidden (token expired)
        // if this happens, the token has just been reset; just wait for next scheduled round
      } //todo: more error handling
    }
  }

  //first has to request the export, before we can fetch it (next round)
  private static void requestAvailabilityExport(
    OCI_Commerce_API__c APIsettings
  ) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(
      'callout:OCI_Commerce_API/impex/v1/organizations/' +
        getOrganisationID() +
        '/availability-records/exports'
    );
    req.setMethod('POST');
    req.setHeader('Accept', 'application/json');
    req.setHeader('Content-Type', 'application/json');
    req.setBody(
      '{ "objects": { "locations": [' + getLocationsString() + '] } }'
    );
    System.debug(req.getBody());
    HttpResponse res = doCommerceAPICallout(req);
    System.debug(res.getBody());
    if (res.getStatusCode() == 200) {
      Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(
        res.getBody()
      );
      APIsettings.exportID__c = (String) m.get('exportId'); // case sensitive!
    } else {
      //todo: error handling
    }
  }

  // when we have an exportID, we can fetch the export
  private static void getAvailabilityExport(OCI_Commerce_API__c APIsettings) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(
      'callout:OCI_Commerce_API/impex/v1/organizations/' +
        getOrganisationID() +
        '/availability-records/exports/' +
        APISettings.exportID__c +
        '/file-content'
    );
    req.setMethod('GET');
    req.setHeader('Accept', '*/*');
    req.setHeader('Content-Type', 'application/json');
    HttpResponse res = doCommerceAPICallout(req);

    List<OCIStock> stockItems = new List<OCIStock>();
    WarehouseLocation loc;
    switch on res.getStatusCode() {
      when 200 {
        //success
        List<String> result = res.getBody().split('\\n');
        system.debug('do we get here?: ' + result);

        for (String line : result) {
          Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(
            line
          );
          if (null != m.get('locationId')) {
            //if we encounter a locationId, set the loc for the following sku lines...
            loc = (WarehouseLocation) JSON.deserialize(
              line,
              warehouseLocation.class
            );
            System.debug(loc.locationId);
          } else if (null != m.get('sku')) {
            OCIStock stockItem = (OCIStock) JSON.deserialize(
              line,
              OCIStock.class
            );
            stockItem.id = loc.locationId;
            stockItems.add(stockItem);
          } else if (null != m.get('deltaToken')) {
            // after all skus are done, there is a deltatoken for next time
            APIsettings.deltaToken__c = (String) m.get('deltaToken');

            deleteAvalailabilityExport(APIsettings);
          }
        }
        upsertAvailability(stockItems);
      }
      when 429 {
        // too many requests
        APILoggingUtil.createProcessException(
          'Too Many Requests',
          'The maximum allowed number of jobs are already running. The Retry-After Header value should be ignored until after the maximum number of jobs are no longer running.',
          null,
          'OCI Sync',
          'oci-sync'
        );
      }
      when 404 {
        // EntityNotFound
        APILoggingUtil.createProcessException(
          'Entity not found',
          'BatchJobRequest does not exist',
          null,
          'OCI Sync',
          'oci-sync'
        );
        //todo: more error handling,
      }
      when else {
        //todo: more error handling
      }
    }
  }

  //copy the DO to the actual object and upsert using external ID
  private static void upsertAvailability(List<OCIStock> stockItems) {
    List<Schema.Location> locs = [
      SELECT Id, ExternalReference
      FROM Location
      WHERE Name LIKE '% Location%'
    ];
    Map<String, Schema.Location> locMap = new Map<String, Schema.Location>();
    for (Schema.Location loc : locs) {
      locMap.put(loc.ExternalReference, loc);
    }
    system.debug('locMap: ' + locMap);
    List<OCI_Stock__c> oci_StockItems = new List<OCI_Stock__c>();
    Set<String> uniqueEntries = new Set<String>(); // unfortunately, entries in OCI are not guaranteed to be unique
    for (OCIStock stockItem : stockItems) {
      String stockItemName = stockItem.sku + '@' + stockItem.id;
      if (!uniqueEntries.contains(stockItemName)) {
        uniqueEntries.add(stockItemName);
        OCI_Stock__c oci_StockItem = new OCI_Stock__c(
          LocExtRef__c = stockItem.id,
          id__c = stockItemName,
          name = stockItemName,
          Reserved__c = stockItem.reserved,
          Location__c = locMap.get(stockItem.id).id,
          SKU__c = stockItem.sku,
          ATF__c = stockItem.atf,
          ATO__c = stockItem.ato,
          onHand__c = (Integer) stockItem.onHand,
          safetyStockCount__c = stockItem.safetyStockCount,
          effectiveDate__c = Date.valueOf(stockItem.effectiveDate)
        );
        oci_StockItems.add(oci_StockItem);
      }
    }
    upsert oci_StockItems id__c;
  }

  private static String getOrganisationID() {
    OCI_Commerce_API__c APIsettings = [
      SELECT organisationID__c
      FROM OCI_Commerce_API__c
      LIMIT 1
    ];
    return APIsettings.organisationID__c;
  }

  private static String getLocationsString() {
    String locationsString = '';
    // Schema.Location is required since location is an otherwise reserved/used term
    // TODO: remove 'WHERE Name LIKE '% Location%' when test locations are gone
    List<Schema.Location> locations = [
      SELECT id, ExternalReference
      FROM Location
      WHERE Name LIKE '% Location%'
    ];
    if (locations.size() > 0) {
      for (Schema.Location loc : locations) {
        locationsString += '"' + loc.ExternalReference + '",';
      }
      return locationsString.substring(0, locationsString.length() - 1); // remove the last '',''
    } else {
      // todo: error handling
      return '';
    }
  }

  private static void deleteAvalailabilityExport(
    OCI_Commerce_API__c APIsettings
  ) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(
      'callout:OCI_Commerce_API/impex/v1/organizations/' +
        getOrganisationID() +
        '/availability-records/exports/' +
        APIsettings.exportID__c
    );
    req.setMethod('DELETE');
    HttpResponse res = doCommerceAPICallout(req);

    if (res.getStatusCode() == 204) {
      // success (empty body)
      APIsettings.exportID__c = null;
    } else {
      // TODO: error handling
    }
  }

  private static HttpResponse doCommerceAPICallout(HttpRequest req) {
    // requires 'custom' JWT token handling because the CommerceAPI returns (wrongly) a 403 on expired token, whereas the Named Credential logic
    // expects (righteously) a 401...
    Http http = new Http();
    HttpResponse res = http.send(req);
    if (res.getStatusCode() == 403) {
      Id currentuser = UserInfo.getUserId();
      NamedCredential nc = [
        SELECT id
        FROM NamedCredential
        WHERE Developername = 'OCI_Commerce_API'
        LIMIT 1
      ];
      List<ExternalDataUserAuth> tokens = [
        SELECT id
        FROM ExternalDataUserAuth
        WHERE UserId = :currentuser AND ExternalDataSourceID = :nc.Id
      ];
      if (tokens.size() > 0) {
        deleteJWTToken(tokens[0].id);
        res = doCommerceAPICallout(req);
      }
    }
    return res;
  }

  private static void deleteJWTToken(Id Id) {
    // required because the JWT token exchange cannot properly remove the expired token.
    // ExternalDataUserAuth does not support DML, so using the RestAPI (???...)
    // https://www.jitendrazaa.com/blog/salesforce/call-salesforce-rest-api-from-apex/

    String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
    String restAPIURL =
      sfdcURL +
      '/services/data/v57.0/sobjects/ExternalDataUserAuth/' +
      Id;

    HttpRequest req = new HttpRequest();
    req.setMethod('DELETE');
    req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionID());
    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
    req.setEndpoint(restAPIURL);
    Http http = new Http();
    HttpResponse res = new HttpResponse();
    try {
      res = http.send(req);
    } catch (System.Exception ex) {
      APILoggingUtil.createProcessException(
        'Failed to delete expired JWT token',
        'Token Id: ' + Id,
        null,
        'OCI Sync',
        'oci-sync'
      );
    }
  }

  //DO wrappers
  public class WarehouseLocation {
    public String locationId;
  }
  public class DeltaResponse {
    public String nextDeltaToken;
    public Boolean shouldQueryAgain;
    public List<OCIStock> records;
  }

  public class OCIStock {
    public String id; // location External Reference
    public String sku;
    public Decimal onHand;
    public Decimal ato;
    public Decimal atf;
    public Decimal reserved;
    public Decimal safetyStockCount;
    public Datetime effectiveDate;
  }
}
