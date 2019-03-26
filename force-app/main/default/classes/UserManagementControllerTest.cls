@isTest 
private class UserManagementControllerTest {
    
    static testMethod void testMethod1() {
        
        Id conRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        User user = [SELECT Id,Email,ContactId,ProfileId, FirstName, LastName FROM User WHERE Contact.RecordType.Name = 'Broker' AND IsActive = TRUE LIMIT 1];
        User user1 = [SELECT Id,Email,ContactId,ProfileId, LastName FROM User WHERE Contact.RecordType.Name = 'Broker' AND IsActive = FALSE LIMIT 1];
        User sysAdmin = [SELECT Id,Email,ContactId,ProfileId,LastName FROM User WHERE Profile.Name = 'System Administrator'  AND IsActive = TRUE LIMIT 1];
    
        system.runAs(sysAdmin) {
        
            System.debug('The user we will use is: ');
            System.debug(user.LastName);
                
            Group__c g = new Group__c( 
                Name = 'Test Group 3', 
                Group__c = 'G0005'
            );
            insert g;
        
            Account acct = new Account(  
                Name = 'Test 22', 
                Group_Name__c = g.id, 
                PF_Club_ID__c = '1234'
            );
            insert acct;
        
            update new Contact(Id = user.ContactId, AccountId = acct.Id);
            update new Contact(Id = user1.ContactId, AccountId = acct.Id);
        
            List<Contact> contacts = new List<Contact>{
                new Contact (FirstName = 'Larrys', LastName = 'Page', Email = 'test@test.com', Phone = '1-800-123-1234', 
                    AccountId = acct.Id, RecordTypeId = conRecType),
                new Contact (FirstName = 'Marc', LastName = 'Buymeoff', Email = 'test2@test1.com', Phone = '1-800-1235-1234',
                    RecordTypeId = conRecType),
                new Contact (FirstName = 'Marc', LastName = 'Buymeoff', Email = user.Email, Phone = '1-800-1235-1234',
                    RecordTypeId = conRecType),
                new Contact (FirstName = 'Marc', LastName = 'Buymeoff', Email = user1.Email, Phone = '1-800-1235-1234',
                    RecordTypeId = conRecType)
            };
            insert contacts;
        
            Group_Owner__c groupOwner = new Group_Owner__c(
                Group_Num__c  = g.Id,
                Owner_Contact__c = user.ContactId
            );
            insert groupOwner;
        
            User_Management_Setting__c ams = new User_Management_Setting__c(
                Owner_Holding_Account_Id__c = acct.Id
            );
            insert ams;
        
            PFAgreement__c[] agreements = new PFAgreement__c[] {
                new PFAgreement__c(
                    Name = 'test Agre'
                )
            };
            insert agreements;
            
            UserManagementController.resetPassword(user.Id);
            UserManagementController.getData();
            UserManagementController.getGroups(contacts[0].Id, 'con create');
            UserManagementController.getGroups(contacts[0].Id, 'test');            
            UserManagementController.checkExistingContact('test@test.com');
            UserManagementController.checkExistingContact(user.Email);
            UserManagementController.checkExistingContact(user1.Email);
            UserManagementController.deactivateUser(user.Id);
            
            List<String> ssoAccess = UserManagementController.returnUserSSOAccess();
            User usr = new User(Email = 'test@test.com', LastName = 'Test');
            User usr1 = new User(Email = user1.Email, LastName = user1.LastName);
            
            Contact con = new Contact(LastName = 'test', Email = 'test@test.com');
            Contact con1 = new Contact(LastName = 'test', Email = 'test@test.com', Id = user1.ContactId);
            Group_Owner__c groupOwner1 = new Group_Owner__c(Group_Num__c  = g.Id,Owner_Contact__c = user.ContactId);
            
            UserManagementController.createUser(JSON.serialize(usr), '', new List<String>{g.Id}, 'Franchisee', ssoAccess, 'create');
            UserManagementController.createUser(JSON.serialize(usr), '', new List<String>{g.Id}, 'Club Staff', ssoAccess, 'create');
            UserManagementController.createUser(JSON.serialize(usr), '', new List<String>{g.Id}, 'Broker', ssoAccess, 'no react');
            UserManagementController.createUser(JSON.serialize(usr1), '', new List<String>{g.Id}, 'Broker', ssoAccess, 'no react');            
            UserManagementController.createUser(JSON.serialize(usr), '', new List<String>{g.Id}, 'Operations', ssoAccess, 'react');
            UserManagementController.createUser(JSON.serialize(usr1), JSON.serialize(con1), new List<String>{g.Id}, 'Operations', ssoAccess, 'react');            
            UserManagementController.createUser(JSON.serialize(usr), JSON.serialize(con), new List<String>{g.Id}, 'Marketing', ssoAccess, 'create');
            UserManagementController.creatingGroup(JSON.serialize(new List<Group_Owner__c>{ groupOwner1 }));
            
            usr.email = 'test@sstest.com';
            UserManagementController.updateUser(JSON.serialize(usr));
        }
    }
    
