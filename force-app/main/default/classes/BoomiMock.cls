@isTest
public class BoomiMock implements HttpCalloutMock {
  protected String body;

  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();

    res.setBody('{}');
    res.setStatusCode(200);
    res.setStatus('Success');
    return res;
  }
}
