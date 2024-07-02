@isTest
public class YotpoApiMock implements HttpCalloutMock {

    protected String body;
   
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        
        res.setBody('{"access_token": "test"}');
        res.setStatusCode(200);
        res.setStatus('Success');
        return res;
    }
}