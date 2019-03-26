@isTest
public class UserTriggerHandlerTest {

    @isTest
    static void syncUserDataWithContactTest(){

        User communityUser;// = PFTestUtility.communityUser('Test', 'CommunityUser', 'test@communityuser.com', 'test@communityuser.com');
        
        User current_user = PFTestUtility.getCurrentUser();
        PFTestUtility.setKnowledgeUser( current_user );
        PFTestUtility.checkUserRole(current_user);

        User_And_Contact_Field_Mapping__c setting = new User_And_Contact_Field_Mapping__c();
        setting.Name = 'Email';
        setting.Contact_Field_Name__c = 'Email';
        
        insert setting;
        communityUser = createCommunityUser(true);
        
        User currentUser = new User(Id = UserInfo.getUserId());
        currentUser.Email = 'user@test.com';
        
        Test.startTest();
            update currentUser;
        Test.stopTest();
        
        System.assert( [SELECT Email FROM Contact WHERE ID = :communityUser.ContactId].Email == currentUser.Email );
    }

    @isTest
    static void createUserSetClubAccess() {

        User community_user;
        User current_user = PFTestUtility.getCurrentUser();
        PFTestUtility.setKnowledgeUser(current_user);
        
        Group__c g = new Group__c(
            Name = 'Test Group',
            Group__c = 'G0001'
        );
        insert g;
        
        Account a = new Account( 
            Name='Club', 
            RecordTypeID = PFTestUtility.club_location_account_rt.id, 
            PF_Club_ID__c = '8888',
            Group_Name__c = g.id
        );
        insert a;
        
        Account a2 = new Account( 
            Name='Club2', 
            RecordTypeID = PFTestUtility.club_location_account_rt.id, 
            PF_Club_ID__c = '9999',
            Group_Name__c = g.id
        );
        insert a2;        

        Contact c = new Contact( 
            LastName = 'Contact Last Name', 
            AccountId = a.id, 
            RecordTypeID = PFTestUtility.contact_club_staff_rt.id 
        );
        insert c;

        System.runAs(current_user) {
            PFTestUtility.checkUserRole( current_user );

            User l_community_user = PFTestUtility.createTestUser(
                '2Name',
                '2lastName',
                'email@email.com',
                'user@name.com',
                PFTestUtility.manager_profile.Id, 
                c
            );
            insert l_community_user;

            User  u = [ 
                SELECT Id, Club_Access__c 
                FROM User 
                WHERE Id = : l_community_user.id 
            ];

            //system.assertEquals( u.Club_Access__c , a.PF_Club_ID__c );

            Contact l_contact_to_update = [ 
                SELECT Id, AccountId
                FROM Contact
                WHERE ID = :c.id 
            ];

            l_contact_to_update.AccountId = a2.id;           
            update l_contact_to_update;

            u = [ 
                SELECT Id, Club_Access__c 
                FROM User 
                WHERE Id = : l_community_user.id 
            ];

            //system.assertEquals( u.Club_Access__c , a2.PF_Club_ID__c );                
        }
    }
    
    @isTest
    static void updateACRTestMethod() {
        
        User current_user = PFTestUtility.getCurrentUser();
        
        Account a = new Account(
            Name='Owner Holding Account', 
            RecordTypeID = PFTestUtility.owner_holding_account_rt.id
        );
        insert a;
        
        RecordType contact_owner_rt = [
            SELECT id 
            FROM RecordType 
            WHERE Name=: 'Owner Contact' 
            AND SobjectType = 'Contact' 
            LIMIT 1
        ];
        
        Contact c = new Contact(
            LastName = 'Contact Last Name', 
            AccountId = a.id, 
            RecordTypeID = contact_owner_rt.id
        );
        insert c;
        
        AccountContactRole acr = new AccountContactRole(
            AccountId = a.Id, 
            ContactId = c.Id
        );
        insert acr;
         
        System.runAs(current_user) {
            
            Profile Community_profile = [
                SELECT id 
                FROM Profile 
                WHERE Name = :'Customer Community User - Broker' 
                LIMIT 1
            ];
            
            User usr = new User(
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                FirstName = 'Test',
                LastName = 'User',
                Username = 'testpfuser@testpf.testcom',
                Alias = 'UserN',
                Email = 'testpfuser@testpf.testcom',
                IsActive = true,
                ContactId = c.Id,
                CommunityNickname = 'testpfuser@testpf.testcom',
                ProfileId = Community_profile.Id
            );
            insert usr;
            
            usr.isActive = FALSE;
            update usr;
            
            usr.isActive = TRUE;
            update usr;
        }        
    }

