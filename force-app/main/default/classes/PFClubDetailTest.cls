@isTest
private class PFClubDetailTest {

    @testSetup static void setUpMethod() {
        PFTestUtility.initCustomSetting();
    }

	@isTest
	static void clubDetail() {
        RecordType l_club_location  = PFTestUtility.getLocationRT();

        // create Group
        Group__c g = new Group__c(
    			Name = 'Test Group',
        		Group__c = 'G0001');
    	insert g;
        
        // create Account list
        List< Account > l_club_list = new List< Account >();

        Account l_open_club = new Account();
        l_open_club.RecordTypeID = l_club_location.id;
        l_open_club.Name = 'PF Open Club';
        l_open_club.PF_Club_ID__c = '0022';
        l_open_club.Status__c = 'Open';
        l_open_club.Date_Opened__c = date.today();
        l_open_club.Group_Name__c = g.id;
        l_open_club.POS_Club_ID__c = '1111';
        l_club_list.add( l_open_club );

        Account l_in_dev_club = new Account();
        l_in_dev_club.RecordTypeID = l_club_location.id;
        l_in_dev_club.Name = 'PF In Dev Club';
        l_in_dev_club.PF_Club_ID__c = '0021';
        l_in_dev_club.Status__c = 'In development';
        l_in_dev_club.Group_Name__c = g.id;
        l_in_dev_club.POS_Club_ID__c = '2222';
        l_club_list.add( l_in_dev_club );  
        insert  l_club_list;

        // create Project
        Project__c l_project = new Project__c();
        l_project.Name = 'PF Open Club Project';
        l_project.Club_Location__c = l_open_club.id;
        l_project.Scope_Type__c = 'New - Franchisee';
        insert l_project;

        // create User
        User l_user = PFTestUtility.createTestUser( 'TestFirst' , 'TestLast' , 'test1@ph.com' ,'test2@ph.com' , null, null  );
        insert l_user;

        // create Account Team Member
        List< AccountTeamMember > l_acc_team_list = new List< AccountTeamMember >();

        AccountTeamMember l_acc_member_open = new AccountTeamMember();
        //l_acc_member_open.AccountAccessLevel = 'Read';
        l_acc_member_open.AccountId = l_open_club.id;
        l_acc_member_open.TeamMemberRole = 'Brand Excellence Specialist';
        l_acc_member_open.UserId = l_user.id;
        l_acc_team_list.add( l_acc_member_open );

        AccountTeamMember l_acc_member_dev = new AccountTeamMember();
        //l_acc_member_dev.AccountAccessLevel = 'Read';
        l_acc_member_dev.AccountId = l_in_dev_club.id;
        l_acc_member_dev.TeamMemberRole = 'Operations Area Manager';
        l_acc_member_dev.UserId = l_user.id;
        l_acc_team_list.add( l_acc_member_dev );

        insert l_acc_team_list;

        Test.startTest();
            PFClubDetailController l_controller_open_club = new PFClubDetailController( new ApexPages.StandardController( l_open_club ) );
            List<Project__c> l_project_steps = l_controller_open_club.allSteps;
            //List< User > l_open_club_contact = l_controller_open_club.getCorporateContacts();
            List<String> l_status_fields  = l_controller_open_club.statusFields;
                
        List<String> l_getREStatus  = l_controller_open_club.getREStatus();
        	List<String> l_getFAStatus  = l_controller_open_club.getFAStatus();
            List<String> l_getDesignStatus  = l_controller_open_club.getDesignStatus();
            List<String> l_getPermitStatus  = l_controller_open_club.getPermitStatus();
            List<String> l_getConStatus  = l_controller_open_club.getConStatus();
            List<String> l_getEquipStatus  = l_controller_open_club.getEquipStatus();
            List<String> l_getPreStatus  = l_controller_open_club.getPreStatus();
            List<String> l_getSaleStatus  = l_controller_open_club.getSaleStatus();

            PFClubDetailController l_controller_dev_club = new PFClubDetailController( new ApexPages.StandardController( l_in_dev_club ) );

            //PFCorpContactsController l_corp_controller = new PFCorpContactsController();
            //l_corp_controller.accID = l_in_dev_club.id;
            //l_corp_controller.next();
            //l_corp_controller.previous();
            //List< User > l_dev_club_contact = l_corp_controller.getCorporateContacts();

        Test.stopTest();

        System.assertEquals( l_project_steps.size() , 1 );
        //System.assertEquals( l_open_club_contact.size() , 1 );
        //System.assertEquals( l_dev_club_contact.size() , 1 );
	}

    @isTest
    static void clubDetailImage() {
        RecordType l_club_location  = PFTestUtility.getLocationRT();

        // create Group
        Group__c g = new Group__c(
    			Name = 'Test Group',
        		Group__c = 'G0001');
    	insert g;
        
        // create Account
        Account l_open_club = new Account();
        l_open_club.RecordTypeID = l_club_location.id;
        l_open_club.Name = 'PF Open Club';
        l_open_club.PF_Club_ID__c = '0022';
        l_open_club.Status__c = 'Open';
        l_open_club.Date_Opened__c = date.today();
        l_open_club.Group_Name__c = g.id;
        l_open_club.POS_Club_ID__c = '3333';
        insert l_open_club;

        // create Club Image
        Club_Image__c l_club_image = new Club_Image__c();
        l_club_image.account__c = l_open_club.id;
        insert l_club_image;

        // create Attachment
        Attachment attach=new Attachment();     
        attach.Name=Community_Settings__c.getInstance().Club_Image_Name__c;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=l_club_image.id;
        insert attach;

        Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.PFClubDetail'));
            System.currentPageReference().getParameters().put('id', l_open_club.id);

            PFClubDetailController l_controller_open_club = new PFClubDetailController( new ApexPages.StandardController( l_open_club ) );

            system.assertEquals( l_controller_open_club.photo_id , attach.id );                  
        Test.stopTest();
    }
}