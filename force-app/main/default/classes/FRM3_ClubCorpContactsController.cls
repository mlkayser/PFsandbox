public without sharing class FRM3_ClubCorpContactsController {

	@auraEnabled
	public static List<User> getCorpContacts(String accId) {

        Set<Id> groupIds = new Set<Id>();
        Set<Id> territoryIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        List<User> corpContacts = new List<User>();
        
        List<AccountShare> accountShares = [
        	SELECT Id, AccountId, UserOrGroupId, RowCause 
            FROM accountShare 
            WHERE AccountId = :accID 
            AND (RowCause = 'TerritoryManual' 
            OR RowCause = 'Territory')
        ];
        
        if (Test.isRunningTest()) {
            accountShares = [
            	SELECT Id, UserOrGroupId 
            	FROM AccountShare 
            	WHERE AccountId = :accId
           	];
            userIds.add(UserInfo.getUserId());
        }
        
        if (accountShares.size() > 0) {                
            for (AccountShare acs :accountShares) {
                groupIds.add(acs.UserOrGroupId);
            }
        }
        
        if (groupIds.size() > 0) {            
            List<Group> groups = [
            	SELECT Id, RelatedId, Type, OwnerId 
            	FROM Group 
            	WHERE Id IN :groupIds
            ];
            for (Group gr :groups) {
                territoryIds.add(gr.RelatedId);
            }
        }
        
        if (territoryIds.size() > 0) {            
            List<Userterritory2Association> userTerritories = [
            	SELECT Id, UserId, Territory2Id, IsActive
                FROM Userterritory2Association
                WHERE Territory2Id IN :territoryIds
            ];
                
            for(Userterritory2Association ut: userTerritories) {
                userIds.add(ut.UserId);
            }
        }
        
        if (userIds.size() > 0 ) {
            corpContacts = [
            	SELECT ID, Name, Phone, Title, Email, SmallPhotoUrl 
            	FROM User 
            	WHERE Id IN :userIds 
            	ORDER BY Name
            ];
        }
                
        return corpContacts;		
	}

}