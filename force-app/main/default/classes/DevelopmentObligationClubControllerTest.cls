@isTest
public class DevelopmentObligationClubControllerTest {
    
	@testsetup 
	static void setup() {
	    
        // create group
        Group__c grp = new Group__c(
    			Name = 'Test Group',
        		Group__c = 'G0001');
    	insert grp;

		// Create ADA record 
		PFAgreement__c ADA = TestUtil.getADAagreements(1, true)[0] ;

		// create clubs
        Account club1 = new Account(
			Name='Club1=',
        	PF_Club_ID__c = '1111',
            Status__c = 'Presale',
            Project_Open_Date__c = Date.today().addDays(10),
            Area_Development_Agreement__c = ADA.id,
        	Group_Name__c = grp.id);
		Account club2 = new Account(
			Name='Club2',
        	PF_Club_ID__c = '2222',
            Status__c = 'Active Development',
            Project_Open_Date__c = Date.today().addDays(20),
            Area_Development_Agreement__c = ADA.id,
        	Group_Name__c = grp.id);
		Account club3 = new Account(
			Name='Club3',
        	PF_Club_ID__c = '3333',
            Status__c = 'Site Planning',
            Project_Open_Date__c = Date.today().addDays(30),
            Area_Development_Agreement__c = ADA.id,
        	Group_Name__c = grp.id);                    
		Account club4 = new Account(
			Name='Club4',
        	PF_Club_ID__c = '4444',
            Status__c = 'Presale',
            Area_Development_Agreement__c = ADA.id,
       	    Group_Name__c = grp.id); 

        List<Account> clubList = new List<Account>{club1, club2, club3, club4};
        insert clubList;

		// Create schedule record under Account & ADA
		ADA_Schedule__c schedule1 = TestUtil.getSchedules(1, ADA, club1, false)[0];
		ADA_Schedule__c schedule2 = TestUtil.getSchedules(1, ADA, club2, false)[0];
		ADA_Schedule__c schedule3 = TestUtil.getSchedules(1, ADA, club3, false)[0];
		ADA_Schedule__c schedule4 = TestUtil.getSchedules(1, ADA, club4, false)[0];
		schedule1.Development_Obligation_Date__c = Date.today().addDays(100);
		schedule2.Development_Obligation_Date__c = Date.today().addDays(100);
		schedule3.Development_Obligation_Date__c = Date.today().addDays(100);
        schedule1.Development_Obligation_Status__c = 'Unmet';
        schedule2.Development_Obligation_Status__c = 'Unmet';
        schedule3.Development_Obligation_Status__c = 'Unmet';
        schedule4.Development_Obligation_Status__c = 'Unmet';

		List<ADA_Schedule__c> scheduleList = new List<ADA_Schedule__c>{schedule1, schedule2, schedule3, schedule4};
		insert scheduleList;
    }

    @isTest
    static void testAutomation() {
        DevelopmentObligationClubController cntrl = new DevelopmentObligationClubController();
        
        PFAgreement__c ADA = [
            SELECT id FROM PFAgreement__c WHERE NAME LIKE 'TestADA%' LIMIT 1
        ];
        List<ADA_Schedule__c> updatedScheduleList = [            
            SELECT id, Club__c
            FROM ADA_Schedule__c
            WHERE Area_Development_Agreement__c =: ADA.id
            ORDER BY Name
        ];
        List<Account> clubs = [
            SELECT id
            FROM Account
            WHERE Area_Development_Agreement__c =: ADA.id
            ORDER BY Name
        ];
        
        // positive test
        ADA_Schedule__c schedule1 = updatedScheduleList[0];
        Account club1 = clubs[0];
        System.assertEquals(schedule1.Club__c, club1.id);

        // negative test
        ADA_Schedule__c schedule4 = updatedScheduleList[3];
        Account club4 = clubs[3];
        System.assertNotEquals(schedule4.Club__c, club4.id);        
    }
}
