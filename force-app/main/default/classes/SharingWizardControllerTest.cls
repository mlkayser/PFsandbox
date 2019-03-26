@isTest 
private class SharingWizardControllerTest {
    
    static testMethod void testMethod1() {
        
        Set<String> developerNameSet =new Set<String>{'Broker', 'Area_Development_Agreement', 'Real_Estate_Site'};
        Set<String> sobjectSet = new Set<String> {'PFAgreement__c', 'Sites__c', 'Contact'};
        Map<String, Id> rtMap = new Map<String, Id>();
        for(RecordType rt : [SELECT Id, DeveloperName, SObjectType FROM RecordType 
                WHERE (DeveloperName IN :developerNameSet)
                AND (sObjectType IN :sobjectSet)]) {
                
            rtMap.put(rt.DeveloperName, rt.Id);
        }
        
        String accRecTypeId = [SELECT Id, DeveloperName, SObjectType FROM RecordType WHERE SObjectType = 'Account'][0].Id;
        Id accRecTypeCLId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Club Location').getRecordTypeId();
        
        List<Account> accounts = new List<Account> {
            new Account(Name='Test Account', PF_Club_ID__c='0010', RecordTypeId=accRecTypeId),
            new Account(Name='Test Account', PF_Club_ID__c='0000', RecordTypeId=accRecTypeId)
        };
        
        insert accounts;
        accounts[0].PF_Club_ID__c = '1234';
        accounts[0].RecordTypeId = accRecTypeCLId;
        accounts[1].RecordTypeId = accRecTypeCLId;
        update accounts;
                   
        List<Contact> contacts = new List<Contact>{
            new Contact (FirstName = 'Larrys', LastName = 'Page', Email = 'test@test.com', Phone = '1-800-123-1234', 
                AccountId = accounts[1].Id, RecordTypeId = rtMap.get('Broker')),
            new Contact (FirstName = 'Marc', LastName = 'Buymeoff', Email = 'test2@test1.com', Phone = '1-800-1235-1234',
                RecordTypeId = rtMap.get('Broker'))
        };
        insert contacts;
        
        Group__c grp = new Group__c( Name = 'Test Group 3', Group__c = 'G0005');
        insert grp;
        
        Group_Owner__c groupOwner = new Group_Owner__c (
            Group_Num__c  = grp.Id, Owner_Contact__c = contacts[0].Id
        );
        insert groupOwner;
        
        List<User> users = [SELECT Id, ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE LIMIT 2];
        
        List<AccountContactRelation> accConRel = new List<AccountContactRelation> {
            new AccountContactRelation(AccountId = accounts[0].Id, ContactId = users[0].ContactId, Roles = 'Construction', IsShared__c = true, Ownership_Percent__c = 10, Voting_Interest__c = 10),
            new AccountContactRelation(AccountId = accounts[1].Id, ContactId = users[0].ContactId, Roles = 'Construction', IsShared__c = true, Ownership_Percent__c = 10, Voting_Interest__c = 10)
        };
        insert accConRel;
        
        List<Project__c> projects = new List<Project__c>{
            new Project__c(Name = 'Test Project', Club_Location__c = accounts[0].Id),
            new Project__C(Name = 'Test Project1', Club_Location__c = accounts[1].Id)
        };
        insert projects;
            
        List<sites__c> sites = new List<Sites__c>{
            new Sites__c (RecordTypeId = rtMap.get('Real_Estate_Site'), Status__c = 'Pending Submission', Project__c  = Projects[1].Id),
            new Sites__c (RecordTypeId = rtMap.get('Real_Estate_Site'), Status__c = 'Pending Submission', Project__c  = Projects[0].Id)
        };
        insert sites;
        
        Sharing_Wizard_Setting__c sws = new Sharing_Wizard_Setting__c(Knowledge_Article_Id__c='test');
        insert sws;
        
        Excluded_Roles__c exRoles = new Excluded_Roles__c(Name='Test');
        insert exRoles;
        
        system.runAs(users[0]) {
            
            accConRel[1].IsShared__c = FALSE;
            SharingWizardController.saveChanges(JSON.serialize(accConRel));
        }
    }
    
