@isTest
global class OCICommerceAPIMock implements HttpCalloutMock {
  // Implement this interface method
  global HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    switch on req.getEndpoint().right(10) {
      when 'get-deltas' {
        res.setBody(
          '{ "nextDeltaToken": "testtoken", "shouldQueryAgain": false, "records": [ { "sku": "8", "id": "Test Location", "deltaType": "Change", "onHand": 0.0, "atf": 0.0, "ato": 0.0, "reserved": 5.0, "safetyStockCount": 20.0, "futures": [], "effectiveDate": "2022-12-08T14:05:22.790896-07:00" }, { "sku": "7", "id": "Test Location", "deltaType": "Change", "onHand": 0.0, "atf": 0.0, "ato": 0.0, "reserved": 0.0, "safetyStockCount": 20.0, "futures": [], "effectiveDate": null } ] }'
        );
        res.setStatusCode(200);
        return res;
      }
      when 'ds/exports' {
        res.setBody(
          '{ "exportId": "export-id", "exportStatusLink": "/inventory/impex/v1/organizations/8e1d8476-b817-46b8-b1af-b191ace44cd6/availability-records/exports/l-e421fea1-8895-461b-9b79-69d8f973989d/status" }'
        );
        res.setStatusCode(200);
        return res;
      }
      when 'le-content' {
        res.setBody(
          '{"locationId":"Test Location"}\n{"sku":"7","onHand":1121.0,"reserved":0,"atf":1121.0,"ato":1121.0,"safetyStockCount":0.0,"futures":[],"effectiveDate":"2000-01-01T00:00:00Z"}\n{"sku":"8","onHand":1121.0,"reserved":0,"atf":1121.0,"ato":1121.0,"safetyStockCount":0.0,"futures":[],"effectiveDate":"2000-01-01T00:00:00Z"}\n{"deltaToken":"test-token"}'
        );
        res.setStatusCode(200);
        return res;
      }
      when '/export-id' {
        res.setBody('');
        res.setStatusCode(204);
        return res;
      }
    }
    return res;
  }
}
