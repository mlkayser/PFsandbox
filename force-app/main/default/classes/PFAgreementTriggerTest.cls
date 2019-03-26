@isTest
public class PFAgreementTriggerTest {

    static testMethod void test1() {
        
        // get record types
        Set<String> developerNameSet =new Set<String>{
            'Broker', 
            'Area_Development_Agreement', 
            'Real_Estate_Site', 
            'Franchise_Agreement',
            'Owner_Contact',
            'Owner_Holding_Account' 
        };
        Set<String> sobjectSet = new Set<String> {'PFAgreement__c', 'Sites__c', 'Contact', 'Account'};
        Map<String, Id> rtMap = new Map<String, Id>();
        
        for (RecordType rt : [
            SELECT Id, DeveloperName, SObjectType 
            FROM RecordType 
            WHERE (DeveloperName IN :developerNameSet)
            AND (sObjectType IN :sobjectSet)
        ]) {               
            rtMap.put(rt.DeveloperName, rt.Id);
        }
        
        // create clubs associated with a single group
        List<Account> accounts = TestUtil.getAccounts(2, false);
        accounts[0].PF_Club_ID__c = '1234';
        insert accounts;
        
        // create contacts
        Contact con1 = PFTestUtility.createOwnerContact('Owner1','Test','owner1@test.com','owner1@test.com');
        Contact con2 = PFTestUtility.createOwnerContact('Owner2','Test','owner2@test.com','owner2@test.com');                   
        List<Contact> contacts = new List<Contact>();
        contacts.add(con1);
        contacts.add(con2);
        insert contacts;
        
        contacts = [
            SELECT id, firstName, lastName, email
            FROM Contact
            LIMIT 2
        ];
        System.debug('**** DEBUG Contact1 = ' + contacts[0].Id + ' ' + contacts[0].firstName + ' ' + contacts[0].email);
        System.debug('**** DEBUG Contact2 = ' + contacts[1].Id + ' ' + contacts[1].firstName + ' ' + contacts[1].email);

        // create group owners
        Id grpId = [SELECT Id FROM Group__c WHERE Name = 'Test Group' Limit 1].Id;        
        List<Group_Owner__c> groupOwner = new List<Group_Owner__c> {
            new Group_Owner__c(
                Group_Num__c  = grpId,
                Owner_Contact__c = contacts[0].Id
            ),
            new Group_Owner__c(
                Group_Num__c  = grpId,
                Owner_Contact__c = contacts[1].Id
            )
        };
        insert groupOwner;
        System.debug('**** DEBUG Group Owners  created ');


        Sharing_Wizard_Setting__c cS = new Sharing_Wizard_Setting__c (
            Error_Notification_Emails__c = 'owner1@test.com;owner2@test.com'
        );
        insert cs;
        System.debug('**** DEBUG Sharing Wizard created ');
 
        // get random community users 
        List<User> activeUsers = [
            SELECT Id, ContactId, Username, ProfileId, UserRoleId 
            FROM User 
            WHERE ContactId != NULL 
            AND IsActive = TRUE 
            LIMIT 2
        ];
        System.debug('**** DEBUG User1.ContactId = ' + activeUsers[0].ContactId + ' ' + activeUsers[0].Username + ' ' + activeUsers[0].Username);
        System.debug('**** DEBUG User2.ContactId = ' + activeUsers[1].ContactId + ' ' + activeUsers[1].Username + ' ' + activeUsers[1].UserRoleId);

        System.debug('**** DEBUG Creating users ....');

        String communityProfileId = [select id from profile where name='Customer Community User - Legal Owner'].Id;
        String userRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'OwnerHoldingAccountCustomerUser'].Id;
        System.debug('**** DEBUG Community Profile Id = ' + communityProfileId);
        System.debug('**** DEBUG UserRoleId = ' + userRoleId);
        System.debug('**** DEBUG Contact1 = ' + contacts[0].Id + ' ' + contacts[0].firstName + ' ' + contacts[0].email);

        User user1 = new User(
            ContactId = contacts[0].Id,
            alias = 'test1', 
            email ='owner1@test.com',
            username =' owner1@test.com',
            profileid = communityProfileId, 
            //UserRoleId = userRoleId,
            emailencodingkey = 'UTF-8', 
            lastname = 'Test', 
            languagelocalekey = 'en_US',
            localesidkey =' en_US', 
            country = 'United States',
            IsActive = true,
            timezonesidkey = 'America/Los_Angeles' 
        );
   
        insert user1;
        System.debug('**** DEBUG User1.email = ' + ' ' + user1.Id + ' ' + user1.email);
        
