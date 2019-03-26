@isTest
private class PFImportantDatesTest
{
	@isTest
	static void getEvents()
	{
        Event__c l_event = new Event__c();
        l_event.Event_Date__c = date.today();
        l_event.Name = 'Party Test';
        insert l_event;

        Test.startTest();

            PFImportantDatesController l_controller = new PFImportantDatesController();
            List< Event__c > recentEvents = l_controller.recentEvents;

            System.assertEquals( recentEvents.size() , 1 );

        Test.stopTest();

	}
}