@isTest
private class PFClubsTest
{

    private static String ACC_NAME = 'PF Open Club';

    @testSetup static void setUpMethod()
    {
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
        insert l_open_club;

        Case l_case = new case();
        l_case.AccountID = l_open_club.id;
        l_case.ClosedDate = datetime.Now();
        insert l_case;
    }

	@isTest
	static void PFClubs()
	{
        User community_user ;
        community_user = PFTestUtility.communityUser( 'TestName' , 'LastNAmeTEst' , 'test@pf.com', 'test@pf.com' );
        insert community_user;
        User current_user = PFTestUtility.getCurrentUser();
        PFTestUtility.setKnowledgeUser( current_user );

        System.runAs( current_user ) 
        {
            PFTestUtility.checkUserRole( current_user );

            Group__c l_group = [Select ID From Group__c Where Name = :'12345' ];

            Group_Owner__c l_group_owner =  new Group_Owner__c();
            l_group_owner.Owner_Contact__c = community_user.ContactId;
            l_group_owner.Group_Num__c = l_group.id;
            insert l_group_owner;
        }
        
        Test.startTest();
            PFClubsController l_controller = new PFClubsController();        
        Test.stopTest();
	}

}