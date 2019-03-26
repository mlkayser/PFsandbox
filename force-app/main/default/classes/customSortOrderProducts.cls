global class customSortOrderProducts {

	// from https://developer.salesforce.com/forums?id=906F000000094fvIAA
	webservice static String customSort(Id oppID) {
    	
    	//pull back the OLIs in a specific sort order
    	List<OpportunityLineItem> olis = [
    		SELECT oli.Id
    		FROM OpportunityLineItem oli
    		WHERE oli.OpportunityId = :oppId
    		ORDER BY oli.Sort_Order__c, oli.PricebookEntry.Product2.Name
    	];
    	
    	//build the comma separated 15 character OLI Id string to send back
    	String sortedIds = '';					  
    	for(OpportunityLineItem oli : olis) {
    		sortedIds += String.valueOf(oli.Id).substring(0,15) + ',';		
    	}
    	
    	//remove the last comma
    	sortedIds = sortedIds.substring(0,sortedIds.length() - 1);
    	return sortedIds;
    }
}