public without sharing class FRM3_DelegatesController {

    private static List<Group__c> getAssignedGroups() {
        ID userId = UserInfo.getUserId();
        List<User> users = [SELECT User.ContactId FROM User WHERE Id = :userId];
        ID contactId;
        contactId = users[0].ContactId;
        List<Group__c> assignedGroups = [
            SELECT Name 
            FROM Group__c 
            WHERE Group_Status__c = 'Active' 
            AND Id IN (SELECT Group_Num__c FROM Group_Owner__c WHERE Owner_Contact__c = :contactId) 
            ORDER BY Name ASC
        ];
        return assignedGroups;
    }

    private static List<Account> getClubs(String thisGroup) {
        List<Account> clubs = [
            SELECT Id, 
				Franchise_Agreement__r.Responsible_Owner__r.FirstName, 
                Franchise_Agreement__r.Responsible_Owner__r.LastName, 
				Franchise_Agreement__r.Responsible_Owner__r.Email,
				Franchise_Agreement__r.Approved_Operator__r.FirstName,
                Franchise_Agreement__r.Approved_Operator__r.LastName,
				Franchise_Agreement__r.Approved_Operator__r.Email,
				Franchise_Agreement__r.Delegated_Administrator_1__r.FirstName, 
                Franchise_Agreement__r.Delegated_Administrator_1__r.LastName, 
				Franchise_Agreement__r.Delegated_Administrator_1__r.Email, 
				Franchise_Agreement__r.Delegated_Administrator_2__r.FirstName,   
                Franchise_Agreement__r.Delegated_Administrator_2__r.LastName,   
				Franchise_Agreement__r.Delegated_Administrator_2__r.Email,
				Area_Development_Agreement__r.Responsible_Owner__r.FirstName, 
                Area_Development_Agreement__r.Responsible_Owner__r.LastName, 
				Area_Development_Agreement__r.Responsible_Owner__r.Email, 
				Area_Development_Agreement__r.Approved_Operator__r.FirstName,
                Area_Development_Agreement__r.Approved_Operator__r.LastName,
				Area_Development_Agreement__r.Approved_Operator__r.Email,
				Area_Development_Agreement__r.Delegated_Administrator_1__r.FirstName, 
                Area_Development_Agreement__r.Delegated_Administrator_1__r.LastName,
				Area_Development_Agreement__r.Delegated_Administrator_1__r.Email, 
				Area_Development_Agreement__r.Delegated_Administrator_2__r.FirstName,
                Area_Development_Agreement__r.Delegated_Administrator_2__r.LastName,
				Area_Development_Agreement__r.Delegated_Administrator_2__r.Email	          	
            FROM Account
            WHERE Group_Name__c IN (SELECT Id from Group__c where Name = :thisGroup) 
            AND Status__c in ('Open', 'Presale')
            ORDER BY PF_Club_ID__c ASC 
        ];

        System.debug('***DEBUG Club list size = ' + clubs.size());
        return clubs;
    }

    @auraEnabled
    public static Map<Id,Contact> getDelegates() {

    	//List<Contact> delegates = new List<Contact>();
    	Map<Id, Contact> delegates = new Map<Id, Contact>();

        List<Group__c> assignedGroups = getAssignedGroups();
        System.debug('assignedGroups = ' + assignedGroups);

        for (Group__c gg : assignedGroups) {

            // Get List of Clubs for this Group
            List<Account> clubs = getClubs(gg.Name);  

            for (Account cc : clubs) {
	            // Responsible Owner	
	 			delegates.put(cc.Franchise_Agreement__r.Responsible_Owner__c, cc.Franchise_Agreement__r.Responsible_Owner__r); 	
	 			delegates.put(cc.Area_Development_Agreement__r.Responsible_Owner__c, cc.Area_Development_Agreement__r.Responsible_Owner__r); 

	            // Approved Operator	
	 			delegates.put(cc.Franchise_Agreement__r.Approved_Operator__c, cc.Franchise_Agreement__r.Approved_Operator__r); 	
	 			delegates.put(cc.Area_Development_Agreement__r.Approved_Operator__c, cc.Area_Development_Agreement__r.Approved_Operator__r); 

	            // Delegated Administrator1	
	 			delegates.put(cc.Franchise_Agreement__r.Delegated_Administrator_1__c, cc.Franchise_Agreement__r.Delegated_Administrator_1__r); 	
	 			delegates.put(cc.Area_Development_Agreement__r.Delegated_Administrator_1__c, cc.Area_Development_Agreement__r.Delegated_Administrator_1__r); 

	            // Delegated Administrator2	
	 			delegates.put(cc.Franchise_Agreement__r.Delegated_Administrator_2__c, cc.Franchise_Agreement__r.Delegated_Administrator_2__r); 	
	 			delegates.put(cc.Area_Development_Agreement__r.Delegated_Administrator_2__c, cc.Area_Development_Agreement__r.Delegated_Administrator_2__r); 
 			}
		}

        System.debug('***DEBUG Delegates map size = ' + delegates.size());
		return delegates;
    }

}