        User user2 = new User(
            ContactId = contacts[1].Id,
            alias = 'test2', 
            email = 'owner2@test.com',
            username = 'owner2@test.com',
            profileid = communityProfileId, 
            //UserRoleId = userRoleId,
            emailencodingkey = 'UTF-8', 
            lastname = 'Test', 
            languagelocalekey = 'en_US',
            localesidkey = 'en_US', 
            country = 'United States',
            IsActive = true,
            timezonesidkey = 'America/Los_Angeles' 
         );
   
        insert user2;
        System.debug('**** DEBUG User1.email = ' + ' ' + user2.Id + ' ' + user2.email);
 
        // update contacts information
        contacts = new List<Contact>{
            new Contact (
                //Id = user1.ContactId, 
                Id = contacts[0].Id,
                Phone = '1-800-111-1234'//,
                //RecordTypeId = rtMap.get('Owner Contact')
                //FirstName = 'Contact1', 
                //LastName = 'Test', 
                //Email = 'contact1@test.com'//, 
                //AccountId = accounts[1].Id
            ),
            new Contact (
                //Id = user2.ContactId, 
                Id = contacts[1].Id,
                Phone = '1-800-222-1234'//,
                //RecordTypeId = rtMap.get('Owner Contact')
                //FirstName = 'Contact2', 
                //LastName = 'Test', 
                //Email = 'contact2@test.com'//, 
                //AccountId = accounts[1].Id
            )
        };
        update contacts;

        // set up club access level
        List<AccountShare> ashare = new List<AccountShare> {
            new AccountShare (
                UserOrGroupId = user1.Id, 
                AccountId = accounts[1].Id, 
                AccountAccessLevel = 'Edit', 
                OpportunityAccessLevel = 'Edit'
            ),
            new AccountShare (
                UserOrGroupId = user2.Id, 
                AccountId = accounts[0].Id, 
                AccountAccessLevel = 'Edit', 
                OpportunityAccessLevel = 'Edit'
            )
        };
        insert ashare;
        
        // create 3 PFagreements
        List<PFAgreement__c> agreement = TestUtil.getAgreements(3, false);
        
        // contacts[0] on FA and ADA agreements
        agreement[0].RecordTypeID = rtMap.get('Franchise_Agreement');
        agreement[0].Club_Name__c = accounts[1].Id;
        agreement[0].Responsible_Owner__c = contacts[0].Id;
        agreement[0].Approved_Operator__c = contacts[0].Id;
        agreement[0].Delegated_Administrator_1__c = contacts[0].Id;
        agreement[0].Delegated_Administrator_2__c = contacts[0].Id;
        agreement[0].ADA_Status__c = 'Active';
        agreement[0].Effective_Date__c = Date.today();
        agreement[0].Expiration_Date__c = Date.today().addDays(2);

        agreement[1].RecordTypeID = rtMap.get('Area_Development_Agreement');
        agreement[1].Club_Name__c = accounts[1].Id;
        agreement[1].Responsible_Owner__c = contacts[0].Id;
        agreement[1].Approved_Operator__c = contacts[0].Id;
        agreement[1].Delegated_Administrator_1__c = contacts[0].Id;
        agreement[1].Delegated_Administrator_2__c = contacts[0].Id;
        agreement[1].ADA_Status__c = 'Active';
        agreement[1].Effective_Date__c = Date.today();
        agreement[1].Expiration_Date__c = Date.today().addDays(2);

        agreement[2].ADA_Status__c  = 'Active';
        insert agreement;        

        // link ADA agreement with accounts[1]
        accounts[1].Area_Development_Agreement__c = agreement[1].Id;
        update accounts;

        // change/remove contacts on all agreements
        PFAgreementTriggerHandler.isFirstExecution = TRUE;
        agreement[0].Responsible_Owner__c = contacts[1].Id;
        agreement[0].Approved_Operator__c = contacts[1].Id;
        agreement[0].Reset_Franchisee_Security__c = true;
        agreement[0].Delegated_Administrator_1__c = contacts[1].Id;
        agreement[0].Delegated_Administrator_2__c = contacts[1].Id;
        agreement[0].Responsible_Owner__c = contacts[1].Id;
        agreement[0].Expiration_Date__c = Date.today();

        agreement[1].Responsible_Owner__c = NULL;
        agreement[1].Approved_Operator__c = NULL;
        agreement[1].Delegated_Administrator_1__c = NULL;
        agreement[1].Delegated_Administrator_2__c = NULL;
        agreement[1].Expiration_Date__c = Date.today();
        agreement[1].ADA_Status__c = 'Expired';        

