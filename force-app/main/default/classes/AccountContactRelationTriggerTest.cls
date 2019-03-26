@isTest
public class AccountContactRelationTriggerTest {
    
    static testMethod void accountContactRelationMtd() {
        
        Set<String> developerNameSet =new Set<String>{'Broker', 'Area_Development_Agreement', 'Real_Estate_Site'};
        Set<String> sobjectSet = new Set<String> {'PFAgreement__c', 'Sites__c', 'Contact'};
        Map<String, Id> rtMap = new Map<String, Id>();
        for(RecordType rt : [SELECT Id, DeveloperName, SObjectType FROM RecordType 
                WHERE (DeveloperName IN :developerNameSet)
                AND (sObjectType IN :sobjectSet)]) {
                
            rtMap.put(rt.DeveloperName, rt.Id);
        }
        //List<Account> accounts = TestUtil.getAccounts(2, false);
        
        String accRecTypeId = [SELECT Id, DeveloperName, SObjectType FROM RecordType WHERE SObjectType = 'Account'][0].Id;
        
        List<Account> accounts = new List<Account> {
            new Account(Name='Test Account1',PF_Club_ID__c = '0034',RecordTypeId=accRecTypeId),
            new Account(Name='Test Account2',PF_Club_ID__c = '0014',RecordTypeId=accRecTypeId)
        };    
        insert accounts;
        
        User user = [SELECT Id, ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE LIMIT 1];
        User u = new User (Id = UserInfo.getUserId());
        update u;
        system.runAs(u) {
            List<Contact> contacts = new List<Contact>{
                new Contact (Id = user.ContactId, FirstName = 'Larrys', LastName = 'Page', Email = 'test@test.com', Phone = '1-800-123-1234', AccountId = accounts[1].Id)
            };
            update contacts[0];
           
            system.debug(':::test List ::' +[SELECT Id,Name,Active_Agreement__c,Club_Name__c,Club_Name__r.Name,Club_Name__r.Status__c,Club_Name__r.Group_Name__r.Name,Club_Name__r.Group_Name__c FROM PFAgreement__c ]);
            Group__c g = new Group__c( Name = 'Test Group 3', Group__c = 'G0005');
            insert g;
            Account acct = new Account(  Name = 'Test 22' , Group_Name__c = g.id );
            acct.Area_Development_Agreement__c = acct.Id;
            insert acct;
            SharingWizardController.getData(user.Id);
            List<AccountContactRelation> accConRel = new List<AccountContactRelation> {
                new AccountContactRelation(AccountId = accounts[0].Id, ContactID = contacts[0].Id, Roles = 'Construction', IsShared__c = true, Ownership_Percent__c = 10, Voting_Interest__c = 10)
            };
            insert accConRel;
            accConRel[0].IsShared__c = FALSE;
            update accConRel;
            delete accConRel;
            user.Club_Access__c = NULL;
            update user;
            accConRel = new List<AccountContactRelation> {
                new AccountContactRelation(AccountId = accounts[0].Id, ContactID = contacts[0].Id, Roles = 'Construction', IsShared__c = False, Ownership_Percent__c = 10, Voting_Interest__c = 10)
            };
            insert accConRel;
            accConRel[0].IsShared__c = TRUE;
            update accConRel;
            delete accConRel;
        }
        
    }
}