/*
** manuela.lkayser June 2018
*/

@isTest
private class PFAgreementUpdateAccountTest {
	
	@testsetup 
	static void setup() {
	    
        // create group
        Group__c grp = new Group__c(
            Name = 'Test Group',
            Group__c = 'G0001');
        insert grp;       
	    
		// create accounts
		List<Account> accList = new List<Account>();
		for(Integer i = 0; i < 2; i++) {
            Account acc = new Account(  
            	Name = 'Test-' + i, 
            	Group_Name__c = grp.id);
            accList.add(acc);
	    }	        
	    insert accList;	

	    // create franchise agreements
	    List<PFAgreement__c> agrmList = new List<PFAgreement__c>();
	    Id RecordTypeId = Schema.SObjectType.PFAgreement__c.getRecordTypeInfosByName().get('Franchise Agreement').getRecordTypeId();
	    System.debug('TEST=====> Record type id = ' + RecordTypeId);

	    for (Integer i = 0; i < 2; i++) {
	    	PFAgreement__c agrm = new PFAgreement__c(
	    		Name = 'Test-' + i,
	    		RecordTypeId = RecordTypeId,
	    		Club_Name__c = accList[i].Id,
	    		Effective_Date__c = date.today(),
	    		Expiration_Date__c = date.today().addDays(7),
	    		SOX_Termination_Date__c = date.today().addDays(7)
	    	);
	    	agrmList.add(agrm);
	    }
	    insert agrmList;
    }
	
	@isTest static void test_method() {		
		List<PFAgreement__c> agrmList = [
			SELECT id, 
				Name,
				RecordType.Name, 
				Active_Agreement__c, 
				Club_Name__c 
			FROM PFAgreement__c];
			System.debug('TEST===> Agreement list = ' + agrmList.size());

		Test.startTest();
		PFAgreementUpdateAccount agrAcc = new PFAgreementUpdateAccount();
		agrAcc.updateActiveAgrmntCount(agrmList);
		Test.stopTest();

		Account acc = [SELECT id, Franchise_Agreement__c
						FROM Account
						WHERE Name = 'Test-0'];
		
		// Verify that Account field was updated
		System.debug('Franchise Agreement = ' + acc.Franchise_Agreement__c);				
		System.assertNotEquals(acc.Franchise_Agreement__c, NULL);			
	}
	
}