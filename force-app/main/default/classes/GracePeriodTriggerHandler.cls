public with sharing class GracePeriodTriggerHandler {
	public static void updateAgreement(List<Grace_Period__c> gps, String status) {
		//Map<Id, Apttus__APTS_Agreement__c> agreementsToUpdate = new Map<Id, Apttus__APTS_Agreement__c>();
		Map<Id, PFAgreement__c> agreementsToUpdate = new Map<Id, PFAgreement__c>();
		
		for(Grace_Period__c gp : gps) {
			//agreementsToUpdate.put(gp.ADA__c, new PFAgreement__c(Id = gp.ADA__c, ADA_Status__c = status));
			agreementsToUpdate.put(gp.Area_Development_Agreement__c, new PFAgreement__c(Id = gp.Area_Development_Agreement__c, ADA_Status__c = status));
		}

		update agreementsToUpdate.values();
	}

	public static void updateAgreementWhenCureDateIsSet(List<Grace_Period__c> gps, Map<Id, Grace_Period__c> oldGps) {
		List<Grace_Period__c> relatedGps = new List<Grace_Period__c>(); 
		for(Grace_Period__c gp: gps) {
			if(gp.Cure_Date__c != null && gp.Cure_Date__c != oldGps.get(gp.Id).Cure_Date__c ) {
				relatedGps.add(gp);
			}
		}

		if(relatedGps.isEmpty()) return;

		updateAgreement(relatedGps, 'Active');
	}
}