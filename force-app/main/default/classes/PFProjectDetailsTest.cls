@isTest
private class PFProjectDetailsTest 
{
    @testSetup static void setUpMethod()
    {
        PFTestUtility.initCustomSetting();
    }

    @isTest
    static void getClubID()
    {
        RecordType l_club_location  = PFTestUtility.getLocationRT();

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
        l_open_club.Group_Name__c = g.id;
        insert l_open_club;

        Project__c l_project = new Project__c();
        l_project.Name = 'PF Open Club Project';
        l_project.Club_Location__c = l_open_club.id;
        l_project.Scope_Type__c = 'New - Franchisee';        
        insert l_project;

        Test.startTest();
            PFProjectDetailsController controller = new PFProjectDetailsController( new ApexPages.StandardController( l_project ));
            System.assertEquals( controller.club_id , l_open_club.id );
        Test.stopTest();
	}
}