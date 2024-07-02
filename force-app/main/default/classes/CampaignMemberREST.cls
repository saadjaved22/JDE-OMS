@RestResource(urlMapping='/CampaignMemberGET/*')
Global class CampaignMemberREST 
{
    // Class to allow My Environment EPI to verify if consumer is already in a Campaign - Created for DE265
    // Robbie Schaap 12-12-2018
    @HttpGet
    global static FullResponse getCampaignMemberbyCampConId() 
    {
        FullResponse ResponseMSG = new FullResponse();
        ResponseCampaignMember result = new ResponseCampaignMember();
     
            RestRequest request = RestContext.request;
            
            system.debug('request.requestURI' + request.requestURI);
    
            Integer StartCampId=request.requestURI.IndexOf('CampaignId=');
            Integer StartContId=request.requestURI.IndexOf('ContactId=');
            Integer amp=request.requestURI.IndexOf('&');
    
            system.debug('StartCampId '+StartCampId);
            String sContactId = request.requestURI.substring(StartContId+10);
            String sCampaignId = request.requestURI.substring(StartCampId+11,amp);

            List<Campaign> LSTCampaign = [SELECT id FROM Campaign WHERE id=:sCampaignId LIMIT 1];
            system.debug('LSTCampaign '+LSTCampaign.size());
            if (LSTCampaign.size()==1)
            {
                List<CampaignMember> LSTresult =  [SELECT Id,CampaignId,ContactId,Status FROM CampaignMember WHERE ContactId = :sContactId AND CampaignId =: sCampaignId LIMIT 1];
                //CampaignMember result;

                system.debug(sContactId);
                system.debug(sCampaignId);
                
                if (LSTresult.size()==1)
                {
                    result.id = LSTresult[0].Id;
                    result.memberstatus = LSTresult[0].Status;
                    ResponseMSG.success = true;
                    ResponseMSG.message = 'Campaign NOT allowed. Consumer ALREADY in Campaign';
                    ResponseMSG.campaignmember = result;
                }
                else
                {
                    ResponseMSG.success = true;
                    ResponseMSG.message = 'Campaign allowed. Consumer NOT YET in Campaign';                }
            }
            else
            {
                system.debug('should come here ');
            	ResponseMSG.success = false;
				ResponseMSG.message = 'Campaign does not exist';
            }
            return ResponseMSG;
    }

    global class FullResponse
    {
		public Boolean success;
		public String message;
		public ResponseCampaignMember campaignmember;
	}
    public class ResponseCampaignMember 
    {
		public String id;
		public String memberStatus;
	}
}