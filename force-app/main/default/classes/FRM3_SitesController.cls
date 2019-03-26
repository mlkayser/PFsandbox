public without sharing class FRM3_SitesController {

    private static List<String> getAssignedGroups() {
        ID userId = UserInfo.getUserId();
        List<User> users = [SELECT User.ContactId FROM User WHERE Id = :userId];
        ID contactId = users[0].ContactId;
        
        List<Group__c> assignedGroups = [
            SELECT Name 
            FROM Group__c 
            WHERE Group_Status__c = 'Active' 
            AND Id IN (SELECT Group_Num__c FROM Group_Owner__c WHERE Owner_Contact__c = :contactId) 
            ORDER BY Name ASC
        ];

        List<String> groupNames = new List<String>();
        for (Group__c gg : assignedGroups) {
        	groupNames.add(gg.Name);
        }
        
        return groupNames;
    }

    @auraEnabled
    public static List<Sites__c> getSites() {

        List<String> groupNames = getAssignedGroups();
        System.debug('groupNames = ' + groupNames);

        List<Sites__c> sites = [
        	SELECT Id, Name, Status__c, Submitter__r.Name, Development_Region__c, ADA__c, Project__r.Name 
        	FROM Sites__c
        	WHERE Group__c IN :groupNames
        	ORDER BY Status__c
        ];

        System.debug('***DEBUG sites list size = ' + sites.size());
		return sites;
    }
 
}