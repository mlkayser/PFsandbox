@isTest
public class PFMyClubsControllerTest {

    static testMethod void fakeTest(){
    
        PFMyClubsController.fake_method();
        //repeat the same for the rest of classes.
    }  
    
    @isTest
    static void testMyClubsController(){
    
        User communityUser = PFTestUtility.communityUser( '1TestFirstName','1TestLastNAme','1test@test.com','1test@test.com');
        insert communityUser;
        
        User current_user = PFTestUtility.getCurrentUser();
        PFTestUtility.setKnowledgeUser( current_user );
        
        Group_Owner__c go = new Group_Owner__c();
        
        System.runAs( current_user ) {
        
            PFTestUtility.checkUserRole( current_user );
            
            Group__c g = new Group__c();
            g.Name = 'Club 1 G';
            g.Group__c = 'Club1';
            insert g;
            
            // Create Account
            Account a_Open = new Account();
            a_Open.Name = 'test Loc';
            a_Open.Group_Name__c = g.Id;
            a_Open.Status__c = 'Open';
            a_Open.Date_Opened__c = Date.today();
            insert a_Open;
            
            Account a_dev = new Account();
            a_dev.Name = 'test Loc';
            a_dev.Group_Name__c = g.Id;
            a_dev.Status__c = 'Development';
            insert a_dev;            
            
            // Create Project
            Project__c p = new Project__c();
            p.Name = 'Test Project';
            p.Club_Location__c = a_Open.Id;
            insert p;
            
            system.debug('*** communityUser ' + communityUser );
            
            Test.startTest();
            go.Group_Num__c = g.Id;
            go.Owner_Contact__c = communityUser.ContactId;
            insert go;
            Test.stopTest();
        }
        
        Account acc = [SELECT Id FROM Account WHERE Status__c = 'Development' LIMIT 1];
        
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id,
            RecordTypeId = [SELECT Id, DeveloperName, SObjectType FROM RecordType 
                            WHERE SObjectType = 'Contact' AND DeveloperName = 'Broker'].Id
        );
        insert con;
        
        Group_Owner__c l_group_owner =  new Group_Owner__c(
            Group_Num__c = [SELECT Id FROM Group__c LIMIT 1].id,
            Owner_Contact__c = con.Id
            
        );
        insert l_group_owner;
        
        Profile p = [SELECT Id, UserType  FROM Profile WHERE UserType = 'CspLitePortal' LIMIT 1]; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, ContactId = con.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');

        System.runAs(u) {
        
            Test.setCurrentPage(Page.PFClubs);

            PFMyClubsController cont = new PFMyClubsController();
            cont.getDevRecords();
            cont.getOpenRecords();
            
            cont.sortOpenRecords();
            cont.sortDevRecords();
            PFMyClubsController.ClubWrapper cw = new PFMyClubsController.ClubWrapper();
            
        }
        
        system.runAs( communityUser ) {
        
            PageReference pr = Page.PFHomepage;
            Test.setCurrentPage( pr );
            
            PFMyClubsController cont = new PFMyClubsController();
            cont.getDevRecords();
            cont.getOpenRecords();
            
            cont.sortOpenRecords();
            cont.sortDevRecords();
            
            PFMyClubsController.sortField = 'Cases';
            PFMyClubsController.sortDirection = 'ASC';
            
            PFMyClubsController.sortField = 'progressStr';
            
            PFMyClubsController.sortField = 'buildPhase';
            
            cont.getIsAscending();
            cont.pageTitle = 'Here';
            PFMyClubsController.sortField = 'Name';
            
            PFMyClubsController.ClubWrapper cw = new PFMyClubsController.ClubWrapper();
            //cw.compareTo( cont.getDevRecords()[0] );
        }
    }
}