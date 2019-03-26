@isTest
private class SiteTriggerHandlerTest {

    private static testMethod void testMethod1() {
        
        List<Account> accList = TestUtil.getAccounts(2, true);
        
        List<User> usrList = [SELECT Id FROM User WHERE IsActive = TRUE AND ContactId != NULL LIMIT 2];
        AccountShare accShare = new AccountShare( UserOrGroupId = usrList[0].Id, AccountId = accList[0].Id, AccountAccessLevel = 'Read',
        OpportunityAccessLevel = 'None', CaseAccessLevel = 'Read', ContactAccessLevel = 'Read');
        insert accShare;
       
        List<Project__c> projects = TestUtil.getProjects(2, accList[0], true);
        
        Sites__c site = new Sites__c(Name='Test Site', Project__c=projects[0].Id);
        insert site;
        
        site.Submitter__c = usrList[1].Id;
        update site;
    }
}