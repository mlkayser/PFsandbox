@isTest
private class PFHomepageGroupHealthTest {
    private static String ACC_NAME = 'PF Open Club';

    @testSetup static void setUpMethod() {
        
        Group__c l_group = new Group__c();
        l_group.Name = '12345';
        l_group.Group__c = '12345';
        insert l_group;

        RecordType l_club_location  = PFTestUtility.getLocationRT();        
        Account l_open_club = new Account();
        l_open_club.RecordTypeID = l_club_location.id;
        l_open_club.Name = ACC_NAME;
        l_open_club.PF_Club_ID__c = '0022';
        l_open_club.Status__c = 'Open';
        l_open_club.Date_Opened__c = date.today();
        l_open_club.BCM__c = 50;
        l_open_club.Club_EFT__c = 50;
        l_open_club.EFT_Difference_Without_Tax__c = 30;
        l_open_club.EFT_Run_Date__c = date.today() -2;
        l_open_club.All_Active_Members__c = 30;
        l_open_club.Group_Name__c = l_group.id;
        l_open_club.POS_Club_ID__c = '1234';
        insert l_open_club;

        Case l_case = new case();
        l_case.AccountID = l_open_club.id;
        l_case.ClosedDate = datetime.Now();
        insert l_case;
    }

	@isTest
	static void GroupHealthTestPositiveEFT() {

        Account l_open_club = [ Select ID, Club_EFT__c,EFT_Difference_Without_Tax__c From Account Where Name = : ACC_NAME  ]; 

        Test.startTest();

            Test.setCurrentPageReference(new PageReference('Page.PFClubDetail'));
            System.currentPageReference().getParameters().put('id', l_open_club.id);

            PFHomepageGroupHealthController l_controller = new PFHomepageGroupHealthController();

            system.assertEquals( l_controller.myGroupHealth.eft.lastDraft , 30 );
            system.assertEquals( l_controller.lastDraftStatus , 1 );

        Test.stopTest();
	}

    @isTest
    static void GroupHealthTestNegativeEFT() {

        Account l_open_club = [ Select ID, Club_EFT__c,EFT_Difference_Without_Tax__c From Account Where Name = : ACC_NAME  ]; 
        l_open_club.EFT_Difference_Without_Tax__c = -70;
        update l_open_club;


        Test.startTest();

            Test.setCurrentPageReference(new PageReference('Page.PFClubDetail'));
            System.currentPageReference().getParameters().put('id', l_open_club.id);

            PFHomepageGroupHealthController l_controller = new PFHomepageGroupHealthController();

            system.assertEquals( l_controller.myGroupHealth.eft.lastDraft , 70 );
            system.assertEquals( l_controller.lastDraftStatus , -1 );

        Test.stopTest();
    }

    @isTest
    static void GroupHealthTestNoEFT() {

        Account l_open_club = [ Select ID, Club_EFT__c,EFT_Difference_Without_Tax__c From Account Where Name = : ACC_NAME  ]; 
        l_open_club.EFT_Difference_Without_Tax__c = 0;
        update l_open_club;

        Test.startTest();

            Test.setCurrentPageReference(new PageReference('Page.PFClubDetail'));
            System.currentPageReference().getParameters().put('id', l_open_club.id);

            PFHomepageGroupHealthController l_controller = new PFHomepageGroupHealthController();

            system.assertEquals( l_controller.myGroupHealth.eft.lastDraft , 0 );
            system.assertEquals( l_controller.lastDraftStatus , 0 );

        Test.stopTest();
    }

    @isTest
    static void GroupHealthTestHomePage() {
        User community_user ;
        User current_user = PFTestUtility.getCurrentUser();
        PFTestUtility.setKnowledgeUser( current_user );

        System.runAs( current_user ) {

            PFTestUtility.checkUserRole( current_user );

            community_user = PFTestUtility.communityUser( 'TestName' , 'LastNAmeTEst' , 'test@pf.com', 'test@pf.com' );
            insert community_user;

            Group__c l_group = [Select ID From Group__c Where Name = :'12345' ];

            Group_Owner__c l_group_owner =  new Group_Owner__c();
            l_group_owner.Owner_Contact__c = community_user.ContactId;
            l_group_owner.Group_Num__c = l_group.id;
            insert l_group_owner;

        }

       // System.runAs( community_user ) {
       //     Test.startTest();
       //         PFHomepageGroupHealthController l_controller = new PFHomepageGroupHealthController();
       //         system.assertEquals( l_controller.myGroupHealth.eft.lastDraft , 30 );
       //         system.assertEquals( l_controller.lastDraftStatus , 1 );
       //    Test.stopTest();
       // }

    }      
        
    @isTest
    static void GroupHealthSocial() {
		ApexPages.currentPage().getParameters().put('Facebook','123456');
        PFHomepageGroupHealthController obj = new PFHomepageGroupHealthController();
    }    
}