    static testMethod void testMethod2() {
        
        Set<String> developerNameSet =new Set<String>{'Broker', 'Area_Development_Agreement', 'Real_Estate_Site'};
        Set<String> sobjectSet = new Set<String> {'PFAgreement__c', 'Sites__c', 'Contact'};
        Map<String, Id> rtMap = new Map<String, Id>();
        for(RecordType rt : [SELECT Id, DeveloperName, SObjectType FROM RecordType 
                WHERE (DeveloperName IN :developerNameSet)
                AND (sObjectType IN :sobjectSet)]) {
                
            rtMap.put(rt.DeveloperName, rt.Id);
        }
        
        String accRecTypeId = [SELECT Id, DeveloperName, SObjectType FROM RecordType WHERE SObjectType = 'Account'][0].Id;
        Id accRecTypeCLId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Club Location').getRecordTypeId();
        
        List<Account> accounts = new List<Account> {
            new Account(Name='Test Account', PF_Club_ID__c='0010', RecordTypeId=accRecTypeId),
            new Account(Name='Test Account', PF_Club_ID__c='0000', RecordTypeId=accRecTypeId)
        };
        
        insert accounts;
        accounts[0].PF_Club_ID__c = '1234';
        accounts[0].RecordTypeId = accRecTypeCLId;
        accounts[1].RecordTypeId = accRecTypeCLId;
        update accounts;
                   
        List<Contact> contacts = new List<Contact>{
            new Contact (FirstName = 'Larrys', LastName = 'Page', Email = 'test@test.com', Phone = '1-800-123-1234', 
                AccountId = accounts[1].Id, RecordTypeId = rtMap.get('Broker')),
            new Contact (FirstName = 'Marc', LastName = 'Buymeoff', Email = 'test2@test1.com', Phone = '1-800-1235-1234',
                RecordTypeId = rtMap.get('Broker'))
        };
        insert contacts;
        
        Group__c grp = new Group__c( Name = 'Test Group 3', Group__c = 'G0005');
        insert grp;
        
        Group_Owner__c groupOwner = new Group_Owner__c (
            Group_Num__c  = grp.Id, Owner_Contact__c = contacts[0].Id
        );
        insert groupOwner;
        List<AccountContactRelation> accConRel = new List<AccountContactRelation> {
            new AccountContactRelation(AccountId = accounts[0].Id, ContactID = contacts[0].Id, Roles = 'Construction', IsShared__c = true, Ownership_Percent__c = 10, Voting_Interest__c = 10)
        };
        insert accConRel;
        
        List<Project__c> projects = new List<Project__c>{
            new Project__c(Name = 'Test Project', Club_Location__c = accounts[0].Id),
            new Project__C(Name = 'Test Project1', Club_Location__c = accounts[1].Id)
        };
        insert projects;
            
        List<sites__c> sites = new List<Sites__c>{
            new Sites__c (RecordTypeId = rtMap.get('Real_Estate_Site'), Status__c = 'Pending Submission', Project__c  = Projects[1].Id),
            new Sites__c (RecordTypeId = rtMap.get('Real_Estate_Site'), Status__c = 'Pending Submission', Project__c  = Projects[0].Id)
        };
        insert sites;
        User u = new User (Id = UserInfo.getUserId(), ContactId = contacts[0].Id);
        update u;
        
        Sharing_Wizard_Setting__c sws = new Sharing_Wizard_Setting__c(Knowledge_Article_Id__c='test');
        insert sws;
        Excluded_Roles__c exRoles = new Excluded_Roles__c(Name='Test');
        insert exRoles;
        system.runAs(u) {
        
            SharingWizardController swCon = new SharingWizardController();
            SharingWizardController.getUser();
            
            SharingWizardController.saveChanges(JSON.serialize(accConRel));
        }
        
        User user = [SELECT Id, ContactId FROM User WHERE IsActive = TRUE AND Contact.RecordType.Name = 'Owner Contact' LIMIT 1];
        system.runAs(user) {
            SharingWizardController swCon = new SharingWizardController();
            
        }
        system.runAs(u) {
            contacts = new List<Contact>{
                new Contact (Id = user.ContactId, FirstName = 'Larrys', LastName = 'Page', Email = 'test@test.com', Phone = '1-800-123-1234', AccountId = accounts[1].Id)
            };
            update contacts[0];
            
            List<PFAgreement__c> agreement = new List<PFAgreement__c> {
                new PFAgreement__c(Name = 'Test Agreement1'),
                new PFAgreement__c(Name = 'Test Agreement2')
            };
            agreement[0].RecordTypeID = rtMap.get('Area_Development_Agreement');
            agreement[1].RecordTypeID = rtMap.get('Area_Development_Agreement');
            agreement[0].Approved_Operator__c = contacts[0].Id;
            agreement[0].Responsible_Owner__c = contacts[0].Id;
            agreement[0].ADA_Status__c = 'Active';
            agreement[1].ADA_Status__c = 'Active';
            agreement[0].Delegated_Administrator_1__c = contacts[0].Id;
            agreement[1].Delegated_Administrator_2__c = contacts[0].Id;
            agreement[1].Approved_Operator__c = contacts[0].Id;
            agreement[1].Responsible_Owner__c = contacts[0].Id;
            agreement[1].Delegated_Administrator_1__c = contacts[0].Id;
            agreement[1].Delegated_Administrator_2__c = contacts[0].Id;
            agreement[0].Club_Name__c = accounts[0].Id;
            agreement[1].Club_Name__c = accounts[1].Id;
            agreement[0].Expiration_Date__c = Date.today().addDays(2);
            agreement[1].Expiration_Date__c = Date.today().addDays(2);
            agreement[0].Effective_Date__c = Date.today();
            agreement[1].Effective_Date__c = Date.today();
            agreement[0].Club_Name__c = accounts[1].Id;
            insert agreement;
            
            Group__c g = new Group__c( Name = 'Test Group 3', Group__c = 'G0001');
            insert g;
            Group_Owner__c groupOwner1 = new Group_Owner__c (
                Group_Num__c  = g.Id, Owner_Contact__c = contacts[0].Id
            );
            insert groupOwner1;
            Account acct = new Account(Name = 'Test 22' , Group_Name__c = g.id );
            acct.Area_Development_Agreement__c = agreement[0].Id;
            insert acct;
            /*
            PFAgreement__c agreement1 = new PFAgreement__c(Name = 'Test Agreement1', Club_Name__c = acct.Id, RecordTypeID = rtMap.get('Franchise_Agreement'),
                                            Effective_Date__c=System.today()
                                        );
            insert agreement1;
            */
            SharingWizardController.getData(user.Id);
                        
            accConRel = new List<AccountContactRelation> {
                new AccountContactRelation(AccountId = accounts[0].Id, ContactID = contacts[0].Id, Roles = 'Construction', IsShared__c = true, Ownership_Percent__c = 10, Voting_Interest__c = 10)
            };
            insert accConRel;
            SharingWizardController.saveChanges(JSON.serialize(accConRel));
            //SharingWizardController.getData(u.Id);
        }
    }
}