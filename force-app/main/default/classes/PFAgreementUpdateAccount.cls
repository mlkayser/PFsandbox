/*
** manuela.lkayser June 2018
*/

public without sharing class PFAgreementUpdateAccount {
	public PFAgreementUpdateAccount() {
		
	}

    public void updateActiveAgrmntCount(List<PFAgreement__c> PFAgreements) {
    	System.debug('==================================');
 		System.debug('**** PFAgreementUpdateAccount ****');

    	// get record type id
        String FArecordTypeId = [SELECT Id 
    							FROM RecordType 
    							WHERE sobjecttype = 'PFAgreement__c' 
    							AND name = 'Franchise Agreement'].Id;
    	System.debug('Record type id = ' + FArecordTypeId);
        
        // get list of Accounts IDs
        List<Id> accIds = new List<Id>();
        for  (PFAgreement__c agrmnt:PFAgreements) {
            accIds.add(agrmnt.Club_Name__c);
        }

        // map Ids with Account records
        List<Account> accsToUpdate = new List<Account>(); 
        Map<ID, Account> accMap = new Map<ID, Account>([
                                SELECT id, Status__c, Group_Name__c, Has_Active_FA__c, Franchise_Agreement__c
                                FROM Account
                                WHERE id IN :accIds]);
        System.debug('Accounts list size = '  + accsToUpdate.size());

        for  (PFAgreement__c agrmnt:PFAgreements) {
 			
        	System.debug('Franchise Agreement Name = ' + agrmnt.Name);
        	System.debug('Franchise Agreement Record Type Name = ' + agrmnt.RecordType.Name);
            System.debug('Franchise Agreement Active = ' + agrmnt.Active_Agreement__c);

       		// process if Franchise Agreement
        	if (agrmnt.RecordTypeId == FArecordTypeId) {

       			// select Account with PFagreement
                Account acc = accMap.get(agrmnt.Club_Name__c); 
                System.debug('Account Status = ' + acc.Status__c);
                System.debug('Account Group Name = ' + acc.Group_Name__c);

                // process if Status__c or Group_Name__c have a value
                if (!(String.isBlank(acc.Status__c) || String.isBlank(acc.Group_Name__c))) {
                    
                    // if agreement is active, add it to the account
                    if (agrmnt.Active_Agreement__c) {
                        acc.Franchise_Agreement__c = agrmnt.Id;
                        accsToUpdate.add(acc);
                    }

           		    // update Number_of_Active_Franchise_Agreement field if numbers don't match
                    /*Integer PFAgrmntCount = agrmnt.Active_Agreement__c == true ? 1 : 0;
                    System.debug('Is active agreemet ? ' + agrmnt.Active_Agreement__c);
                    System.debug('Count = ' + PFAgrmntCount);

            		if (acc.Number_of_Active_Franchise_Agreements__c != PFAgrmntCount) {
    	        		// update field
    	        		acc.Number_of_Active_Franchise_Agreements__c = PFAgrmntCount; 
                        System.debug('Number_of_Active_Franchise_Agreements__c = ' + acc.Number_of_Active_Franchise_Agreements__c);
                        accsToUpdate.add(acc);
                    }*/ 	
                }									
        	} 
        }
        	
        // update Accounts       	
        // put all the values from the List to Map to remove duplicate values
        Map<id,Account> accsToUpdateMap = new Map<id,Account>();
        accsToUpdateMap.putall(accsToUpdate);
        if (accsToUpdateMap.size()>0) {
            update accsToUpdateMap.values();
            System.debug('Accounts updated ' + accsToUpdateMap.size());
        }  
    }
}