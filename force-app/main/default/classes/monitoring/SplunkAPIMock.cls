@isTest
global class SplunkAPIMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody('');
        res.setStatusCode(200);
        return res;
    }
}
