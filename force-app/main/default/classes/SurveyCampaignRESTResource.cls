/**
* REST endpoint to save Survey Campaigns data
*
* @author tim.dirckx@emark.com
*/
@RestResource(urlMapping='/v1/Survey/Campaign/*')
global with sharing class SurveyCampaignRESTResource {

    @HttpPost
    global static SurveyCampaignResponse save() {
        RestRequest request = RestContext.request;
        SurveyCampaignResponse response = SurveyCampaignRESTIntegration.insertIntegration(request);
        System.Debug(response);
        return response;
    }
}