        agreement[2].Responsible_Owner__c = contacts[1].Id;
        agreement[2].Approved_Operator__c = contacts[1].Id;
        agreement[2].Delegated_Administrator_1__c = contacts[0].Id;
        agreement[2].Delegated_Administrator_2__c = contacts[1].Id;
        agreement[2].ADA_Status__c = 'Active';
        update agreement;

        // FA agreement - change security to false
        PFAgreementTriggerHandler.isFirstExecution = TRUE;
        agreement[0].Reset_Franchisee_Security__c = false;
        update agreement[0];
 
        // FA agreement - remove contacts
        PFAgreementTriggerHandler.isFirstExecution = TRUE;
        agreement[0].Delegated_Administrator_1__c = NULL;
        agreement[0].Delegated_Administrator_2__c = NULL;
        agreement[0].Responsible_Owner__c = NULL ;
        agreement[0].Approved_Operator__c = NULL;
        update agreement;

        // FA agreement - change record type to ADA
        PFAgreementTriggerHandler.isFirstExecution = TRUE;
        agreement[0].RecordTypeID = rtMap.get('Area_Development_Agreement');
        update agreement[0];

        // ADA agreements - expire
        PFAgreementTriggerHandler.isFirstExecution = TRUE;
        agreement[0].Delegated_Administrator_1__c = NULL;
        agreement[0].Delegated_Administrator_2__c = NULL;
        agreement[0].Responsible_Owner__c = NULL ;
        agreement[0].Approved_Operator__c = NULL;
        agreement[0].ADA_Status__c = 'Expired';
        
        agreement[1].ADA_Status__c = 'Expired';
        update agreement;

        // delete agreements
        PFAgreementTriggerHandler.isFirstExecution = TRUE;
        delete agreement;        

        // create new ADA agreement
        agreement = TestUtil.getAgreements(1, false);
        agreement[0].RecordTypeID = rtMap.get('Area_Development_Agreement');
        insert agreement;
 
        // assign agreement to new club
        Group__c grp = new Group__c( 
            Name = 'Test Group 3', 
            Group__c = 'G0005'
        );
        insert grp;

        Account acct = new Account(  
            Name = 'Test 22', 
            Group_Name__c = grp.id 
        );
        acct.Area_Development_Agreement__c = agreement[0].Id;
        insert acct;

        // set up club access level for current user
        PFAgreementTriggerHandler hnd = new PFAgreementTriggerHandler();
        AccountShare asha = hnd.createAccountShare(acct.Id, UserInfo.getUSerId());
        PFAgreementTriggerHandler.accountSharesFutureJob('', JSON.serialize(ashare), NULL, NULL);
        
