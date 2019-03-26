/**
 * Created by rdiaznasser on 3/8/18.
 */
@IsTest
public with sharing class AccountTriggerHandler_Test {

    @TestSetup
    static void setup(){
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
        Account setupAccount = new Account();
        setupAccount.Name = 'Owner Holding Account';
        setupAccount.Group_Name__c = setupGroup.Id;
        setupAccount.Status__c = 'Open';
        setupAccount.Date_Opened__c = Date.today();
        setupAccount.POS_Club_ID__c = '1234';
        insert setupAccount;
    }

/*------------------------------------------------Test Methods----------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------*/

    @isTest
    static void testMethod1() {
        // Get the first test account by using a SOQL query
        Account acct = [SELECT Id FROM Account LIMIT 1];

        // Create Group 2
        Group__c group2 = new Group__c();
        group2.Name = 'setupGroup2';
        group2.Group__c = '00002';
        insert group2;

        acct.Group_Name__c = group2.Id;

        List<AccountShare> accountshares = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare];
        System.debug(accountshares);

        update acct;
    }
    
    @isTest
    static void testMethod2() {
        
        List<User> users = [SELECT Id, ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE AND Contact.RecordType.DeveloperName = 'Owner_Contact' LIMIT 1];
        String adaRecTypeId = Schema.SObjectType.PFAgreement__c.getRecordTypeInfosByName().get('Area Development Agreement').getRecordTypeId();
        
        if(users.size() > 0) {
            String randNo = String.valueOf(Crypto.getRandomInteger());
            PFAgreement__c ada = new PFAgreement__c(Name='Test'+randNo,Responsible_Owner__c = users[0].ContactId,
                                     Approved_Operator__c = users[0].ContactId,Delegated_Administrator_1__c = users[0].ContactId,
                                     Delegated_Administrator_2__c = users[0].ContactId,RecordTypeId = adaRecTypeId
                                 );
            insert ada;
            
            Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Club Location').getRecordTypeId();
            
            Group__c g = new Group__c( Name = 'Test Group 3', Group__c = 'G0005');
            insert g;
            
            Account acc1 = new Account(Name='Test Account', RecordTypeId=accRecTypeId,PF_Club_ID__c='0000',
                Area_Development_Agreement__c=ada.Id,Group_Name__c=g.Id
            );
            insert acc1;
            
            Test.StartTest();
            
            List<AccountContactRelation> acrList = [SELECT Id,isShared__c FROM AccountContactRelation LIMIT 100];
            if(acrList.size() > 0) {
                acrList[0].isShared__c = !acrList[0].isShared__c;
                update acrList;
                
                acrList[0].isShared__c = !acrList[0].isShared__c;
                update acrList;
                
                //delete acrList;
            }
            
            Test.StopTest();
        }
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