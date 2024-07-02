/*********************************************************************
Name    :       TestDataBuilder
Date    :       20 June 2017
Author  :       Anjerico Caburnay
Description:    Test Date Builder for Trigger Handlers
History :       
*********************************************************************/

@isTest
public class TestDataBuilder {
    //Dynamic method to get Record type id
    public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName){
       //Generate a map of tokens for all the Record Types for the desired object
       Map<String, Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();

       //Retrieve the record type id by name
       return recordTypeInfo.get(recordTypeName).getRecordTypeId();
    }
    
	//Returns ProfileId
    public static string getUserProfileId(String profileName){
        Profile myProfileNotA = [SELECT id FROM PROFILE WHERE Name=: profileName limit 1];
        return myProfileNotA.Id;
    }
    
    //Returns User 
    public static User createUser(Integer i, string ProfID){
        Integer randomNumber = Integer.valueof((math.random() * 10));
        User user = new User(
            Alias = 'tstUser' + i,
            Email = 'tstUser' + i + '@email.com.12312423412432',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User' + i,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = ProfID,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'tstUser' + i + '@email.com.de.uk.12312423412432' + randomNumber,
            isActive = true
        );
        return user;
    }

    //Returns Account
    public static Account createAccount(){
        Account myAccount = new Account(
        	LastName = 'Test Account'
        );
        return myAccount; 
    }

}