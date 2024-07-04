public with sharing class RestServiceCreateReservation {
  public static Boolean makeReservation(
    String orderReferenceNumber,
    String locationExternalReference,
    RestServiceOrderCreate.orderItemWrapper[] orderItems,
    String salesChannel,
    String transactionID,
    Boolean isTemporary
  ) {
    ReservationRequest reservationObj = new ReservationRequest();
    reservationObj.externalRefId = orderReferenceNumber;
    reservationObj.allowPartialReservations = false;
    if (isTemporary) {
      reservationObj.expirationSeconds = 900;
    }
    reservationObj.groups = new List<Grp>();
    Grp grp = new Grp();
    grp.id = locationExternalReference;
    grp.reservations = new List<Reservation>();
    for (RestServiceOrderCreate.orderItemWrapper orderItem : orderItems) {
      if (orderItem.type != 'bundle' && orderItem.type != 'subscription') {
        Reservation reservation = getExistingReservation(
          grp.reservations,
          orderItem.sku
        );
        if (reservation == null) {
          reservation = new Reservation();
          reservation.sku = orderItem.sku;
          reservation.quantity = Integer.valueOf(orderItem.quantity);
          grp.reservations.add(reservation);
        } else {
          reservation.quantity += Integer.valueOf(orderItem.quantity);
        }
      }
    }
    reservationObj.groups.add(grp);
    return callApi(
      JSON.serialize(reservationObj, true),
      orderReferenceNumber,
      salesChannel,
      transactionID
    );
  }

  private static Reservation getExistingReservation(
    List<Reservation> reservations,
    String sku
  ) {
    for (Reservation reservation : reservations) {
      if (reservation.sku == sku) {
        return reservation;
      }
    }
    return null;
  }

  private static Boolean callApi(
    String JSONBody,
    String orderNumber,
    String salesChannel,
    String transactionID
  ) {
    API_Endpoint__c endpoint = [
      SELECT Base_URL__c
      FROM API_Endpoint__c
      WHERE Name = 'Create Reservation API Base Endpoint' AND isDeleted = FALSE
      LIMIT 1
    ];
    System.debug('Reservation sent to API: ' + JSONBody);
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint.Base_URL__c + orderNumber + '/reserveStock');
    req.setMethod('POST');
    req.setTimeout(60000);
    req.setBody(JSONBody);

    try {
      Http http = new Http();
      HTTPResponse res = http.send(req);
      String responseBody = res.getBody();

      ReservationResponse reservationResponse = parseReservationResponse(
        responseBody
      );
      if (!reservationResponse.success) {
        // reservation failed , creating Process Exception Record
        OCI_Commerce_API__c APIsettings = [
          SELECT Id
          FROM OCI_Commerce_API__c
          LIMIT 1
        ];

        ProcessException processExc = new ProcessException();
        processExc.Status = 'New';
        processExc.Severity = 'Low';
        processExc.AttachedToId = APIsettings.Id;
        processExc.ExternalReference = salesChannel + '|' + orderNumber;
        processExc.TransactionId__c = transactionID;
        processExc.Priority = 'Low';
        processExc.Category = 'Transfer Reservation';
        processExc.Message = 'Stock Unavailable. Order aborted';
        processExc.Description = responseBody.left(2000);
        processExc.StatusCode__c = res.getStatusCode();
        insert processExc;

        System.debug('Reservation failed, throw process exception');
        return false;
      } else {
        System.debug('Reservation succeeded');
      }
    } catch (Exception ex) {
      // reservation failed , creating Process Exception Record
      OCI_Commerce_API__c APIsettings = [
        SELECT Id
        FROM OCI_Commerce_API__c
        LIMIT 1
      ];

      ProcessException processExc = new ProcessException();
      processExc.Status = 'New';
      processExc.Severity = 'Low';
      processExc.AttachedToId = APIsettings.Id;
      processExc.ExternalReference = salesChannel + '|' + orderNumber;
      processExc.TransactionId__c = transactionID;
      processExc.Priority = 'Low';
      processExc.Category = 'Transfer Reservation';
      processExc.Message = 'Stock Unavailable. Order aborted';
      processExc.Description = ex.getMessage().left(2000);
      insert processExc;
      return false;
    }
    return true;
  }

  private static ReservationResponse parseReservationResponse(String json) {
    return (ReservationResponse) System.JSON.deserialize(
      json,
      ReservationResponse.class
    );
  }

  public class ReservationRequest {
    public String externalRefId;
    public Boolean allowPartialReservations;
    public Integer expirationSeconds;
    public List<Grp> groups;
  }

  class Grp {
    public String id;
    public List<Reservation> reservations;
  }

  class Reservation {
    public String sku;
    public Integer quantity;
  }

  public class ReservationResponse {
    public String reservationTime;
    public String expirationTime;
    public boolean success;
    public ReservationResponseGroup[] groups;
    public ReservationResponseLocation[] locations;
  }

  class ReservationResponseGroup {
    public String id;
    public ReservationResponseError[] errors;
    public ReservationResponseDetail[] details;
  }
  class ReservationResponseError {
    public String sku;
    public String errorCode;
  }
  class ReservationResponseDetail {
    public String sku;
    public Decimal quantity;
  }
  class ReservationResponseLocation {
    public String id;
    public ReservationResponseError[] errors;
    public ReservationResponseDetail[] details;
  }
}
