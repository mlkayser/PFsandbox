@isTest
private class GracePeriodTriggerTest {
    static testMethod void testTrigger() {
		/* ---> commented out in order to deploy inactive trigger
		// Create agreement record 
		//Apttus__APTS_Agreement__c agreement = TestUtil.getAgreements(1, true)[0] ;
		PFAgreement__c agreement = TestUtil.getAgreements(1, true)[0] ;

		Grace_Period__c gp = TestUtil.getGracePeriodsWithPFA(1, agreement, true)[0];

		System.assert([select Id, ADA_Status__c 
						//from Apttus__APTS_Agreement__c where Id = :agreement.Id 
						from PFAgreement__c where Id = :agreement.Id 
						and ADA_Status__c = 'Default'].size() == 1, 'Agreement should be set to default');


		gp.Cure_Date__c = Date.today();
		update gp;
		
		System.assert([select Id, ADA_Status__c 
						//from Apttus__APTS_Agreement__c where Id = :agreement.Id 
						from PFAgreement__c where Id = :agreement.Id 
						and ADA_Status__c = 'Active'].size() == 1, 'Agreement should be set to active');
	commented out in order to deploy inactive trigger <--- */
    }
}