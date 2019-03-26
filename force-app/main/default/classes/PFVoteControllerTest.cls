@IsTest
public with sharing class PFVoteControllerTest {
    @TestSetup
    public static void init() {
        User runningAdminUser = [
                SELECT Id,Email,ContactId,ProfileId,FirstName,LastName
                FROM User
                WHERE Profile.Name = 'System Administrator'
                AND UserRoleId != NULL
                AND IsActive = TRUE
                LIMIT 1
        ];

        System.debug(runningAdminUser.FirstName + ' ' + runningAdminUser.LastName);

        Date fivedaysago = Date.today().addDays(-5);
        Date infivedays = Date.today().addDays(5);
        Poll__c p = new Poll__c(
                Name = 'Test Poll',
                Question__c = 'Is this a test poll?',
                Start_Date__c = fivedaysago,
                End_Date__c = infivedays,
                Active__c = true
        );
        insert p;

        PollOption__c po_yes = new PollOption__c(
                Name = 'Yes',
                Poll__c = p.Id
        );
        insert po_yes;

        PollOption__c po_no = new PollOption__c(
                Name = 'No',
                Poll__c = p.Id
        );
        insert po_no;

        PollResult__c pr = new PollResult__c(
                Poll__c = p.Id
        );
        insert pr;

        Group__c testGroup = new Group__c(
                Name = 'Test Group',
                //My IDE does not like that this field is named the same as the Object!
                Group__c = '1234'
        );
        insert testGroup;

        Account ownerHoldingAccount = new Account(
                Name = 'Owner Holding AccountTest',
                RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Owner_Holding_Account'][0].Id,
                OwnerId = runningAdminUser.Id
        );
        insert ownerHoldingAccount;

        Account club = new Account(
                Name = 'Test Club',
                RecordTypeId = [
                        SELECT Id
                        FROM RecordType
                        WHERE DeveloperName = 'Club_Location'
                        AND SobjectType = 'Account'
                        LIMIT 1
                ].Id,
                Group_Name__c = testGroup.Id,
                Date_Opened__c = Datetime.newInstance(2017, 1, 1),
                POS_Club_ID__c = '1234',
                PF_Club_ID__c = '1234',
                Status__c = 'Open'
        );
        insert club;

        Contact groupOwner = new Contact(
                LastName = 'Trump',
                FirstName = 'TheDonald',
                Email = 'president@whitehouse.com',
                AccountId = ownerHoldingAccount.Id,
                RecordTypeId = [
                        SELECT Id
                        FROM RecordType
                        WHERE DeveloperName = 'Owner_Contact'
                        AND SobjectType = 'Contact'
                        LIMIT 1
                ].Id
        );

        PFAgreement__c agreement = new PFAgreement__c(
                Name = 'Test Agreement',
                Club_Name__c = club.Id,
                Responsible_Owner__c = groupOwner.Id,
                RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Franchise_Agreement' LIMIT 1].Id
        );
        insert agreement;
    }

    @IsTest
    public static void getPollTest() {
        List<Poll__c> polls = PFVoteController.getActivePolls();
        System.assertEquals(1, polls.size());
        Id pollId = polls.get(0).Id;
        Poll__c poll = PFVoteController.getPoll(String.valueOf(pollId));
        System.assertEquals(pollId, poll.Id);
    }

    @IsTest
    public static void getActivePollsTest() {
        List<Poll__c> polls = PFVoteController.getActivePolls();
        System.assertEquals(1, polls.size());
    }

    @IsTest
    public static void getPollOptionsTest() {
        Poll__c p = [SELECT Id FROM Poll__c];
        List<PollOption__c> pollOptions = PFVoteController.getPollOptions(String.valueOf(p.Id));
        System.assertEquals(2, pollOptions.size());
    }

    @IsTest
    public static void getClubsTest() {
        PFVoteController.getClubs();
    }
}