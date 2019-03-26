public class FRM3_ClubDetailController {

	@auraEnabled
	public static Account getClubInfo(String recordId) {
		Account acc  = [
            SELECT Name,
				ShippingStreet,
				ShippingCity,
				ShippingState,
				ShippingPostalCode,
				Club_Assigned_Email__c,
				PF_Dedicated_Phone_Number__c,
				Phone,
				Status__c, 
				PF_Club_Id__c,
				POS_Club_Id__c,
				Project_Open_Date__c,
				Date_Opened__c,
				Facebook_URL__c,
				Twitter_URL__c,
				Account.Instagram_URL__c,
				Google_Plus_URL__c,
				Website,
				Operations_Region__c,							
				Square_Footage__c,
				Group_Name__r.Group__c,
				Group_Name__r.Name
			FROM Account 
			WHERE Id =: recordId 
		];
        
		return acc;
	}

	@auraEnabled
	public static Community_Settings__c getCommSettings() {
		Community_Settings__c cs = [
            SELECT Facebook_URL__c, 
				Twitter_URL__c, 
				Instagram_URL__c, 
				Google_Plus_URL__c 
			FROM Community_Settings__c 
			LIMIT 1
        ];
    System.debug('**** DEBUG custom settings' + cs.Twitter_URL__c);                   
		return Community_Settings__c.getInstance();

	}

    @AuraEnabled
    public static List<AccountShare> getAccounts() {
        return [SELECT Id, AccountId, UserOrGroupId, RowCause 
                FROM AccountShare 
                WHERE AccountId = '0010a00001FBY6hAAH' 
                AND (RowCause = 'TerritoryManual' OR RowCause = 'Territory')];
    }

    @auraEnabled
    public static String getCorpContacts(String accId) {

        Set<Id> groupIds = new Set<Id>();
        Set<Id> territoryIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        List<User> corpContacts = new List<User>();

        //**** EDIT 
        List<AccountShare> accountShares = [
            SELECT Id, AccountId, UserOrGroupId, RowCause 
            FROM AccountShare 
            WHERE AccountId = :accId 
            AND (RowCause = 'TerritoryManual' OR RowCause = 'Territory')
        ];    
        
         /*List<sObject> accountShares = Database.query(
            'SELECT Id, AccountId, UserOrGroupId, RowCause ' +
            'FROM AccountShare ' +
            'WHERE AccountId = :accId ' +
            'AND (RowCause = \'TerritoryManual\' OR RowCause = \'Territory\')'
        );*/
        
        /*if (Test.isRunningTest()) {
            accountShares = [
                SELECT Id, UserOrGroupId 
                FROM AccountShare 
                WHERE AccountId = :accID
            ];
            userIds.add(UserInfo.getUserId());
        }*/
       
        if (accountShares.size() > 0) {                
            //for (AccountShare acs :accountShares) {
                //groupIds.add(acs.UserOrGroupId);
            //}    
            for (sObject acs :accountShares) {
                groupIds.add((String)acs.get('UserOrGroupId'));
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
                
        return accId;        
    }   

    public Class ClubMilestoneWrapper {

        @auraEnabled public String projectId {get; set;}
        @auraEnabled public List<String> options {get; set;}
        @auraEnabled public String status {get; set;}
        @auraEnabled public Integer statNum {get; set;}
        @auraEnabled public String progress {get; set;}
    }

    @auraEnabled 
    public static Map<String,ClubMilestoneWrapper> getAllMilestones(String accId) {

        System.debug('****DEBUG getMilestone');
        System.debug('****DEBUG accId = ' + accId);

        Map<String,ClubMilestoneWrapper> milestoneMap = new Map<String,ClubMilestoneWrapper>();
        String milestone;

        List<Project__c> projList = [
            SELECT Id, Franchisee_Projected_Open_Date__c, Open_Date__c,
                Real_Estate_Status__c, Franchise_Agreement_Status__c, Design_Status_new__c, Permitting_Status_New__c, 
                Construction_Status__c, Equipment_Status__c, Presale_Operations_Status__c, Pre_Sale_Status__c
            FROM Project__c 
            WHERE Club_Location__c = :accId
            AND RecordType.Name != 'Historical' 
            //AND Scope_Type__c = 'Relo' 
            ORDER BY Open_Date__c DESC 
            LIMIT 1
        ];
        System.debug('****DEBUG projectList size = ' + projList.size());

        if (projList.size() > 0) {
            Project__c proj = projList[0];

            milestone = 'RealEstate';
            ClubMilestoneWrapper RE_milestone = getMilestone(proj.Real_Estate_Status__c, milestone, proj.Id);
            milestoneMap.put(milestone, RE_milestone);        
            
            milestone = 'FranchiseAgreement';
            ClubMilestoneWrapper FA_milestone = getMilestone(proj.Franchise_Agreement_Status__c, milestone, proj.Id);
            milestoneMap.put(milestone, FA_milestone);        
 
            milestone = 'Design';
            ClubMilestoneWrapper DS_milestone = getMilestone(proj.Design_Status_new__c, milestone, proj.Id);
            milestoneMap.put(milestone, DS_milestone);        
            
            milestone = 'Permitting';
            ClubMilestoneWrapper PM_milestone = getMilestone(proj.Permitting_Status_New__c, milestone, proj.Id);
            milestoneMap.put(milestone, PM_milestone);        

            milestone = 'Construction';
            ClubMilestoneWrapper CS_milestone = getMilestone(proj.Construction_Status__c, milestone, proj.Id);
            milestoneMap.put(milestone, CS_milestone);        
            
            milestone = 'Equipment';
            ClubMilestoneWrapper EQ_milestone = getMilestone(proj.Equipment_Status__c, milestone, proj.Id);
            milestoneMap.put(milestone, EQ_milestone);        
 
            milestone = 'PreOpening';
            ClubMilestoneWrapper PO_milestone = getMilestone(proj.Presale_Operations_Status__c, milestone, proj.Id);
            milestoneMap.put(milestone, PO_milestone);        
            
            milestone = 'PreSale';
            ClubMilestoneWrapper PS_milestone = getMilestone(proj.Pre_Sale_Status__c, milestone, proj.Id);
            milestoneMap.put(milestone, PS_milestone);        
       }

        return milestoneMap;
    }

    @auraEnabled
    public static ClubMilestoneWrapper getMilestone(String status, String milestone, Id ProjectId) {
        
        System.debug('****DEBUG getMilestone');
        System.debug('****DEBUG status = ' + status);

        ClubMilestoneWrapper clubMilestone = new ClubMilestoneWrapper();
        String progress;
        Integer statNum = 0;
        Integer statNumTemp = 0;  
        List<String> options = new List<String>();      

        Schema.DescribeFieldResult fieldResult;
        if (milestone == 'RealEstate') {
            fieldResult = Project__c.Real_Estate_Status__c.getDescribe();
        }
        else if (milestone == 'FranchiseAgreement') {
            fieldResult = Project__c.Franchise_Agreement_Status__c.getDescribe();
        }
        else if (milestone == 'Design') {
            fieldResult = Project__c.Design_Status_new__c.getDescribe();
        }
        else if (milestone == 'Permitting') {
            fieldResult = Project__c.Permitting_Status_New__c.getDescribe();
        }
        else if (milestone == 'Construction') {
            fieldResult = Project__c.Construction_Status__c.getDescribe();
        }
        else if (milestone == 'Equipment') {
            fieldResult = Project__c.Equipment_Status__c.getDescribe();
        }
        else if (milestone == 'PreOpening') {
            fieldResult = Project__c.Presale_Operations_Status__c.getDescribe();
        }
        else if (milestone == 'PreSale') {
            fieldResult = Project__c.Pre_Sale_Status__c .getDescribe();
        }

        List<Schema.PicklistEntry> statusValues = fieldResult.getPicklistValues();  
        System.debug('***DEBUG fieldResult = ' + statusValues);

        for (Schema.PicklistEntry val : statusValues) {
            System.debug('***DEBUG loop = ' + val.getLabel());
         
            if (val.getLabel().indexOf('Not Started') == -1 
                && val.getLabel().indexOf('Denied') == -1 
                && val.getLabel().indexOf('Dead') == -1 
                && val.getLabel().indexOf('On Hold') == -1
                && val.getLabel().indexOf('Not Applicable') == -1
                && val.getLabel().indexOf('Rejected') == -1
            ) {
               
                statNumTemp = statNumTemp + 1;                
                options.add(val.getLabel());
                System.debug('***DEBUG options = ' + options);

                if (val.getlabel() == status) {
                    statNum = statNumTemp;
                }
            }   

            Decimal ii = statNumTemp;
            Decimal kk = statNum;

            if (ii==0) {
                progress = '0';
            } 
            else {
                Double dd = (kk/ii)*100;
                progress = String.valueof(dd);
            }

            if (status == 'Lease Signed' || status == 'Building Purchased') {
                progress = '100';
            } 
        }
        
        System.debug('***DEBUG options = ' + options);
        System.debug('***DEBUG status = ' + status);
        System.debug('***DEBUG progress = ' + progress);

        if (projectId != NULL) clubMilestone.projectId = projectId;
        clubMilestone.progress = progress;
        clubMilestone.options = options;
        clubMilestone.statNum = statNum;
        clubMilestone.status = status;

        System.debug('***DEGUB clubMilestone = ' + clubMilestone.progress);

        return clubMilestone;
     }
     
}