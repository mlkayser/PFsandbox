@isTest
public class TestAccountTrigger {
    
    static testMethod void testMethod1() {
        
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
                
                delete acrList;
            }
            
            Test.StopTest();
        }
    }
}