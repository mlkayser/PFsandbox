@isTest
public Class PFLinksFooterSectionControllerTest {
    
    static testMethod void PFLinksFooterSectionConMtd() {
    
    
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', SSO_Access__c = 'Cognos;Marketing Cloud',
            UserName='test@pftestxyz.com.us'
        );

        System.runAs(u) {
            PFLinksFooterSectionController linkFooCon = new PFLinksFooterSectionController();
        }

         
         
    }
}