        // delete agreement
        PFAgreementTriggerHandler.isFirstExecution = TRUE;
        delete agreement;
    }
    
    static testMethod void test2() {
        
        // get record types
        Set<String> developerNameSet = new Set<String>{'Broker', 'Area_Development_Agreement', 'Real_Estate_Site', 'Franchise_Agreement'};
        Set<String> sobjectSet = new Set<String> {'PFAgreement__c', 'Sites__c', 'Contact'};
        Map<String, Id> rtMap = new Map<String, Id>();
        
        for (RecordType rt : [
            SELECT Id, DeveloperName, SObjectType FROM RecordType 
             WHERE (DeveloperName IN :developerNameSet)
             AND (sObjectType IN :sobjectSet)
        ]) {                
            rtMap.put(rt.DeveloperName, rt.Id);
        }
        
        // create clubs associated with a single group
        List<Account> accounts = TestUtil.getAccounts(2, false);
        accounts[0].PF_Club_ID__c = '1234';
        insert accounts;

        // create contacts
        Contact con1 = PFTestUtility.createOwnerContact('Owner1','Test','owner1@test.com','owner1@test.com');
        Contact con2 = PFTestUtility.createOwnerContact('Owner2','Test','owner2@test.com','owner2@test.com');                   
        List<Contact> contacts = new List<Contact>();
        contacts.add(con1);
        contacts.add(con2);
        insert contacts;
        
        // create group owners
        Id grpId = [SELECT Id FROM Group__c WHERE Name = 'Test Group' Limit 1].Id;        
        List<Group_Owner__c> groupOwner = new List<Group_Owner__c> {
            new Group_Owner__c(
                Group_Num__c  = grpId,
                Owner_Contact__c = contacts[0].Id
            ),
            new Group_Owner__c(
                Group_Num__c  = grpId,
                Owner_Contact__c = contacts[0].Id
            )
        };        
        insert groupOwner;

        Sharing_Wizard_Setting__c cS = new Sharing_Wizard_Setting__c (
            Error_Notification_Emails__c = 'owner1@test.com;owner2@test.com'
        );
        insert cs;
        
        // get random community users
        /*List<User> user = [
            SELECT Id, ContactId 
            FROM User 
            WHERE ContactId != NULL 
            AND IsActive = TRUE 
            LIMIT 2
        ];*/

        String communityProfileId = [select id from profile where name='Customer Community User - Legal Owner'].Id;
        String userRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'OwnerHoldingAccountCustomerUser'].Id;
        System.debug('**** DEBUG Community Profile Id = ' + communityProfileId);
        System.debug('**** DEBUG UserRoleId = ' + userRoleId);
        System.debug('**** DEBUG Contact1 = ' + contacts[0].Id + ' ' + contacts[0].firstName + ' ' + contacts[0].email);

        User user1 = new User(
            ContactId = contacts[0].Id,
            alias = 'test1', 
            email ='owner1@test.com',
            username =' owner1@test.com',
            profileid = communityProfileId, 
            //UserRoleId = userRoleId,
            emailencodingkey = 'UTF-8', 
            lastname = 'Test', 
            languagelocalekey = 'en_US',
            localesidkey =' en_US', 
            country = 'United States',
            IsActive = true,
            timezonesidkey = 'America/Los_Angeles' 
        );
   
        insert user1;
        System.debug('**** DEBUG User1.email = ' + ' ' + user1.Id + ' ' + user1.email);
        
        User user2 = new User(
            ContactId = contacts[1].Id,
            alias = 'test2', 
            email = 'owner2@test.com',
            username = 'owner2@test.com',
            profileid = communityProfileId, 
            //UserRoleId = userRoleId,
            emailencodingkey = 'UTF-8', 
            lastname = 'Test', 
            languagelocalekey = 'en_US',
            localesidkey = 'en_US', 
            country = 'United States',
            IsActive = true,
            timezonesidkey = 'America/Los_Angeles' 
         );
   
        insert user2;
        System.debug('**** DEBUG User1.email = ' + ' ' + user2.Id + ' ' + user2.email); 
        
        // update contacts information
        contacts = new List<Contact>{
            new Contact (
                //Id = user[0].ContactId, 
                Id = contacts[0].Id,
                Phone = '1-800-111-1234'
                //FirstName = 'Contact1', 
                //LastName = 'Test', 
                //Email = 'contact1@test.com'//, 
                //AccountId = accounts[1].Id
            ),
            new Contact (
                //Id = user[1].ContactId, 
                Id = contacts[1].Id,
                Phone = '1-800-222-1234'
                //FirstName = 'Contact2', 
                //LastName = 'Test', 
                //Email = 'contact2@test.com'//, 
                //AccountId = accounts[1].Id
            )
        };
        update contacts;
        
        List<AccountShare> ashare = new List<AccountShare> {
            new AccountShare (
                UserOrGroupId = user1.Id, 
                AccountId = accounts[1].Id, 
                AccountAccessLevel = 'Edit', 
                OpportunityAccessLevel = 'Edit'
            ),
            new AccountShare (
                UserOrGroupId = user2.Id, 
                AccountId = accounts[0].Id, 
                AccountAccessLevel = 'Edit', 
                OpportunityAccessLevel = 'Edit'
            )
        };
        insert ashare;
        
        // create PFagreements
        List<PFAgreement__c> agreement = TestUtil.getAgreements(3, false);
        agreement[1].RecordTypeID = rtMap.get('Area_Development_Agreement');
        agreement[1].ADA_Status__c = 'Active';
        agreement[1].Approved_Operator__c = contacts[0].Id;
        agreement[1].Responsible_Owner__c = contacts[0].Id;
        agreement[1].Delegated_Administrator_1__c = contacts[0].Id;
        agreement[1].Delegated_Administrator_2__c = contacts[0].Id;
        agreement[1].Club_Name__c = accounts[1].Id;
        agreement[1].Expiration_Date__c = Date.today().addDays(2);
        agreement[1].Effective_Date__c = Date.today();
 
        agreement[2].ADA_Status__c  = 'Active';
        insert agreement;
        
        // associate ADA with account
        for (Account acc : accounts) {
            acc.Area_Development_Agreement__c = agreement[1].Id;
        }
        update accounts;
        
        // change contacs
        PFAgreementTriggerHandler.isFirstExecution = TRUE;        
        agreement[1].Approved_Operator__c = contacts[1].Id;
        agreement[1].Responsible_Owner__c = contacts[1].Id;
        agreement[1].Delegated_Administrator_1__c = contacts[1].Id;
        agreement[1].Delegated_Administrator_2__c = contacts[1].Id;
        agreement[1].Expiration_Date__c = Date.today();
        update agreement;   
              
    }
}