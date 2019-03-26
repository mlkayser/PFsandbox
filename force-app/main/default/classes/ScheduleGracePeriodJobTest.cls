@isTest
private class ScheduleGracePeriodJobTest {
    static testMethod void testBatchJob0GPLimit() {
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

		// Create project record under account
		Project__c project = TestUtil.getProjects(1, account, false )[0];
		project.Open_Date_Status__c = 'Estimate';
		insert project;

		System.assert(project.Id != null , 'An error occurred while creating project');

		// Create agreement record 
		PFAgreement__c agreement = TestUtil.getAgreements(1, true)[0] ;

		System.assert(agreement.Id != null , 'An error occurred while creating agreement');

		// Create schedule record under Account & Agreement
		ADA_Schedule__c schedule1 = TestUtil.getSchedules(1, agreement, account, false)[0];
		ADA_Schedule__c schedule2 = TestUtil.getSchedules(1, agreement, account, false)[0];
		ADA_Schedule__c schedule3 = TestUtil.getSchedules(1, agreement, account, false)[0];
		schedule1.Development_Obligation_Date__c = Date.today().addDays(-1);
		schedule2.Development_Obligation_Date__c = Date.today().addDays(-1);
		schedule3.Development_Obligation_Date__c = Date.today().addDays(-2);

		List<ADA_Schedule__c> schedules = new List<ADA_Schedule__c>{schedule1, schedule2, schedule3};
		insert schedules;

		Test.startTest();
			new ScheduleGracePeriodJob().execute(null);
		Test.stopTest();

		System.assert([select Id, Default_Start_Date__c, Development_Obligation_Status__c from ADA_Schedule__c where Id in :schedules 
						and Development_Obligation_Status__c = 'Default'].size() == 3, 'All schedules should be set to default');
    }

    static testMethod void testBatchJob1GPLimit() {
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

		// Create project record under account
		Project__c project = TestUtil.getProjects(1, account, false )[0];
		project.Open_Date_Status__c = 'Estimate';
		insert project;

		System.assert(project.Id != null , 'An error occurred while creating project');

		// Create agreement record 
		PFAgreement__c agreement = TestUtil.getAgreements(1, false)[0] ;
		agreement.Number_of_Allowed_Grace_Periods__c = 1;
		insert agreement;

		System.assert(agreement.Id != null , 'An error occurred while creating agreement');

		// Create schedule record under Account & Agreement
		ADA_Schedule__c schedule1 = TestUtil.getSchedules(1, agreement, account, false)[0];
		ADA_Schedule__c schedule2 = TestUtil.getSchedules(1, agreement, account, false)[0];
		ADA_Schedule__c schedule3 = TestUtil.getSchedules(1, agreement, account, false)[0];
		schedule1.Development_Obligation_Date__c = Date.today().addDays(-1);
		schedule2.Development_Obligation_Date__c = Date.today().addDays(-1);
		schedule3.Development_Obligation_Date__c = Date.today().addDays(-2);

		List<ADA_Schedule__c> schedules = new List<ADA_Schedule__c>{schedule1, schedule2, schedule3};
		insert schedules;

		Test.startTest();
			new ScheduleGracePeriodJob().execute(null);
		Test.stopTest();

		System.assert([select Id, Default_Start_Date__c, Development_Obligation_Status__c from ADA_Schedule__c where Id in :schedules 
						and Grace_Period__c != null].size() == 2, 'Only schedule should be set to default');
    }


    static testMethod void testBatchJob3GPLimit() {
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

		// Create project record under account
		Project__c project = TestUtil.getProjects(1, account, false )[0];
		project.Open_Date_Status__c = 'Estimate';
		insert project;

		System.assert(project.Id != null , 'An error occurred while creating project');

		// Create agreement record 
		PFAgreement__c agreement = TestUtil.getAgreements(1, false)[0] ;
		agreement.Number_of_Allowed_Grace_Periods__c = 3;
		insert agreement;

		System.assert(agreement.Id != null , 'An error occurred while creating agreement');

		// Create schedule record under Account & Agreement
		ADA_Schedule__c schedule1 = TestUtil.getSchedules(1, agreement, account, false)[0];
		ADA_Schedule__c schedule2 = TestUtil.getSchedules(1, agreement, account, false)[0];
		ADA_Schedule__c schedule3 = TestUtil.getSchedules(1, agreement, account, false)[0];
		schedule1.Development_Obligation_Date__c = Date.today().addDays(-1);
		schedule2.Development_Obligation_Date__c = Date.today().addDays(-1);
		schedule3.Development_Obligation_Date__c = Date.today().addDays(-2);

		List<ADA_Schedule__c> schedules = new List<ADA_Schedule__c>{schedule1, schedule2, schedule3};
		insert schedules;

		Test.startTest();
			new ScheduleGracePeriodJob().execute(null);
		Test.stopTest();

		System.assert([select Id, Default_Start_Date__c, Development_Obligation_Status__c from ADA_Schedule__c where Id in :schedules 
						and Grace_Period__c = null and Development_Obligation_Status__c = 'Default'].size() == 1, 'No schedule should be set to default');
    }


    static testMethod void testBatchJob3GPLimit3SameDateSch() {
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
        
		// Create project record under account
		Project__c project = TestUtil.getProjects(1, account, false )[0];
		project.Open_Date_Status__c = 'Estimate';
		insert project;

		System.assert(project.Id != null , 'An error occurred while creating project');

		// Create agreement record 
		PFAgreement__c agreement = TestUtil.getAgreements(1, false)[0] ;
		agreement.Number_of_Allowed_Grace_Periods__c = 3;
		insert agreement;

		System.assert(agreement.Id != null , 'An error occurred while creating agreement');

		// Create schedule record under Account & Agreement
		ADA_Schedule__c schedule1 = TestUtil.getSchedules(1, agreement, account, false)[0];
		ADA_Schedule__c schedule2 = TestUtil.getSchedules(1, agreement, account, false)[0];
		ADA_Schedule__c schedule3 = TestUtil.getSchedules(1, agreement, account, false)[0];
		schedule1.Development_Obligation_Date__c = Date.today().addDays(-1);
		schedule2.Development_Obligation_Date__c = Date.today().addDays(-1);
		schedule3.Development_Obligation_Date__c = Date.today().addDays(-1);

		List<ADA_Schedule__c> schedules = new List<ADA_Schedule__c>{schedule1, schedule2, schedule3};
		insert schedules;

		Test.startTest();
			new ScheduleGracePeriodJob().execute(null);
		Test.stopTest();

		System.assert([select Id, Default_Start_Date__c, Development_Obligation_Status__c from ADA_Schedule__c where Id in :schedules 
						and Development_Obligation_Status__c = 'Default'].size() == 3, 'All schedules should be set to default');
    }
}