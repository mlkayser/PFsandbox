/*
** manuela.lkayser June 2018
*/

@isTest
private class PFAgreementUpdateAccountJobTest  {
	
	@testsetup 
	static void setup() {
	    
        // create group
        Group__c grp = new Group__c(
            Name = 'Test Group',
            Group__c = 'G0001');
        insert grp;       
	    
		// create accounts
		List<Account> accList = new List<Account>();
		for(Integer i = 0; i < 200; i++) {
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

	    for(Integer i = 0; i < 200; i++) {
	    	PFAgreement__c agrm = new PFAgreement__c(
	    		Name = 'Test-' + i,
	    		RecordTypeId = RecordTypeId,
	    		Club_Name__c = accList[i].Id,
	    		Effective_Date__c = date.today(),
	    		Expiration_Date__c = date.today().addDays(7),
	    		SOX_Termination_Date__c = date.today().addDays(7));
	    	agrmList.add(agrm);
	    }
	    insert agrmList;
    }
	
	@isTest 
	static void test_job() {
		/*PFAgreement__c agrTest = [SELECT id, 
									RecordTypeId, 
									Active_Agreement__c, 
									Effective_Date__c, 
									Expiration_Date__c, 
									SOX_Termination_Date__c, 
									Club_Name__c 
								FROM PFAgreement__c 
								LIMIT 1];
		System.debug('TEST=====> Test data Record typd id = ' + agrTest.RecordTypeId);
		System.debug('TEST=====> Test data Effective date = ' + agrTest.Effective_Date__c);
		System.debug('TEST=====> Test data Expiration date = ' + agrTest.Expiration_Date__c);
		System.debug('TEST=====> Test data SOX termination date = ' + agrTest.SOX_Termination_Date__c);
		System.debug('TEST=====> Test data Active agreement = ' + agrTest.Active_Agreement__c);
		System.debug('TEST=====> Test data Club id = ' + agrTest.Club_Name__c);*/

		Test.startTest();
		PFAgreementUpdateAccountJob job = new PFAgreementUpdateAccountJob();
		ID batchId = Database.executeBatch(job);
		Test.stopTest();

		// verify that records were processes
		System.assertEquals(200, [SELECT count() FROM Account WHERE Franchise_Agreement__c != NULL]);
	}
	
}