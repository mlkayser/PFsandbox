public class FRM3_ClubBrandExcellence {

	@auraEnabled
    public static List<Brand_Excellence__c> getBrandExcellence(String accId) {

    	List<Brand_Excellence__c> brandEx = new List<Brand_Excellence__c>();
    	brandEx = [
    		SELECT id, Name, RecordType.Name, Survey_Date__c, Grade__c, Account__r.Name
			FROM Brand_Excellence__c
			WHERE Account__c = :accId
			ORDER BY Survey_Date__c DESC
		];

		return brandEx;
    }
	
}