    @isTest
    static void updateProfileInactiveCommUserTest() {

        User communityUser = createCommunityUser(TRUE);
        System.debug('*** TEST communityUser Id = ' + communityUser.id);
        System.debug('*** TEST communityUser email = ' + communityUser.email);

        User current_user = PFTestUtility.getCurrentUser(); 
        System.runAs(current_user) {
            User cUser = [
                SELECT id, isActive
                FROM User
                WHERE id = :communityUser.Id
            ];
            System.debug('*** TEST-BEFORE isActive = ' + cUser.isActive);
            cUser.isActive = FALSE;

            Test.startTest();                
                update cUser;           
            Test.stopTest();       
        
            User commUser = [
                SELECT id, SSO_Access__c, isActive, ContactId
                FROM User
                WHERE id = :communityUser.Id
            ];
            System.debug('*** TEST-AFTER isActive = ' + commUser.isActive);
            System.debug('*** TEST-AFTER SSO_Access = ' + commUser.SSO_Access__c);

            System.assertEquals(commUser.isActive, FALSE);
            System.assertEquals(commUser.SSO_Access__c, NULL);               

           Contact con = [
                SELECT id, Receive_Franchsiee_Newsletter__c
                FROM Contact
                WHERE id = :commUser.ContactId
                LIMIT 1
            ];
            
            System.debug('*** TEST-AFTER Receive_Franchsiee_Newsletter = ' + con.Receive_Franchsiee_Newsletter__c);            
            System.assertEquals(con.Receive_Franchsiee_Newsletter__c, FALSE);   
        }    
    }

    @isTest
    static void updateContactRecNewsletterTest() {

            User communityUser = createCommunityUser(TRUE);

            User current_user = PFTestUtility.getCurrentUser(); 
            System.runAs(current_user) {
                Test.startTest();
                    User cUser = [
                        SELECT id, SSO_Access__c, ContactId
                        FROM User
                        WHERE id = :communityUser.Id
                    ];

                    cUser.SSO_Access__c = 'Franchise Newsletter';
                    update cUser;
                Test.stopTest();

                Contact con = [
                    SELECT id, Receive_Franchsiee_Newsletter__c
                    FROM Contact
                    WHERE id = :cUser.ContactId
                    LIMIT 1
                ];
                
                System.debug('*** TEST-AFTER Receive_Franchsiee_Newsletter = ' + con.Receive_Franchsiee_Newsletter__c);            
                System.assertEquals(con.Receive_Franchsiee_Newsletter__c, TRUE);            
        }
    }

    private static User createCommunityUser(Boolean doInsert){
       
        RecordType accountRecType = [
            SELECT Id 
            FROM RecordType 
            //WHERE Name = 'Club Location' 
            WHERE Name = 'Owner Holding Account'
            AND sObjectType = 'Account' 
            LIMIT 1
        ];
        RecordType contactRecType = [
            SELECT Id 
            FROM RecordType 
            WHERE Name = 'Club Staff' 
            AND sObjectType = 'Contact' 
            LIMIT 1
        ];
        
        Group__c g = new Group__c(
            Name = 'Test Group',
            Group__c = 'G0001'
        );
        insert g;
        
        Account acc = new Account();
        acc.Name = 'new A';
        acc.RecordTypeId = accountRecType.Id;
        acc.Entity_Name__c = 'test ent';
        acc.Group_Name__c = g.id;
        insert acc;
        
        Contact c = new Contact();
        c.LastName = 'test';
        c.AccountId = acc.Id;
        c.RecordTypeId = contactRecType.id;
        insert c;
        
        Profile p = [
            SELECT id 
            FROM profile 
            WHERE Name = 'Customer Community User - Franchisee'
            LIMIT 1
        ];   
        
        String testemail = 'user@test.com';
        User pu = new User(
            profileId = p.id, 
            username = testemail, 
            email = testemail,             
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US',             
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias = 'cspu', 
            lastname = 'lastname', 
            contactId = c.id
        );
        
        if (doInsert) {
            Database.insert(pu);
        }
    
        return pu;
    }

}