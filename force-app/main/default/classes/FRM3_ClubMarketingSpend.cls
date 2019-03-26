public class FRM3_ClubMarketingSpend {

	@auraEnabled
    public static List<Compliance__c> getMarketingSpend(String accId) {

    	List<Compliance__c> markSpend = new List<Compliance__c>();
    	markSpend = [
    		SELECT id, Name, Total_Marketing_Spend__c, mspend_Spend_Month__c
			FROM Compliance__c
			WHERE Club__c= :accId
			ORDER By mspend_Spend_Month__c DESC
		];

		return markSpend;
    }
 
}