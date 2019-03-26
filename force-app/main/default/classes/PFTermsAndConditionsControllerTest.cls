@isTest
public class PFTermsAndConditionsControllerTest {

    @isTest
    static void testPFTermsAndConditionsController(){
       
        String randomKey = '-' + String.valueOf( Integer.valueOf( Math.random() * 1000 ) ) + '-test';
        Id RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Terms & Conditions').getRecordTypeId();
        System.debug('RecordTypeId=' + RecordTypeId);
       
        User current_user = PFTestUtility.getCurrentUser();
        PFTestUtility.setKnowledgeUser(current_user);       
        User communityUser = createCommunityUser();
        //PFTestUtility.setKnowledgeUser(communityUser);

        system.runAs(current_user){ 
            PFTestUtility.checkUserRole( current_user );
            //communityUser = createCommunityUser();

            // Create Group
            Group__c g = new Group__c();
            g.Name = 'Club 1 G';
            g.Group__c = 'Club1';
            insert g;
            
            // Create Group Owner
            Group_Owner__c go = new Group_Owner__c();
            go.Group_Num__c = g.Id;
            go.Owner_Contact__c = communityUser.ContactId;
            insert go;
            
            // Create Account
            Account a_Open = new Account();
            a_Open.Name = 'test Loc';
            a_Open.Group_Name__c = g.Id;
            a_Open.Status__c = 'Open';
            a_Open.Date_Opened__c = Date.today();
            a_Open.Group_Name__c = g.id;
            insert a_Open;
            
            // Create Project
            Project__c p = new Project__c();
            p.Name = 'Test Project';
            p.Club_Location__c = a_Open.Id;
            insert p;

            Knowledge__kav tcKav = new Knowledge__kav(); 
            tcKav.title = 'test article';
            tcKav.Summary = 'Sample article';
            tcKav.Content__c = 'Sample article content';
            tcKav.Language = 'en_US';
            tcKav.UrlName = 'Terms-and-Conditions' + randomKey;
            tcKav.RecordTypeId = RecordTypeId;
            insert tcKav;

            //retrieve master article Id created on Terms_Conditions__kav record 
            //insertion in order to get the KnowledgeArticleId
            tcKav = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :tcKav.Id];

            //publish it
            KbManagement.PublishingService.publishArticle(tcKav.KnowledgeArticleId, true);        
        }		
 
        Test.startTest();
            system.runAs(communityUser){
            	PageReference pr = Page.PFHomepage;
            	Test.setCurrentPage( pr );
            
            	PFTermsAndConditionsController cont = new PFTermsAndConditionsController();        	
            	cont.updateTermsAcceptance();

            	System.assertEquals(true, cont.u.Are_Terms_and_Conditions_Accepted__c);
            	System.assertNotEquals(null, cont.u.Date_Time_Terms_and_Conditions_Accepted__c);
            }
        Test.stopTest();
    }
    
    private static User createCommunityUser(){
        // Create Group
        Group__c g = new Group__c(
    			Name = 'Test Group',
        		Group__c = 'G0001');
    	insert g;
        
        // Create Account
        Account a = new Account();
        a.Name = 'Owner Holding Account';
        a.Group_Name__c = g.id;
        insert a;
        
        // Create Contact
        Contact c = new Contact();
        c.LastName = 'Communiy Contact';
        c.accountId = a.Id;
        c.RecordTypeId = [select Id from RecordType where Name = 'Owner Contact' and sObjectType = 'Contact'].Id;
        insert c;
        
        // Create User        
       	//Profile p = [select Id from profile where Name = 'Customer Community User - Franchisee' limit 1];        
       	Profile p = [SELECT Id FROM profile WHERE Name = 'Customer Community User - Legal Owner' limit 1];                
        User u = new User( 
            alias = 'standt', 
            email = 'test.test@testCommunity.com',
	        emailencodingkey = 'UTF-8', 
            firstname = 'test', 
            lastname = 'CommunityUser', 
            languagelocalekey = 'en_US',
	        localesidkey = 'en_US', 
            profileid = p.Id, 
            contactId = c.Id,            
            timezonesidkey = 'America/Los_Angeles', 
            username = 'test.test@testCommunity.com',            
            CommunityNickname = 'testUser123', 
            IsActive = true
        );        
        insert u; 
        
        return u;        
    }

}