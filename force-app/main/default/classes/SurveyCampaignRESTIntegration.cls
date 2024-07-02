/**
* Integration for saving Survey Campaigns data
*
* @author tim.dirckx@emark.com
*/
global with sharing class SurveyCampaignRESTIntegration {

    public static Campaign campaign;
    public static Account account;

    public static final String ERROR_EMPTY_REQUEST = 'No data in request.';
    public static final String ERROR_EMPTY_QUESTIONS = 'No data in questions attribute or attribute doesn\'t exists.';
    public static final String ERROR_EMPTY_RESULTS = 'No data in results attribute or attribute doesn\'t exists.';
    public static final String ERROR_EMPTY_RESULTS_ATTRIBUTES = 'Missing one of the following mandatory field in the results attribute: rank, name, value, properties';
    public static final String ERROR_MANDATORY_RESULTS_PROPERTIES = 'Missing one of the following mandatory field in the results properties attribute: name, value';
    public static final String ERROR_MANDATORY_FIELDS = 'Missing one of the following mandatory fields: accountId, campaignProfileId, campaignId, results or questions';
    public static final String ERROR_EMPTY_QUESTIONS_ATTRIBUTES = 'Missing one of the following mandatory field in the questions attribute: title, question_id or answers';
    public static final String ERROR_MANDATORY_QUESTIONS_ANSWERS = 'Missing one of the following mandatory field in the questions answers attribute: title, answer_id, selected';
    public static final String ERROR_CAMPAIGN_NOT_EXISTING = 'Campaign does not exists!';
    public static final String ERROR_ACCOUNT_NOT_EXISTING = 'Account does not exists!';


    // save the Survey_Campaign_Profile__c
    @TestVisible
    private static Survey_Campaign_Profile__c saveSurveyCampaignProfile(SurveyCampaignRequest requestObject) {
        List<Survey_Campaign_Profile__c> exitingSurveyCampaignProfile = SurveyCampaignProfileSelector.findUnique(
                requestObject.campaignProfileId, 
                SurveyCampaignRESTIntegration.campaign.Id, 
                SurveyCampaignRESTIntegration.account.PersonContactId
        );
        
        if(exitingSurveyCampaignProfile.size() == 0) {
            Survey_Campaign_Profile__c surveyCampaignProfile = new Survey_Campaign_Profile__c();
            surveyCampaignProfile.campaignprofileid__c = requestObject.campaignProfileId;
            surveyCampaignProfile.CampaignId__c = SurveyCampaignRESTIntegration.campaign.Id;        
            surveyCampaignProfile.ContactId__c = SurveyCampaignRESTIntegration.account.PersonContactId;
            surveyCampaignProfile.Last_Payload_Date__c = Date.today();

            insert surveyCampaignProfile;

            return surveyCampaignProfile;
        } else {
            Survey_Campaign_Profile__c surveyCampaignProfileUpdate = new Survey_Campaign_Profile__c();
            surveyCampaignProfileUpdate.Id = exitingSurveyCampaignProfile[0].Id;
            surveyCampaignProfileUpdate.Last_Payload_Date__c = Date.today();

            update surveyCampaignProfileUpdate;
        }

        return exitingSurveyCampaignProfile[0];
    }


    //Saving the survey result and properties
    @TestVisible
    private static void saveSurveyResult(SurveyCampaignRequest requestObject, Id surveyCampaignProfileId) {
        List<Survey_Result_Property__c> properties = new List<Survey_Result_Property__c>();
        List<Survey_Result__c> surveyResultList = new List<Survey_Result__c>();

        for(SurveyCampaignRequest.SurveyResult result: requestObject.results) {
            Survey_Result__c resultObj = new Survey_Result__c();
            resultObj.Unique_Id__c = String.valueOf(surveyCampaignProfileId) + result.value;
            resultObj.Name__c = result.name;
            resultObj.Rank__c = result.rank;
            resultObj.Survey_Campaign_Profile__c = surveyCampaignProfileId;
            resultObj.Value__c = result.value;

            surveyResultList.add(resultObj);
        }

        upsert surveyResultList Unique_Id__c;

        for(Integer i = 0; i<surveyResultList.size(); i++) {
            for(SurveyCampaignRequest.SurveyResultProperty property: requestObject.results[i].Properties) {
                Survey_Result_Property__c surveyResultProperty = new Survey_Result_Property__c();
                surveyResultProperty.Unique_Id__c = String.valueOf(surveyCampaignProfileId) + requestObject.results[i].value + property.name;
                surveyResultProperty.Name__c = property.name;
                surveyResultProperty.Value__c = property.value;
                surveyResultProperty.Survey_Result__c = surveyResultList[i].Id;
                properties.add(surveyResultProperty);
            }        
        }     

        upsert properties Unique_Id__c;
    }


    //Saving the survey Question and answers
    @TestVisible
    private static void saveSurveyQuestions(SurveyCampaignRequest requestObject, Id surveyCampaignProfileId) {
        List<Survey_Answer__c> answers = new List<Survey_Answer__c>();
        List<Survey_Question__c> surveyQuestionsList = new List<Survey_Question__c>();

        for(SurveyCampaignRequest.SurveyQuestion question: requestObject.questions) {
            Survey_Question__c questionObj = new Survey_Question__c();
            questionObj.Question_Id__c = question.question_id;
            questionObj.Unique_Id__c = String.valueOf(surveyCampaignProfileId) + question.question_id;
            questionObj.Title__c = question.title;
            questionObj.Survey_Campaign_Profile__c = surveyCampaignProfileId;

            surveyQuestionsList.add(questionObj);
        }

        upsert surveyQuestionsList Unique_Id__c;

        for(Integer i = 0; i<surveyQuestionsList.size(); i++) {
            for(SurveyCampaignRequest.SurveyAnswer answer: requestObject.questions[i].answers) {
                Survey_Answer__c surveyAnswer = new Survey_Answer__c();
                surveyAnswer.Answer_Id__c = answer.answer_id;
                surveyAnswer.Unique_Id__c = String.valueOf(surveyCampaignProfileId) + requestObject.questions[i].question_id + answer.answer_id;
                surveyAnswer.Title__c = answer.title;
                surveyAnswer.Value__c = answer.value;
                surveyAnswer.Selected__c = answer.selected;
                surveyAnswer.Survey_Question__c = surveyQuestionsList[i].Id;

                answers.add(surveyAnswer);
            }
        }

        upsert answers Unique_Id__c;
    }


    //validation of the given request. Throws an Exception when there is an error
    @TestVisible
    private static void validateRequest(String requestBody, SurveyCampaignRequest fullRequest) {
        if(
            fullRequest.accountId == NULL || fullRequest.accountId == '' ||
            fullRequest.campaignProfileId == NULL || fullRequest.campaignProfileId == '' ||
            fullRequest.campaignId == NULL || fullRequest.campaignId == '' ||
            fullRequest.questions == NULL || fullRequest.results == NULL
        ) {
            throw new CalloutException( ERROR_MANDATORY_FIELDS);
        }

        if(fullRequest.results.size() > 0) {
            for(SurveyCampaignRequest.SurveyResult result : fullRequest.results) {
                if(
                    result.rank == NULL ||
                    result.name == NULL || result.name == '' ||
                    result.value == NULL || result.value == '' ||
                    result.Properties == NULL
                ) {
                    throw new CalloutException( ERROR_EMPTY_RESULTS_ATTRIBUTES );
                }

                if(result.Properties.size() > 0) {
                    for(SurveyCampaignRequest.SurveyResultProperty property: result.Properties) {
                        if(
                            property.name == NULL || property.name == '' ||
                            property.value == NULL || property.value == '' 
                        ) {
                            throw new CalloutException( ERROR_MANDATORY_RESULTS_PROPERTIES );
                        }
                    }
                }
            }
        }

        if(fullRequest.questions.size() > 0) {
            for(SurveyCampaignRequest.SurveyQuestion question: fullRequest.questions) {
                if(
                    question.title == NULL || question.title == '' ||
                    question.answers == NULL || 
                    question.question_id == null || question.question_id == ''
                ) {
                    throw new CalloutException( ERROR_EMPTY_QUESTIONS_ATTRIBUTES );
                }

                if(question.answers.size() > 0) {
                    for(SurveyCampaignRequest.SurveyAnswer answer: question.answers) {
                        if(
                            answer.title == NULL || answer.title == '' ||
                            answer.selected == NULL || answer.answer_id == null || answer.answer_id == ''
                        ) { 
                            throw new CalloutException( ERROR_MANDATORY_QUESTIONS_ANSWERS );
                        }
                    }
                }
            }
        }

        SurveyCampaignRESTIntegration.campaign = CampaignSelector.getCampaignByExternalId(fullRequest.campaignId);
        if(SurveyCampaignRESTIntegration.campaign == null) {
            throw new CalloutException( ERROR_CAMPAIGN_NOT_EXISTING );
        }

        SurveyCampaignRESTIntegration.account = AccountSelector.getContactByExternalId(fullRequest.accountId);
        if(SurveyCampaignRESTIntegration.account == null) {
            throw new CalloutException( ERROR_ACCOUNT_NOT_EXISTING );
        }
    }


    //Deserialize the json and validate it
	@TestVisible
	private static SurveyCampaignRequest readFromRequest ( RestRequest request ) {
		String requestBody = request.requestBody.toString();
        
        if ( requestBody.length() == 0 ) {
			throw new CalloutException( ERROR_EMPTY_REQUEST );
		}

		SurveyCampaignRequest fullRequest = (SurveyCampaignRequest) JSON.deserialize(requestBody, SurveyCampaignRequest.class );

		validateRequest(requestBody, fullRequest);

		return fullRequest; 
	}


    //delete existing survey campaign and then save the different attributes in the json call
    @TestVisible
    private static void saveRequest(SurveyCampaignRequest requestObject) {
        Survey_Campaign_Profile__c surveyCampaignProfile = SurveyCampaignRESTIntegration.saveSurveyCampaignProfile(requestObject);
        SurveyCampaignRESTIntegration.saveSurveyResult(requestObject, surveyCampaignProfile.Id);
        SurveyCampaignRESTIntegration.saveSurveyQuestions(requestObject, surveyCampaignProfile.Id);
    }

    
    //Read the request and validate and save the result
    global static SurveyCampaignResponse insertIntegration(RestRequest request) {
        System.debug('Incoming request - uri: ' + request.requestURI + ' path:' + request.resourcePath + 'headers:' + request.headers);
        SurveyCampaignResponse response = new SurveyCampaignResponse();

        try {
            SurveyCampaignRequest data = readFromRequest( request );
            SurveyCampaignRESTIntegration.saveRequest(data);
        } catch(Exception e) {
            response.success = false;
            response.error = e.getMessage();
            return response;
        }

        response.success = true;
        response.message = 'OK';                                                           

        return response;
    }
}