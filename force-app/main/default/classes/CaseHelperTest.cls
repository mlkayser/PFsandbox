@isTest
public class CaseHelperTest {
    static testMethod void testPopulateAccountLookup() {
       Group__c g = new Group__c(
    			Name = 'Test Group',
        		Group__c = 'G0001');
    	insert g;
        
        Account a = new Account(
        		Name='TestAccount',
        		PF_Club_ID__c = '1234',
        		Group_Name__c = g.id);
        insert a;

        Case c = new Case(
        			Web_Account_Id__c = a.Id);
        
        Test.startTest();
        insert c;
        Test.stopTest();
        
        c = [select Id, AccountId from Case where id =: c.Id];
        
        //Check the Account lookup on Case was populated with the value in Web Account Id
        System.assertEquals(a.Id, c.AccountId);
    }
}