public class FRM3_CasesController {

    private static List<String> getAssignedGroups() {
        ID userId = UserInfo.getUserId();
        List<User> users = [SELECT User.ContactId FROM User WHERE Id = :userId];
        ID contactId = users[0].ContactId;
        
        List<Group__c> assignedGroups = [
            SELECT Group__c 
            FROM Group__c 
            WHERE Group_Status__c = 'Active' 
            AND Id IN (SELECT Group_Num__c FROM Group_Owner__c WHERE Owner_Contact__c = :contactId) 
            ORDER BY Name ASC
        ];

        List<String> groupNum = new List<String>();
        for (Group__c gg : assignedGroups) {
        	groupNum.add(gg.Group__c);
        }
        
        return groupNum;
    }

    @auraEnabled
    public static List<Case> getCases() {

        List<String> groupNum = getAssignedGroups();
        System.debug('groupNam = ' + groupNum);

        List<Case> cases = [
        	SELECT CaseNumber, Account.Name, Reason, Status, CreatedDate
			FROM Case
			WHERE Group_Number__c IN :groupNum
			ORDER BY CreatedDate DESC
			LIMIT 50
        ];

        System.debug('***DEBUG cases list size = ' + cases.size());
		return cases;
    }

}