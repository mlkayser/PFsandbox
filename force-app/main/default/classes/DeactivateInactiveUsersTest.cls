@isTest
private class DeactivateInactiveUsersTest {
	
    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

	@isTest
	static void TestDeactivateInactiveUsers() {
        // Create user records 
        Date createdDate = Date.today().addDays(-100); //created date = last modified date
        List<User> users = new List<User>();
        User userZee = new User();
        User userFranchisee = new User();
        
        // Zee users
        for (Integer ii=0; ii<5; ii++) {
            userZee = PFTestUtility.customCommunityUser(
            	'Zee-' + ii, 
            	ii + 'UserZee', 
            	'Zee-' + ii + '@noemail.com', 
            	'Zee-' + ii + '@noemail.com', 
            	'Customer Community Plus Login Zee'
            );
            users.add(userZee);
        }
        // Franchisee users
        for (Integer jj=0; jj<5; jj++) {
            userFranchisee = PFTestUtility.customCommunityUser(
            	'Franchisee-' + jj, 
            	jj + 'UserFran', 
            	'Franchisee-' + jj + '@noemail.com', 
            	'Franchisee-' + jj + '@noemail.com', 
            	'Customer Community User - Franchisee'
            );
            users.add(userFranchisee);
        }
        System.debug('**** DEBUG user list size ==>  ' + users.size());
        insert users;
        
        // Get the IDs of the users just inserted
        Map<Id, User> userMap = new Map<Id, User>(users);
        List<Id> userIds = new List<Id>(userMap.keySet());
		
        // change createdDate (createdDate=lastModifiedDate in test)
		for (Integer kk=0; kk<userIds.size(); kk++) {
			Test.setCreatedDate(userIds[kk], createdDate);
		}		

        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new DeactivateInactiveUsers());         
                
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
        // Check that the users were deactivated
        List<User> deactivatedUsers = [
        	SELECT Id 
            FROM User 
            WHERE isActive = FALSE
            AND Id IN :userIds
        ];
        System.assertEquals(UserIds.size(), deactivatedUsers.size(), 'Users not processed');
	}

}