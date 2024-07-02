@isTest
public class MdCChangePasswordControllerTest {
    
    @testSetup static void setUpTestData() {
        User communityUser = new User();
        communityUser.UserName =  'test@emark.com.mdc.fr';
        communityUser.Email = 'test@emark.com';
        
        communityUser.FirstName = 'test';
        communityUser.LastName = 'test';
        
        String nickname = 'testt';
        nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
        communityUser.CommunityNickname = nickname;

        Account communityAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'test',
            LastName = 'test',
            PersonEmail = 'test@emark.com',
            Gender__pc = 'Male',
            PersonBirthdate = Date.valueOf('1990-06-03'),
            Sixteen_Years_or_Older__c = true,
            External_id__c = 'test@emark.comFRMaison du Café',
            Brand__c = 'Maison du Café',
            OwnerId = Label.CommunityOwnerID
        );

        insert communityAccount;

        Site.createExternalUser(communityUser, communityAccount.Id, 'Testing123!');
    }
    
    @isTest public static void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        PageReference pageRef = Page.MdCCommunityChangePassword;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('setupid', 'ChangePassword');
        MdCChangePasswordController controller = new MdCChangePasswordController();
        
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);                           
    }    
    
    @isTest public static void testChangePasswordDEForgotRequestController() {
        // Instantiate a new controller with all parameters in the page
        PageReference pageRef = Page.MdCCommunityChangePassword;
        Test.setCurrentPage(pageRef);
        MdCChangePasswordController controller = new MdCChangePasswordController();
        
        controller.oldPassword = '';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);                           
    }   
    
    @isTest public static void testChangePasswordPasswordsAreBlank() {
        // Instantiate a new controller with all parameters in the page
        PageReference pageRef = Page.MdCCommunityChangePassword;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('setupid', 'ChangePassword');
        MdCChangePasswordController controller = new MdCChangePasswordController();
        
        controller.oldPassword = '';
        controller.newPassword = ''; 
        controller.verifyNewPassword = '';                
        
        System.assertEquals(controller.changePassword(),null);                           
        
        controller.oldPassword = 'Test1234';
        controller.newPassword = ''; 
        controller.verifyNewPassword = '';                
        
        System.assertEquals(controller.changePassword(),null); 
        
        controller.oldPassword = 'Test1234';
        controller.newPassword = '1234'; 
        controller.verifyNewPassword = '';                
        
        System.assertEquals(controller.changePassword(),null);  
        
        controller.oldPassword = 'Test1234';
        controller.newPassword = '1234'; 
        controller.verifyNewPassword = '1234';                
        
        System.assertEquals(controller.changePassword(),null);  
        
        controller.oldPassword = 'Test1234';
        controller.newPassword = 'Teset12345'; 
        controller.verifyNewPassword = 'Test12345';                
        
        System.assertEquals(controller.changePassword(),null);  
        
        controller.oldPassword = 'Test1234';
        controller.newPassword = 'Teset12345#'; 
        controller.verifyNewPassword = 'Test12345';                
        
        System.assertEquals(controller.changePassword(),null);  
        
        controller.oldPassword = 'Test1234';
        controller.newPassword = '12345678'; 
        controller.verifyNewPassword = '12345678';      
        
        System.assertEquals(controller.changePassword(),null);  
        
        controller.oldPassword = 'Test1234';
        controller.newPassword = 'ABCDEFGHIJ'; 
        controller.verifyNewPassword = 'ABCDEFGHIJ';      
        
        System.assertEquals(controller.changePassword(),null);  
    }    
    
    @isTest public static void testChangePasswordDENonDERequestController() {
        // Instantiate a new controller with all parameters in the page
        PageReference pageRef = Page.MdCCommunityChangePassword;
        Test.setCurrentPage(pageRef);
        MdCChangePasswordController controller = new MdCChangePasswordController();
        
        controller.oldPassword = '';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);                           
    }   
    
}