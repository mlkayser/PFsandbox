/*
** manuela.lkayser June 2018
*/

public class PFAgreementUpdateAccountJob 
	implements Database.Batchable<sObject>, Database.Stateful {
	
	public Integer recordsProcessed = 0;	
	// get record type id
    String FArecordTypeId = [SELECT Id 
							FROM RecordType 
							WHERE sobjecttype = 'PFAgreement__c' 
							AND name = 'Franchise Agreement'].Id;

    String query = 'SELECT Id, Name, RecordType.Name, Club_Name__c, Active_Agreement__c ' +
    			   'FROM PFAgreement__c ' +
    			   'WHERE RecordTypeId = :FArecordTypeId';
	
	PFAgreementUpdateAccount agrAcc = new PFAgreementUpdateAccount();

	public Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('query = ' + query);
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<PFAgreement__c> scope) {
		// process each batch of records
		agrAcc.updateActiveAgrmntCount(scope);		
	}
	
	public void finish(Database.BatchableContext BC) {
		System.debug(recordsProcessed + ' records processed');
	}
	
}