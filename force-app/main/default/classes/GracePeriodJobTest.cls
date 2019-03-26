@isTest
private class GracePeriodJobTest {
    static testMethod void testBatchJob() {
        // Insert Custom Settings
    	TestUtil.insertCustomSettings();

        Group__c g = new Group__c(
    			Name = 'Test Group',
        		Group__c = 'G0001');
    	insert g;
        
        Account account = new Account(
        		Name='TestAccount',
        		PF_Club_ID__c = '1234',
        		Group_Name__c = g.id);
        insert account;
        
    	// Create account record 
		//Account account = TestUtil.getAccounts(1, true)[0];
		//System.assert(account.Id != null , 'An error occurred while creating accounts');

		// Create project record under account
		Project__c project = TestUtil.getProjects(1, account, false )[0];
		project.Open_Date_Status__c = 'Estimate';
        project.Scope_Type__c = 'New - Franchisee';
		insert project;

		System.assert(project.Id != null , 'An error occurred while creating project');

		// Create agreement record 
		PFAgreement__c agreement = TestUtil.getAgreements(1, true)[0] ;
		System.assert(agreement.Id != null , 'An error occurred while creating agreement');

		// Create grace period
		Grace_Period__c gp = TestUtil.getGracePeriods(1, agreement, true)[0];
		System.assert(gp.Id != null , 'An error occurred while creating grace perior');

		// Create schedule record under Account & Agreement
		ADA_Schedule__c schedule1 = TestUtil.getSchedules(1, agreement, account, false)[0];
		ADA_Schedule__c schedule2 = TestUtil.getSchedules(1, agreement, account, false)[0];
		schedule1.Development_Obligation_Date__c = Date.today().addDays(-1);
		schedule1.Grace_Period__c = gp.Id;

		schedule2.Development_Obligation_Date__c = Date.today().addDays(-1);
		schedule2.Grace_Period__c = gp.Id;

		List<ADA_Schedule__c> schedules = new List<ADA_Schedule__c>{schedule1, schedule2};
		insert schedules;

		Test.startTest();
			new GracePeriodJob().execute(null);
		Test.stopTest();
		System.assert([select Id, Default_Start_Date__c, Development_Obligation_Status__c from ADA_Schedule__c where Id in :schedules 
						and Development_Obligation_Status__c = 'Default'].size() == 2, 'All schedules should be set to default');
    }
}