@isTest
public with sharing class SurveyCampaignRESTResourceTest {
  @TestSetup
  static void makeData() {
    String RecTypeId = [
      SELECT Id
      FROM RecordType
      WHERE Name = 'Person Account' AND SobjectType = 'Account'
    ]
    .Id;

    Account account = new Account(
      RecordTypeID = RecTypeId,
      FirstName = 'Test',
      LastName = 'Person',
      PersonMailingStreet = 'Some street 123',
      PersonMailingPostalCode = '1234 LS',
      PersonMailingCity = 'Amsterdam',
      PersonEmail = 'test@example.com',
      PersonHomePhone = '1234567891',
      PersonMobilePhone = '1234567891',
      External_Id__c = '456-654'
    );

    insert account;

    Campaign campaign = new Campaign();
    campaign.Name = 'TestCampaign';
    campaign.External_Id__c = '123-321';

    insert campaign;
  }

  private static void mockPOSTRequest(String jsonRequestBody) {
    RestRequest request = new RestRequest();

    request.httpMethod = 'POST';
    request.requestBody = Blob.valueOf(jsonRequestBody);

    RestContext.request = request;
  }

  @isTest
  public static void insertCorrectIntegration() {
    String campaignprofileid = '123-123-123-123';

    Test.startTest();
    Account account = [
      SELECT PersonContactId, External_Id__c
      FROM Account
      WHERE External_Id__c = '456-654'
      LIMIT 1
    ];
    Campaign campaign = [
      SELECT Id, External_Id__c
      FROM Campaign
      WHERE Name = 'TestCampaign'
      LIMIT 1
    ];

    String correctBody =
      '{ "campaignprofileid": "' +
      campaignprofileid +
      '", "accountid": "' +
      account.External_Id__c +
      '", "campaignid": "' +
      campaign.External_Id__c +
      '", "results": [ { "rank": 1, "name": "Jacobs Barista Editions Espresso", "value": "8711000891736", "Properties": [ { "name": "outputGrindSize", "value": "fine" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "short" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "mild" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] }, { "rank": 2, "name": "Jacobs Barista Editions Crema", "value": "8711000891704", "Properties": [ { "name": "outputGrindSize", "value": "standard" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "standard" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "standard" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] } ], "questions": [ { "title": "Choose your coffee beans", "question_id": "1", "answers": [ { "title": "Jacobs Barista Editions Crema", "answer_id": "1", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Crema Intense", "answer_id": "2", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Espresso", "answer_id": "3", "selected": true, "value": null } ] }, { "title": "Choose your favourite coffee", "question_id": "2", "answers": [ { "title": "Capuccino", "answer_id": "4", "selected": false, "value": null }, { "title": "Americano", "answer_id": "5", "selected": true, "value": null }, { "title": "Espresso", "answer_id": "6", "selected": false, "value": null } ] }, { "title": "Select volume control", "question_id": "3", "answers": [ { "title": "Yes", "answer_id": "7", "selected": false, "value": null }, { "title": "No", "answer_id": "8", "selected": true, "value": null } ] } ] }';
    mockPOSTRequest(correctBody);

    SurveyCampaignResponse response = SurveyCampaignRESTResource.save();

    SurveyCampaignResponse checkResponse = new SurveyCampaignResponse();
    checkResponse.message = 'OK';
    checkResponse.success = true;

    System.assertEquals(
      checkResponse.success,
      response.success,
      'Succes should be valid!'
    );
    System.assertEquals(
      checkResponse.message,
      response.message,
      'message should be saying OK!'
    );
    System.assertEquals(
      checkResponse.error,
      response.error,
      'response error should be null!'
    );

    List<Survey_Campaign_Profile__c> surveyCampaignProfile = [
      SELECT
        campaignprofileid__c,
        CampaignId__c,
        ContactId__c,
        Last_Payload_Date__c
      FROM Survey_Campaign_Profile__c
      WHERE campaignprofileid__c = :campaignprofileid
    ];
    System.assertEquals(
      surveyCampaignProfile.size(),
      1,
      'Survey_Campaign_Profile__c did not return the correct number of records'
    );

    if (surveyCampaignProfile.size() > 0) {
      System.assertEquals(
        surveyCampaignProfile[0].campaignprofileid__c,
        campaignprofileid,
        'campaignprofileid__c is not saved correct!'
      );
      System.assertEquals(
        surveyCampaignProfile[0].CampaignId__c,
        campaign.Id,
        'CampaignId__c is not saved correct!'
      );
      System.assertEquals(
        surveyCampaignProfile[0].ContactId__c,
        account.PersonContactId,
        'ContactId__c is not saved correct!'
      );
      System.assertEquals(
        surveyCampaignProfile[0].Last_Payload_Date__c,
        Date.today(),
        'ContactId__c is not saved correct!'
      );

      Id surveyCampaignProfileId = surveyCampaignProfile[0].Id;
      List<Survey_Question__c> questions = [
        SELECT Id, Title__c
        FROM Survey_Question__c
        WHERE Survey_Campaign_Profile__c = :surveyCampaignProfileId
        ORDER BY Title__c ASC
      ];
      System.assertEquals(
        questions.size(),
        3,
        'Survey_Question__c did not return the correct number of records'
      );
      if (questions.size() > 0) {
        System.assertEquals(questions[0].Title__c, 'Choose your coffee beans');

        Id questionsId1 = questions[0].Id;
        List<Survey_Answer__c> answers1 = [
          SELECT Title__c, Value__c, Selected__c
          FROM Survey_Answer__c
          WHERE Survey_Question__c = :questionsId1
        ];
        System.assertEquals(
          answers1.size(),
          3,
          'Survey_Answer__c did not return the correct number of records [1]'
        );

        Id questionsId2 = questions[2].Id;
        List<Survey_Answer__c> answers2 = [
          SELECT Title__c, Value__c, Selected__c
          FROM Survey_Answer__c
          WHERE Survey_Question__c = :questionsId2
          ORDER BY Title__c ASC
        ];
        System.assertEquals(
          answers2.size(),
          2,
          'Survey_Answer__c did not return the correct number of records [2]'
        );

        if (answers2.size() > 0) {
          System.assertEquals(
            answers2[0].Title__c,
            'No',
            'Answer should be no'
          );
          System.assertEquals(
            answers2[0].Value__c,
            null,
            'Answer should be null'
          );
          System.assertEquals(
            answers2[0].Selected__c,
            true,
            'Answer should be true'
          );
        }
      }

      List<Survey_Result__c> results = [
        SELECT Name__c, Rank__c, Value__c
        FROM Survey_Result__c
        WHERE Survey_Campaign_Profile__c = :surveyCampaignProfileId
        ORDER BY Rank__c ASC
      ];
      System.assertEquals(
        results.size(),
        2,
        'Survey_Result__c did not return the correct number of records'
      );
      if (results.size() > 0) {
        System.assertEquals(
          results[0].Rank__c,
          1,
          'Result Rank__c should be 1'
        );
        System.assertEquals(
          results[0].Name__c,
          'Jacobs Barista Editions Espresso',
          'Jacobs Barista Editions Espresso'
        );
        System.assertEquals(
          results[0].Value__c,
          '8711000891736',
          'Result Value__c should be 8711000891736'
        );

        Id resultId = results[0].Id;

        List<Survey_Result_Property__c> properties = [
          SELECT Name__c, Value__c
          FROM Survey_Result_Property__c
          WHERE Survey_Result__c = :resultId
          ORDER BY Name__c ASC
        ];
        System.assertEquals(
          properties.size(),
          6,
          'Survey_Result_Property__c did not return the correct number of records'
        );

        if (properties.size() > 0) {
          System.assertEquals(
            properties[0].Name__c,
            'ourputCoffeeStrength',
            'property Name__c should reutrn ourputCoffeeStrength'
          );
          System.assertEquals(
            properties[0].Value__c,
            'mild',
            'property Value__c should return mild'
          );
        }
      }
    }
    Test.stopTest();
  }

  @isTest
  public static void failedNoBodyTest() {
    Test.startTest();

    String correctBody = '';
    mockPOSTRequest(correctBody);

    SurveyCampaignResponse response = SurveyCampaignRESTResource.save();
    System.assertEquals(
      response.error,
      'No data in request.',
      'Not the correct error'
    );
    System.assertEquals(response.message, null, 'message should be null');
    System.assertEquals(response.success, false, 'success should be false');

    Test.stopTest();
  }

  @isTest
  public static void failedFaultyJSONTest() {
    Test.startTest();
    String correctBody = '{somefaultyjson';
    mockPOSTRequest(correctBody);

    SurveyCampaignResponse response = SurveyCampaignRESTResource.save();
    System.assertEquals(
      response.error,
      'Unexpected character (\'s\' (code 115)): was expecting double-quote to start field name at [line:1, column:3]',
      'Not the correct error'
    );
    System.assertEquals(response.message, null, 'message should be null');
    System.assertEquals(response.success, false, 'success should be false');
    System.Debug(response);

    Test.stopTest();
  }

  @isTest
  public static void failedWrongCampaignIdTest() {
    String campaignprofileid = '123-123-123-123';

    Test.startTest();
    Account account = [
      SELECT PersonContactId, External_Id__c
      FROM Account
      WHERE External_Id__c = '456-654'
      LIMIT 1
    ];
    String campaignExternalId = 'some-not-existing-campaign-id';

    String correctBody =
      '{ "campaignprofileid": "' +
      campaignprofileid +
      '", "accountid": "' +
      account.External_Id__c +
      '", "campaignid": "' +
      campaignExternalId +
      '", "results": [ { "rank": 1, "name": "Jacobs Barista Editions Espresso", "value": "8711000891736", "Properties": [ { "name": "outputGrindSize", "value": "fine" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "short" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "mild" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] }, { "rank": 2, "name": "Jacobs Barista Editions Crema", "value": "8711000891704", "Properties": [ { "name": "outputGrindSize", "value": "standard" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "standard" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "standard" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] } ], "questions": [ { "title": "Choose your coffee beans", "question_id": "1", "answers": [ { "title": "Jacobs Barista Editions Crema", "answer_id": "1", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Crema Intense", "answer_id": "2", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Espresso", "answer_id": "3", "selected": true, "value": null } ] }, { "title": "Choose your favourite coffee", "question_id": "2", "answers": [ { "title": "Capuccino", "answer_id": "4", "selected": false, "value": null }, { "title": "Americano", "answer_id": "5", "selected": true, "value": null }, { "title": "Espresso", "answer_id": "6", "selected": false, "value": null } ] }, { "title": "Select volume control", "question_id": "3", "answers": [ { "title": "Yes", "answer_id": "7", "selected": false, "value": null }, { "title": "No", "answer_id": "8", "selected": true, "value": null } ] } ] }';
    mockPOSTRequest(correctBody);

    SurveyCampaignResponse response = SurveyCampaignRESTResource.save();
    System.assertEquals(response.error, 'Campaign does not exists!');
    System.assertEquals(response.message, null, 'message should be null');
    System.assertEquals(response.success, false, 'success should be false');
    System.Debug(response);

    Test.stopTest();
  }

  @isTest
  public static void failedWrongAccountIdTest() {
    String campaignprofileid = '123-123-123-123';

    Test.startTest();
    String accountExternalId = 'some-not-existing-external-account-id';
    Campaign campaign = [
      SELECT Id, External_Id__c
      FROM Campaign
      WHERE Name = 'TestCampaign'
      LIMIT 1
    ];

    String correctBody =
      '{ "campaignprofileid": "' +
      campaignprofileid +
      '", "accountid": "' +
      accountExternalId +
      '", "campaignid": "' +
      campaign.External_Id__c +
      '", "results": [ { "rank": 1, "name": "Jacobs Barista Editions Espresso", "value": "8711000891736", "Properties": [ { "name": "outputGrindSize", "value": "fine" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "short" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "mild" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] }, { "rank": 2, "name": "Jacobs Barista Editions Crema", "value": "8711000891704", "Properties": [ { "name": "outputGrindSize", "value": "standard" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "standard" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "standard" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] } ], "questions": [ { "title": "Choose your coffee beans", "question_id": "1", "answers": [ { "title": "Jacobs Barista Editions Crema", "answer_id": "1", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Crema Intense", "answer_id": "2", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Espresso", "answer_id": "3", "selected": true, "value": null } ] }, { "title": "Choose your favourite coffee", "question_id": "2", "answers": [ { "title": "Capuccino", "answer_id": "4", "selected": false, "value": null }, { "title": "Americano", "answer_id": "5", "selected": true, "value": null }, { "title": "Espresso", "answer_id": "6", "selected": false, "value": null } ] }, { "title": "Select volume control", "question_id": "3", "answers": [ { "title": "Yes", "answer_id": "7", "selected": false, "value": null }, { "title": "No", "answer_id": "8", "selected": true, "value": null } ] } ] }';
    mockPOSTRequest(correctBody);

    SurveyCampaignResponse response = SurveyCampaignRESTResource.save();
    System.assertEquals(response.error, 'Account does not exists!');
    System.assertEquals(response.message, null, 'message should be null');
    System.assertEquals(response.success, false, 'success should be false');
    System.Debug(response);

    Test.stopTest();
  }

  @isTest
  public static void failedMissingFieldTest() {
    Test.startTest();
    Account account = [
      SELECT PersonContactId, External_Id__c
      FROM Account
      WHERE External_Id__c = '456-654'
      LIMIT 1
    ];
    Campaign campaign = [
      SELECT Id, External_Id__c
      FROM Campaign
      WHERE Name = 'TestCampaign'
      LIMIT 1
    ];

    String correctBody =
      '{"accountid":"' +
      account.External_Id__c +
      '","campaignid":"' +
      campaign.External_Id__c +
      '","results":[{"rank":1,"name":"JacobsBaristaEditionsEspresso","value":"8711000891736","Properties":[{"name":"outputGrindSize","value":"fine"},{"name":"outputGrindSizeText","value":"Grindsizeaffectsthespeedatwhichthewatergoesthroughthegroundcoffeeandextractstheflavours."},{"name":"outputDrinkVolume","value":"short"},{"name":"outputDrinkVolumeText","value":"Thevolumeofwateraffectsthecoffee-to-waterratioinyourcupandthetasteintensity."},{"name":"ourputCoffeeStrength","value":"mild"},{"name":"outputCoffeeStrenthText","value":"Theamountofcoffeeusedforthebrewdeterminesthecoffeestrengthandthetasteintensityinyourcup."}]},{"rank":2,"name":"JacobsBaristaEditionsCrema","value":"8711000891704","Properties":[{"name":"outputGrindSize","value":"standard"},{"name":"outputGrindSizeText","value":"Grindsizeaffectsthespeedatwhichthewatergoesthroughthegroundcoffeeandextractstheflavours."},{"name":"outputDrinkVolume","value":"standard"},{"name":"outputDrinkVolumeText","value":"Thevolumeofwateraffectsthecoffee-to-waterratioinyourcupandthetasteintensity."},{"name":"ourputCoffeeStrength","value":"standard"},{"name":"outputCoffeeStrenthText","value":"Theamountofcoffeeusedforthebrewdeterminesthecoffeestrengthandthetasteintensityinyourcup."}]}],"questions":[{"title":"Chooseyourcoffeebeans","question_id":"1","answers":[{"title":"JacobsBaristaEditionsCrema","answer_id":"1","selected":false,"value":null},{"title":"JacobsBaristaEditionsCremaIntense","answer_id":"2","selected":false,"value":null},{"title":"JacobsBaristaEditionsEspresso","answer_id":"3","selected":true,"value":null}]},{"title":"Chooseyourfavouritecoffee","question_id":"2","answers":[{"title":"Capuccino","answer_id":"4","selected":false,"value":null},{"title":"Americano","answer_id":"5","selected":true,"value":null},{"title":"Espresso","answer_id":"6","selected":false,"value":null}]},{"title":"Selectvolumecontrol","question_id":"3","answers":[{"title":"Yes","answer_id":"7","selected":false,"value":null},{"title":"No","answer_id":"8","selected":true,"value":null}]}]}';
    mockPOSTRequest(correctBody);

    SurveyCampaignResponse response = SurveyCampaignRESTResource.save();
    System.assertEquals(
      response.error,
      'Missing one of the following mandatory fields: accountId, campaignProfileId, campaignId, results or questions'
    );
    System.assertEquals(response.message, null, 'message should be null');
    System.assertEquals(response.success, false, 'success should be false');
    System.Debug(response);

    Test.stopTest();
  }

  @isTest
  public static void insertCorrectCallTwiceIntegrationTest() {
    String campaignprofileid = '123-123-123-123';

    Test.startTest();
    Account account = [
      SELECT PersonContactId, External_Id__c
      FROM Account
      WHERE External_Id__c = '456-654'
      LIMIT 1
    ];
    Campaign campaign = [
      SELECT Id, External_Id__c
      FROM Campaign
      WHERE Name = 'TestCampaign'
      LIMIT 1
    ];

    String correctBody =
      '{ "campaignprofileid": "' +
      campaignprofileid +
      '", "accountid": "' +
      account.External_Id__c +
      '", "campaignid": "' +
      campaign.External_Id__c +
      '", "results": [ { "rank": 1, "name": "Jacobs Barista Editions Espresso", "value": "8711000891736", "Properties": [ { "name": "outputGrindSize", "value": "fine" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "short" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "mild" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] }, { "rank": 2, "name": "Jacobs Barista Editions Crema", "value": "8711000891704", "Properties": [ { "name": "outputGrindSize", "value": "standard" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "standard" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "standard" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] } ], "questions": [ { "title": "Choose your coffee beans", "question_id": "1", "answers": [ { "title": "Jacobs Barista Editions Crema", "answer_id": "1", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Crema Intense", "answer_id": "2", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Espresso", "answer_id": "3", "selected": true, "value": null } ] }, { "title": "Choose your favourite coffee", "question_id": "2", "answers": [ { "title": "Capuccino", "answer_id": "4", "selected": false, "value": null }, { "title": "Americano", "answer_id": "5", "selected": true, "value": null }, { "title": "Espresso", "answer_id": "6", "selected": false, "value": null } ] }, { "title": "Select volume control", "question_id": "3", "answers": [ { "title": "Yes", "answer_id": "7", "selected": false, "value": null }, { "title": "No", "answer_id": "8", "selected": true, "value": null } ] } ] }';
    mockPOSTRequest(correctBody);

    SurveyCampaignResponse response1 = SurveyCampaignRESTResource.save();
    SurveyCampaignResponse response2 = SurveyCampaignRESTResource.save();

    if (response1.success == true && response2.success == true) {
      List<Survey_Campaign_Profile__c> surveyCampaignProfile = [
        SELECT campaignprofileid__c, CampaignId__c, ContactId__c
        FROM Survey_Campaign_Profile__c
        WHERE campaignprofileid__c = :campaignprofileid
      ];
      System.assertEquals(
        surveyCampaignProfile.size(),
        1,
        'Survey_Campaign_Profile__c did not return the correct number of records'
      );
    } else {
      System.assertEquals(response1.success, true, 'Response 1 has failed');
      System.assertEquals(response2.success, true, 'Response 2 has failed');
    }

    Test.stopTest();
  }

  @isTest
  public static void emptyResultTest() {
    String campaignprofileid = '123-123-123-123';

    Test.startTest();
    Account account = [
      SELECT PersonContactId, External_Id__c
      FROM Account
      WHERE External_Id__c = '456-654'
      LIMIT 1
    ];
    Campaign campaign = [
      SELECT Id, External_Id__c
      FROM Campaign
      WHERE Name = 'TestCampaign'
      LIMIT 1
    ];

    String correctBody =
      '{ "campaignprofileid": "' +
      campaignprofileid +
      '", "accountid": "' +
      account.External_Id__c +
      '", "campaignid": "' +
      campaign.External_Id__c +
      '", "results": [ { "rank": 1, "name": "Jacobs Barista Editions Espresso", "value": "8711000891736", "Properties": [ { "name": "outputGrindSize", "value": "fine" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "short" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "mild" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] }, { "rank": 2, "name": "", "value": "8711000891704", "Properties": [ { "name": "outputGrindSize", "value": "standard" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "standard" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "standard" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] } ], "questions": [ { "title": "Choose your coffee beans", "question_id": "1", "answers": [ { "title": "Jacobs Barista Editions Crema", "answer_id": "1", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Crema Intense", "answer_id": "2", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Espresso", "answer_id": "3", "selected": true, "value": null } ] }, { "title": "Choose your favourite coffee", "question_id": "2", "answers": [ { "title": "Capuccino", "answer_id": "4", "selected": false, "value": null }, { "title": "Americano", "answer_id": "5", "selected": true, "value": null }, { "title": "Espresso", "answer_id": "6", "selected": false, "value": null } ] }, { "title": "Select volume control", "question_id": "3", "answers": [ { "title": "Yes", "answer_id": "7", "selected": false, "value": null }, { "title": "No", "answer_id": "8", "selected": true, "value": null } ] } ] }';
    mockPOSTRequest(correctBody);

    SurveyCampaignResponse response = SurveyCampaignRESTResource.save();
    System.assertEquals(
      response.error,
      'Missing one of the following mandatory field in the results attribute: rank, name, value, properties'
    );
    System.assertEquals(response.message, null, 'message should be null');
    System.assertEquals(response.success, false, 'success should be false');
    System.Debug(response);

    Test.stopTest();
  }

  @isTest
  public static void emptyResultPropertyTest() {
    String campaignprofileid = '123-123-123-123';

    Test.startTest();
    Account account = [
      SELECT PersonContactId, External_Id__c
      FROM Account
      WHERE External_Id__c = '456-654'
      LIMIT 1
    ];
    Campaign campaign = [
      SELECT Id, External_Id__c
      FROM Campaign
      WHERE Name = 'TestCampaign'
      LIMIT 1
    ];

    String correctBody =
      '{ "campaignprofileid": "' +
      campaignprofileid +
      '", "accountid": "' +
      account.External_Id__c +
      '", "campaignid": "' +
      campaign.External_Id__c +
      '", "results": [ { "rank": 1, "name": "Jacobs Barista Editions Espresso", "value": "8711000891736", "Properties": [ { "name": "outputGrindSize", "value": "fine" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "short" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "mild" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] }, { "rank": 2, "name": "Some name", "value": "8711000891704", "Properties": [ { "name": "", "value": "standard" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "standard" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "standard" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] } ], "questions": [ { "title": "Choose your coffee beans", "question_id": "1", "answers": [ { "title": "Jacobs Barista Editions Crema", "answer_id": "1", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Crema Intense", "answer_id": "2", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Espresso", "answer_id": "3", "selected": true, "value": null } ] }, { "title": "Choose your favourite coffee", "question_id": "2", "answers": [ { "title": "Capuccino", "answer_id": "4", "selected": false, "value": null }, { "title": "Americano", "answer_id": "5", "selected": true, "value": null }, { "title": "Espresso", "answer_id": "6", "selected": false, "value": null } ] }, { "title": "Select volume control", "question_id": "3", "answers": [ { "title": "Yes", "answer_id": "7", "selected": false, "value": null }, { "title": "No", "answer_id": "8", "selected": true, "value": null } ] } ] }';
    mockPOSTRequest(correctBody);

    SurveyCampaignResponse response = SurveyCampaignRESTResource.save();
    System.assertEquals(
      response.error,
      'Missing one of the following mandatory field in the results properties attribute: name, value'
    );
    System.assertEquals(response.message, null, 'message should be null');
    System.assertEquals(response.success, false, 'success should be false');
    System.Debug(response);

    Test.stopTest();
  }

  @isTest
  public static void emptyQuestionTest() {
    String campaignprofileid = '123-123-123-123';

    Test.startTest();
    Account account = [
      SELECT PersonContactId, External_Id__c
      FROM Account
      WHERE External_Id__c = '456-654'
      LIMIT 1
    ];
    Campaign campaign = [
      SELECT Id, External_Id__c
      FROM Campaign
      WHERE Name = 'TestCampaign'
      LIMIT 1
    ];

    String correctBody =
      '{ "campaignprofileid": "' +
      campaignprofileid +
      '", "accountid": "' +
      account.External_Id__c +
      '", "campaignid": "' +
      campaign.External_Id__c +
      '", "results": [ { "rank": 1, "name": "Jacobs Barista Editions Espresso", "value": "8711000891736", "Properties": [ { "name": "outputGrindSize", "value": "fine" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "short" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "mild" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] }, { "rank": 2, "name": "Jacobs Barista Editions Crema", "value": "8711000891704", "Properties": [ { "name": "outputGrindSize", "value": "standard" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "standard" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "standard" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] } ], "questions": [ { "title": "", "question_id": "1", "answers": [ { "title": "Jacobs Barista Editions Crema", "answer_id": "1", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Crema Intense", "answer_id": "2", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Espresso", "answer_id": "3", "selected": true, "value": null } ] }, { "title": "Choose your favourite coffee", "question_id": "2", "answers": [ { "title": "Capuccino", "answer_id": "4", "selected": false, "value": null }, { "title": "Americano", "answer_id": "5", "selected": true, "value": null }, { "title": "Espresso", "answer_id": "6", "selected": false, "value": null } ] }, { "title": "Select volume control", "question_id": "3", "answers": [ { "title": "Yes", "answer_id": "7", "selected": false, "value": null }, { "title": "No", "answer_id": "8", "selected": true, "value": null } ] } ] }';
    mockPOSTRequest(correctBody);

    SurveyCampaignResponse response = SurveyCampaignRESTResource.save();
    System.assertEquals(
      response.error,
      'Missing one of the following mandatory field in the questions attribute: title, question_id or answers'
    );
    System.assertEquals(response.message, null, 'message should be null');
    System.assertEquals(response.success, false, 'success should be false');
    System.Debug(response);

    Test.stopTest();
  }

  @isTest
  public static void emptyQuestionAnswerTest() {
    String campaignprofileid = '123-123-123-123';

    Test.startTest();
    Account account = [
      SELECT PersonContactId, External_Id__c
      FROM Account
      WHERE External_Id__c = '456-654'
      LIMIT 1
    ];
    Campaign campaign = [
      SELECT Id, External_Id__c
      FROM Campaign
      WHERE Name = 'TestCampaign'
      LIMIT 1
    ];

    String correctBody =
      '{ "campaignprofileid": "' +
      campaignprofileid +
      '", "accountid": "' +
      account.External_Id__c +
      '", "campaignid": "' +
      campaign.External_Id__c +
      '", "results": [ { "rank": 1, "name": "Jacobs Barista Editions Espresso", "value": "8711000891736", "Properties": [ { "name": "outputGrindSize", "value": "fine" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "short" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "mild" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] }, { "rank": 2, "name": "Jacobs Barista Editions Crema", "value": "8711000891704", "Properties": [ { "name": "outputGrindSize", "value": "standard" }, { "name": "outputGrindSizeText", "value": "Grind size affects the speed at which the water goes through the ground coffee and extracts the flavours." }, { "name": "outputDrinkVolume", "value": "standard" }, { "name": "outputDrinkVolumeText", "value": "The volume of water affects the coffee-to-water ratio in your cup and the taste intensity." }, { "name": "ourputCoffeeStrength", "value": "standard" }, { "name": "outputCoffeeStrenthText", "value": "The amount of coffee used for the brew determines the coffee strength and the taste intensity in your cup." } ] } ], "questions": [ { "title": "Choose your coffee beans", "question_id": "1", "answers": [ { "title": "", "answer_id": "1", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Crema Intense", "answer_id": "2", "selected": false, "value": null }, { "title": "Jacobs Barista Editions Espresso", "answer_id": "3", "selected": true, "value": null } ] }, { "title": "Choose your favourite coffee", "question_id": "2", "answers": [ { "title": "Capuccino", "answer_id": "4", "selected": false, "value": null }, { "title": "Americano", "answer_id": "5", "selected": true, "value": null }, { "title": "Espresso", "answer_id": "6", "selected": false, "value": null } ] }, { "title": "Select volume control", "question_id": "3", "answers": [ { "title": "Yes", "answer_id": "7", "selected": false, "value": null }, { "title": "No", "answer_id": "8", "selected": true, "value": null } ] } ] }';
    mockPOSTRequest(correctBody);

    SurveyCampaignResponse response = SurveyCampaignRESTResource.save();
    System.assertEquals(
      response.error,
      'Missing one of the following mandatory field in the questions answers attribute: title, answer_id, selected'
    );
    System.assertEquals(response.message, null, 'message should be null');
    System.assertEquals(response.success, false, 'success should be false');
    System.Debug(response);

    Test.stopTest();
  }
}
