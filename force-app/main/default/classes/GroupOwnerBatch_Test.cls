/**
 * Created by rdiaznasser on 4/3/18.
 */

@IsTest
public class GroupOwnerBatch_Test {
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';

    public static testMethod void testExecute(){
        Test.startTest();

        // Create new Community User
        User communityUser = createCommunityUser('test@test1.com');

        // Create Group 1
        Group__c setupGroup = new Group__c();
        setupGroup.Name = 'setupGroup1';
        setupGroup.Group__c = '00001';
        insert setupGroup;

        // Create Group Owner record
        Group_Owner__c setupGroupOwner = new Group_Owner__c();
        setupGroupOwner.Group_Num__c = setupGroup.Id;
        setupGroupOwner.Owner_Contact__c = communityUser.ContactId;
        insert setupGroupOwner;

        // Create Account (Location)
        Account a = new Account();
        a.Name = 'Owner Holding Account';
        a.Group_Name__c = setupGroup.Id;
        a.Status__c = 'Open';
        a.Date_Opened__c = Date.today();
        a.POS_Club_ID__c = '1234';
        insert a;

        // Schedule the test job

        String jobId = System.schedule('testBasicScheduledApex',
                GroupOwnerBatch_Test.CRON_EXP,
                new GroupOwnerBatchSchedule());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                NextFireTime
        FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(GroupOwnerBatch_Test.CRON_EXP,
                ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00',
                String.valueOf(ct.NextFireTime));
        System.assertNotEquals('testScheduledApexFromTestMethodUpdated',
                [SELECT id, name FROM account WHERE id = :a.id].name);

        Test.stopTest();

//        System.assertEquals('testScheduledApexFromTestMethodUpdated',
//                [SELECT Id, Name FROM Account WHERE Id = :a.Id].Name);
    }


/*------------------------------------------------Utility Methods-------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------*/

    private static User createCommunityUser( String email ){
        Group__c g = new Group__c(
                Name = 'Test Group',
                Group__c = 'G0001');
        insert g;

        // Create Account
        Account a = new Account();
        a.Name = 'Owner Holding Account';
        a.Group_Name__c = g.id;
        insert a;

        Contact c = new Contact();
        c.LastName = 'Communiy Contact';
        c.accountId = a.Id;
        c.RecordTypeId = [select Id from RecordType where Name = 'Owner Contact' and sObjectType = 'Contact'].Id;
        insert c;

        Profile p = [select Id from profile where Name = 'Customer Community User - Franchisee' limit 1];

        User u = new User( alias = 'standt', email=email,
                emailencodingkey='UTF-8', lastname=email.substring(0 , 5), languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, contactId=c.Id,
                timezonesidkey='America/Los_Angeles', username=email);

        insert u;

        return u;

    }
}