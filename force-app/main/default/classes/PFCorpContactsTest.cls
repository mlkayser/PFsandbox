@isTest
private class PFCorpContactsTest {

    
    @testSetup static void setUpMethod()
    {
        PFTestUtility.initCustomSetting();
    }

    @isTest
    static void PFCorpContacts()
    {
       RecordType l_club_location  = PFTestUtility.getLocationRT();
        
        List< Account > l_club_list = new List< Account >();

        Group__c g = new Group__c(
            Name = 'Test Group',
            Group__c = 'G0001');
        insert g;
        
        Account l_open_club = new Account();
        l_open_club.RecordTypeID = l_club_location.id;
        l_open_club.Name = 'PF Open Club';
        l_open_club.PF_Club_ID__c = '0022';
        l_open_club.Status__c = 'Open';
        l_open_club.Date_Opened__c = date.today();
        l_open_club.Operations_Region__c = 'Canada';
        l_open_club.Group_Name__c = g.id;
        l_club_list.add( l_open_club );

        insert l_club_list;
        
        Account clubInfo = [select Operations_Region__c from Account limit 1];
        
        Account l_open_club2 = new Account();
        l_open_club2.Name = 'Test Account';
        l_open_club2.Operations_Region__c = 'Canada';
        l_open_club2.Group_Name__c = g.id;
        insert l_open_club2;
        
        List< Contact > l_contact_list = new List< Contact >();
        Contact l_contact = new Contact();
        l_contact.FirstName  = 'Test';
        l_contact.LastName = 'Contact';
        l_contact.Accountid= l_open_club2.id;
        l_contact_list.add( l_contact );
        insert l_contact_list;
        
        List< User > l_user_list = new List< User >();
        User l_user = new User();
        l_user = PFTestUtility.createTestUser( 'TestSecond' , 'TestUser' , 'test3@ph.com' ,'test4@ph.com' , null, null  );
        l_user.Phone = '9876543210';
        l_user.Email = 'test2@ph.com';        
        l_user_list.add( l_user );
        insert l_user_list;
        
        System.runAs(l_user_list[0]) {
            Territory2Model terModel = new Territory2Model(
                DeveloperName = 'TestTerr',
                Name = 'Test Model'
            );
            insert terModel;
            
            Territory2Type[] terType1 = [SELECT Id FROM Territory2Type LIMIT 1];
            
            Territory2 tty = new Territory2 (
                Name = 'Test Terr',
                DeveloperName = 'TestTerr',
                Territory2ModelId = terModel.Id,
                Territory2TypeId = terType1[0].Id
            );
            insert tty;
            
            UserTerritory2Association uta = new UserTerritory2Association(
                Territory2Id = tty.Id,
                UserId = l_user_list[0].Id
            );
            insert uta;
        }
        
        Group grp = new Group(
            Name = 'Test Group'
        );
        insert grp;
        
        AccountShare accShare = new AccountShare (
            AccountId = l_open_club2.Id,
            UserOrGroupId = grp.Id,
            AccountAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Edit',
            ContactAccessLevel = 'Edit'
        );
        insert accShare;
        
        PFCorpContactsController bp = new PFCorpContactsController();
        bp.accID = l_open_club2.id;
        String myString = bp.accID;
        bp.getCorporateContacts();
        
        Test.startTest();
            PFCorpContactsController l_corp_controller = new PFCorpContactsController();
            l_corp_controller.next();
            l_corp_controller.previous();
        Test.stopTest();
    }
}