    static testMethod void testMethod2() {
        
        Id conRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Broker').getRecordTypeId();  
        User user = [SELECT Id,Email,ContactId,ProfileId,Contact.RecordTypeId FROM User WHERE Contact.RecordType.Name = 'Owner Contact' AND IsActive = TRUE LIMIT 1];
        User user1 = [SELECT Id,Email,ContactId,ProfileId,LastName FROM User WHERE Contact.RecordType.Name = 'Broker' AND IsActive = FALSE LIMIT 1];
        User sysAdmin = [SELECT Id,Email,ContactId,ProfileId,LastName FROM User WHERE Profile.Name = 'System Administrator'  AND IsActive = TRUE LIMIT 1];
        
        system.runAs(sysAdmin) {
            Group__c g = new Group__c( Name = 'Test Group 3', Group__c = 'G0005');
            insert g;
        
            Account acct = new Account(  Name = 'Test 22' , Group_Name__c = g.id, PF_Club_ID__c = '1234');
            insert acct;
        
            update new Contact(Id = user.ContactId, AccountId = acct.Id);
            update new Contact(Id = user1.ContactId, AccountId = acct.Id);
        
            List<Contact> contacts = new List<Contact>{
                new Contact (FirstName = 'Larrys', LastName = 'Page', Email = 'test@test.com', Phone = '1-800-123-1234',
                    AccountId = acct.Id, RecordTypeId = conRecType),
                new Contact (FirstName = 'Marc', LastName = 'Buymeoff', Email = 'test2@test1.com', Phone = '1-800-1235-1234',
                    RecordTypeId = conRecType),
                new Contact (FirstName = 'Marc', LastName = 'Buymeoff', Email = user.Email, Phone = '1-800-1235-1234',
                    RecordTypeId = conRecType),
                new Contact (FirstName = 'Marc', LastName = 'Buymeoff', Email = user1.Email, Phone = '1-800-1235-1234',
                    RecordTypeId = conRecType)
            };
            insert contacts;
        
            Group_Owner__c groupOwner = new Group_Owner__c(Group_Num__c  = g.Id,Owner_Contact__c = user.ContactId);
            insert groupOwner;
            
            User_Management_Setting__c ums = new User_Management_Setting__c(
                Owner_Holding_Account_Id__c = acct.Id,
                Contact_Club_Staff_Record_Type_Id__c = user.Contact.RecordTypeId,
                Contact_Record_Type__c = user.Contact.RecordTypeId,
                Default_User_Profile_Id__c = user.ProfileId
            );
            insert ums;
        
            Id adaRecTypeId = Schema.SObjectType.PFAgreement__c.getRecordTypeInfosByName().get('Area Development Agreement').getRecordTypeId();            
            PFAgreement__c pfa = new PFAgreement__c(
                Name = 'test Agre', 
                Delegated_Administrator_2__c = user.ContactId,
                Responsible_Owner__c = user.ContactId, 
                Approved_Operator__c = user.ContactId, 
                ADA_Status__c = 'Active',
                Delegated_Administrator_1__c = contacts[0].Id, 
                RecordTypeId = adaRecTypeId, 
                Club_Name__c=acct.Id
            );
            insert pfa;       
            
            List<String> ssoAccess = UserManagementController.returnUserSSOAccess();
            UserManagementController.resetPassword('test');
            UserManagementController.getData();
            user.email = 'test@sstest.com';
            UserManagementController.updateUser(JSON.serialize(user));
            UserManagementController.createUser(JSON.serialize(user), JSON.serialize(contacts[0]), new List<String>{g.Id}, 'Franchisee', ssoAccess, '');
            ums.Contact_Record_Type__c = conRecType;
            update ums;
            
            UserManagementController.checkExistingContact(contacts[0].Email);
        }
    }
}