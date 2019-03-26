/**
 * Created by JLinn on 1/17/18.
 */
@IsTest
public with sharing class PFMarketingSpendControllerTest {
    
    //Sample Data Factory
    
    //Add a group
    @TestSetup
    public static void testFactory() {
        
        User runningAdminUser = [
                SELECT Id, Email, ContactId, ProfileId, FirstName, LastName
                FROM User
                WHERE Profile.Name = 'System Administrator'
                    AND UserRoleId != NULL
                    AND IsActive = TRUE
                LIMIT 1
        ];       
        System.debug(runningAdminUser.FirstName + ' ' + runningAdminUser.LastName);
        
        //System.runAs(runningAdminUser){

        Group__c testGroup = new Group__c(
            Name = 'Test Group',
            //My IDE does not like that this field is named the same as the Object!
            Group__c = '1234'
        );    
        insert testGroup;       

        //Account
        Account ownerHoldingAccount = new Account(
                Name = 'Owner Holding AccountTest',
                RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Owner_Holding_Account'][0].Id,
                OwnerId = runningAdminUser.Id
        );
        insert ownerHoldingAccount;

        //Create an Account Record with a record Type of 'Club'    
        //SELECT PF_Club_ID__c,Group_Name__c,Group_Number__c,Id,Name,Date_Opened__c
        Account testClub = new Account(
                Name = 'Test Club',
                Group_Name__c = testGroup.Id,
                RecordTypeId = [
                        SELECT Id
                        FROM RecordType
                        WHERE DeveloperName = 'Club_Location'
                        AND SobjectType = 'Account'
                        LIMIT 1
                ].Id,
                OwnerId = runningAdminUser.Id,
                Date_Opened__c = Datetime.newInstance(2017, 1, 1),
                POS_Club_ID__c = '1234',
                PF_Club_ID__c = '1234',
                Status__c = 'Open'
        );    
        insert testClub;
            
        System.debug('The Account Details: ');
        System.debug(testClub);
    
        //Create a user who is a community User (e.g. has a contact Record)
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
        Database.insert(groupOwner);
    
        Group_Owner__c ownerGroup = new Group_Owner__c(
                Owner_Contact__c = groupOwner.Id,
                Group_Num__c = testGroup.Id
                
        );    
        insert ownerGroup;
        
        //Make them a related contact to the Club
        AccountContactRelation acr = new AccountContactRelation(
                AccountId = testClub.Id,
                ContactId = groupOwner.Id,
                Roles = 'Owner'
        );        
        insert acr;

        User testUser = new User(
                ProfileId = '00e0a000000Dn3j',
                //ProfileId = [SELECT id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].id,
                userName = 'president@whitehouse.com',
                email = 'president@whitehouse.com',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/New_York',
                Alias = 'TRUMP',
                LastName = 'Trump',
                ContactId = groupOwner.Id,
                PortalRole = 'Manager'
        );
        insert testUser;
    
        testClub.OwnerId = testUser.Id;
        update testClub;
        
        testGroup.OwnerId = testUser.id;
        update testGroup;
    
        //Community_Settings__c cs = [SELECT Marketing_Spend_Record_Type_ID__c from Community_Settings__c LIMIT 1];        
        Compliance__c comp = new Compliance__c(
                Name = 'Marketing Spend tEST',
                mspend_Spend_Month__c = Date.valueOf('2017-02-01'),
                Club__c = testClub.Id,                
                OwnerId = testUser.id,
                //RecordTypeId = cs.Marketing_Spend_Record_Type_ID__c
                RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Club_Marketing_Compliance'][0].id                
        );        
        insert comp;
    //}
    }
    
    @IsTest
    public static void getGroupNamesTest(){
        
        //Test the static method
        PFMarketingSpendController.getClubs('Test Group');
        
        User Runner = [SELECT Id FROM User WHERE Username = 'president@whitehouse.com' LIMIT 1];
        System.runAs(Runner){
            PFMarketingSpendController cont = new PFMarketingSpendController();
            
            cont.selectedGroup = 'Test Group';
            cont.getGroupNames();
            
            //PFMarketingSpendController.getClubs('Test Group');            
            PFMarketingSpendController.getComplianceStatus('Test Group',2017,NULL);
            PFMarketingSpendController.getComplianceStatus('Test Group',2017,2);
        }
        //Test.stopTest();
    }
}