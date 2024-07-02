@isTest
public class CommunityConsentLabelsSelectorTest {
	
	@isTest static void getCommunityConsentLabelsForCommunityTest() {
		Test.startTest();
		List<Community_Consent_Label__mdt> communityConsentLabels = CommunityConsentLabelsSelector.getCommunityConsentLabelsForCommunity('Maison du Cafe', 'FR');
		Test.stopTest();

		System.assert(!communityConsentLabels.isEmpty());
	}

	@isTest static void getCommunityConsentLabelsTest() {
		Test.startTest();
		Map<String, Community_Consent_Label__mdt> consentLabels = CommunityConsentLabelsSelector.getCommunityConsentLabels();
		Test.stopTest();

		System.assert(!consentLabels.isEmpty());
	}

}