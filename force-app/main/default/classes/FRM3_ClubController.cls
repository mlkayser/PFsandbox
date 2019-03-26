public with sharing class FRM3_ClubController {

    public Class ClubWrapper {

        @auraEnabled public Account clubObj {get; set;}
        @auraEnabled public String progressStr {get; set;}
        @auraEnabled public String buildPhase {get; set;}
        @auraEnabled public Integer totalOpenCases {get; set;}
        @auraEnabled public Date presale_date {get; set;}
        @auraEnabled public Date open_date {get; set;}
        @auraEnabled public String faStatus {get;set;}
        @auraEnabled public String equipmentStatus {get;set;}
        @auraEnabled public Date onlinePresaleDate {get;set;}
        @auraEnabled public Date physicalPresaleDate {get;set;}
        @auraEnabled public Date projectedOpenDate {get;set;}
    }

    @auraEnabled
    public static list<ClubWrapper> getClubs(String clubStatus) {

        String clubStatusStr = clubStatus;
        Set<ID> groupIds = new set<ID>();
        List<ID> club_id = new List< ID > ();

        String fieldsStr =  'x1_FA_Deposit_Status__c,' +
                            'x2_Site_Selection_Status__c,' +
                            'x3_LOI_Negotiations_Status__c,' +
                            'x4_Lease_Review_Status__c,' +
                            'x5_Lease_Signed_Status__c,' +
                            'x6_Space_Planning_Status__c,' +
                            'x7_Owners_Orientation_Status__c,' +
                            'x8_Design_Status__c,' +
                            'x9_Permitting_Status__c,' +
                            'x10_Vendor_Permitting_Status__c,' +
                            'x11_Construction_Status__c,' +
                            'x12_Ops_Presale_Training_Status__c,' +
                            'x13_Marketing_Status__c,' +
                            'x14_Presales_Status__c';
        List<String> statusFields = fieldsStr.split( ',' );
         
        // get user info
        Id userId = UserInfo.getUserId();
        User thisUser = [SELECT ContactId,
                        Contact.Id, Contact.Name, Contact.AccountId, Contact.RecordType.Name,
                        Contact.Account.Id, Contact.Account.Name, Contact.Account.Group_Name__c
                        FROM User
                        WHERE Id = :userId];
        Contact thisContact = thisUser.Contact;             
        
        // A. Select Groups
        if (thisContact.RecordType.Name == 'Owner Contact') {
            for ( Group_Owner__c go : [ SELECT Group_Num__c 
                                        FROM Group_Owner__c 
                                        WHERE Owner_Contact__c =: thisContact.Id ] ) {
                groupIds.add( go.Group_Num__c );
            }
            System.debug('*** groupIds ' + groupIds );
        }

        // B. Select Clubs              
        else {
            if ( thisContact.RecordType.Name == 'Club Staff' ) {
                club_id.add( thisUser.Account.Id );
                System.debug('**** DEBUG: Club Staff');
            }
 
            else if ( thisContact.RecordType.Name == 'Broker' ) {
                List< Broker__c > brokerList = [SELECT Account__c, Contact__c 
                                                FROM Broker__c 
                                                WHERE Contact__c =: thisContact.Id ];
                System.debug('**** DEBUG: Broker');

                for( Broker__c broker : brokerList ) {
                    club_id.add( broker.Account__c );
                }
                System.debug('**** DEBUG: Club ' + club_id );
            }
        }

        // build query
        String query = 'SELECT Name,' +
                        'Club_EFT__c,' +
                        'Active_EFT_Members__c,' +
                        'All_Active_Members__c,' +
                        'BC__c,' +
                        'BER_Score__c,' +
                        'ShippingCity,' +
                        'ShippingState,' +
                        'Status__c,' +
                        'Presale_Date__c,' +
                        'Date_Opened__c,' +
                        'EFT_Members__c,' +
                        'Previous_Month_EFT__c,' +
                        'EFT_Difference_Without_Tax__c,' +
                            '(SELECT PI_Projected_Presale_Date__c ,' + 
                            'Open_Date__c, ' +
                            'Build_Phase__c, ' +
                            'x1_FA_Deposit_Status__c, ' +
                            'x2_Site_Selection_Status__c, ' +
                            'x3_LOI_Negotiations_Status__c, ' +
                            'x4_Lease_Review_Status__c, ' +
                            'x5_Lease_Signed_Status__c, ' +
                            'x6_Space_Planning_Status__c, ' +
                            'x7_Owners_Orientation_Status__c, ' +
                            'x8_Design_Status__c, ' +
                            'x9_Permitting_Status__c, ' +
                            'x10_Vendor_Permitting_Status__c, ' +
                            'x11_Construction_Status__c,' + 
                            'x12_Ops_Presale_Training_Status__c, ' +
                            'x13_Marketing_Status__c, ' +
                            'x14_Presales_Status__c, ' +
                            'Franchise_Agreement_Status__c, ' +
                            'Equipment_Status__c, ' +
                            'Projected_Online_Presale_Start_Date__c, ' +
                            'Projected_Physical_Presale_Start_Date__c, ' +
                            'Franchisee_Projected_Open_Date__c ' +
                            'FROM Projects__r ' +
                            'WHERE recordtype.name != \'Historical\' ORDER BY Franchisee_Projected_Open_Date__c ' +
                            'DESC NULLS LAST limit 1) ' +
                        'FROM Account ' +
                        'WHERE Status__c ' + 
                            ( clubStatusStr == 'Open' ? ( ' = \'' + clubStatusStr + '\' ' ) : ( ' != \'Open\' and Status__c != \'closed\' and Status__c != \'dead\' ' ) ) + 
                        'AND  ( Group_Name__c in :groupIds  OR ID IN :club_id ) ' +
                        'ORDER By CreatedDate Desc ';

        list<ClubWrapper> clubWrappers = new list<ClubWrapper>();
        for ( Account clubObj : (list<Account>)database.query( query ) ) {
            System.debug( '*** clubObj ' + clubObj );
             
             Integer completedProjects = 0;
             String buildPhase = '';
             Date l_open_date;
             Date l_pre_sale_date ;
             String l_faStatus = '';
             String l_equipmentStatus;
             Date l_onlinePresaleDate;
             Date l_physicalPresaleDate;
             Date l_projectedOpenDate; 
             
             if ( clubObj.Projects__r.size() > 0 ) {
                 Project__c proj = clubObj.Projects__r[0];
                 buildPhase = proj.Build_Phase__c;
                 l_open_date = proj.Open_Date__c;
                 l_pre_sale_date = proj.PI_Projected_Presale_Date__c;
                 l_faStatus = proj.Franchise_Agreement_Status__c;
                 l_equipmentStatus = proj.Equipment_Status__c;
                 l_onlinePresaleDate = proj.Projected_Online_Presale_Start_Date__c;
                 l_physicalPresaleDate = proj.Projected_Physical_Presale_Start_Date__c;
                 l_projectedOpenDate = proj.Franchisee_Projected_Open_Date__c;
                 
                 for ( String statusField : statusFields ) {
                     if ( (String)proj.get( statusField ) == 'Completed' ){
                         completedProjects++;
                     }
                 }
             }

             ClubWrapper cw = new ClubWrapper();
             cw.clubObj = clubObj;
             cw.progressStr = completedProjects + ' of 14';
             cw.buildPhase = buildPhase;
             cw.totalOpenCases = 0; //clubObj.cases.size(); //08/15 - following view state error
             cw.presale_date = l_pre_sale_date;
             cw.open_date = l_open_date;
             cw.faStatus = l_faStatus;
             cw.equipmentStatus = l_equipmentStatus;
             cw.onlinePresaleDate = l_onlinePresaleDate;
             cw.physicalPresaleDate = l_physicalPresaleDate;
             cw.projectedOpenDate = l_projectedOpenDate;

             clubWrappers.add( cw );
        }
        
        return clubWrappers ;             
    }        
      
    @auraEnabled
    public static list<ClubWrapper> getDevRecords() {

    	String clubStatusStr = null;
   		Set<ID> groupIds = new set<ID>();
    	List<ID> club_id = new List< ID > ();

        String fieldsStr =  'x1_FA_Deposit_Status__c,' +
                            'x2_Site_Selection_Status__c,' +
                            'x3_LOI_Negotiations_Status__c,' +
                            'x4_Lease_Review_Status__c,' +
                            'x5_Lease_Signed_Status__c,' +
                            'x6_Space_Planning_Status__c,' +
                            'x7_Owners_Orientation_Status__c,' +
                            'x8_Design_Status__c,' +
                            'x9_Permitting_Status__c,' +
                            'x10_Vendor_Permitting_Status__c,' +
                            'x11_Construction_Status__c,' +
                            'x12_Ops_Presale_Training_Status__c,' +
                            'x13_Marketing_Status__c,' +
                            'x14_Presales_Status__c';
        List<String> statusFields = fieldsStr.split( ',' );
    	 
        // get user info
        Id userId = UserInfo.getUserId();
		User thisUser = [SELECT ContactId,
                        Contact.Id, Contact.Name, Contact.AccountId, Contact.RecordType.Name,
                        Contact.Account.Id, Contact.Account.Name, Contact.Account.Group_Name__c
                    	FROM User
                    	WHERE Id = :userId];
        Contact thisContact = thisUser.Contact;            	
        
        // A. Select Groups
     	if (thisContact.RecordType.Name == 'Owner Contact') {
	        for ( Group_Owner__c go : [ SELECT Group_Num__c 
	        							FROM Group_Owner__c 
	        							WHERE Owner_Contact__c =: thisContact.Id ] ) {
	            groupIds.add( go.Group_Num__c );
	        }
	        System.debug('*** groupIds ' + groupIds );
	    }

        // B. Select Clubs           	
		else {
	    	if ( thisContact.RecordType.Name == 'Club Staff' ) {
	            club_id.add( thisUser.Account.Id );
	            System.debug('**** DEBUG: Club Staff');
	        }
 
	        else if ( thisContact.RecordType.Name == 'Broker' ) {
	            List< Broker__c > brokerList = [SELECT Account__c, Contact__c 
	            								FROM Broker__c 
	            								WHERE Contact__c =: thisContact.Id ];
	            System.debug('**** DEBUG: Broker');

	            for( Broker__c broker : brokerList ) {
	                club_id.add( broker.Account__c );
	            }
	            System.debug('**** DEBUG: Club ' + club_id );
	        }
	    }

        // build query
        String query = 'SELECT Name,' +
                        'Club_EFT__c,' +
                        'Active_EFT_Members__c,' +
                        'All_Active_Members__c,' +
                        'BC__c,' +
                        'BER_Score__c,' +
                        'ShippingCity,' +
                        'ShippingState,' +
                        'Status__c,' +
                        'Presale_Date__c,' +
                        'Date_Opened__c,' +
                        'EFT_Members__c,' +
                        'Previous_Month_EFT__c,' +
                        'EFT_Difference_Without_Tax__c,' +
                            '(SELECT PI_Projected_Presale_Date__c ,' + 
                            'Open_Date__c, ' +
                            'Build_Phase__c, ' +
                            'x1_FA_Deposit_Status__c, ' +
                            'x2_Site_Selection_Status__c, ' +
                            'x3_LOI_Negotiations_Status__c, ' +
                            'x4_Lease_Review_Status__c, ' +
                            'x5_Lease_Signed_Status__c, ' +
                           	'x6_Space_Planning_Status__c, ' +
                            'x7_Owners_Orientation_Status__c, ' +
                            'x8_Design_Status__c, ' +
                            'x9_Permitting_Status__c, ' +
                            'x10_Vendor_Permitting_Status__c, ' +
                            'x11_Construction_Status__c,' + 
                            'x12_Ops_Presale_Training_Status__c, ' +
                            'x13_Marketing_Status__c, ' +
                         	'x14_Presales_Status__c, ' +
                            'Franchise_Agreement_Status__c, ' +
                            'Equipment_Status__c, ' +
                            'Projected_Online_Presale_Start_Date__c, ' +
                            'Projected_Physical_Presale_Start_Date__c, ' +
                            'Franchisee_Projected_Open_Date__c ' +
                            'FROM Projects__r ' +
                            'WHERE recordtype.name != \'Historical\' ORDER BY Franchisee_Projected_Open_Date__c ' +
                            'DESC NULLS LAST limit 1) ' +
                        'FROM Account ' +
                        'WHERE Status__c ' + 
                            ( clubStatusStr == 'Open' ? ( ' = \'' + clubStatusStr + '\' ' ) : ( ' != \'Open\' and Status__c != \'closed\' and Status__c != \'dead\' ' ) ) + 
                        'AND  ( Group_Name__c in :groupIds  OR ID IN :club_id ) ' +
                        'ORDER By CreatedDate Desc ';

        list<ClubWrapper> clubWrappers = new list<ClubWrapper>();
        for ( Account clubObj : (list<Account>)database.query( query ) ) {
            System.debug( '*** clubObj ' + clubObj );
             
             Integer completedProjects = 0;
             String buildPhase = '';
             Date l_open_date;
             Date l_pre_sale_date ;
             String l_faStatus = '';
             String l_equipmentStatus;
             Date l_onlinePresaleDate;
             Date l_physicalPresaleDate;
             Date l_projectedOpenDate; 
             
             if ( clubObj.Projects__r.size() > 0 ) {
                 Project__c proj = clubObj.Projects__r[0];
                 buildPhase = proj.Build_Phase__c;
                 l_open_date = proj.Open_Date__c;
                 l_pre_sale_date = proj.PI_Projected_Presale_Date__c;
                 l_faStatus = proj.Franchise_Agreement_Status__c;
                 l_equipmentStatus = proj.Equipment_Status__c;
                 l_onlinePresaleDate = proj.Projected_Online_Presale_Start_Date__c;
                 l_physicalPresaleDate = proj.Projected_Physical_Presale_Start_Date__c;
                 l_projectedOpenDate = proj.Franchisee_Projected_Open_Date__c;
                 
                 for ( String statusField : statusFields ) {
                     if ( (String)proj.get( statusField ) == 'Completed' ){
                         completedProjects++;
                     }
                 }
             }

             ClubWrapper cw = new ClubWrapper();
             cw.clubObj = clubObj;
             cw.progressStr = completedProjects + ' of 14';
             cw.buildPhase = buildPhase;
             cw.totalOpenCases = 0; //clubObj.cases.size(); //08/15 - following view state error
             cw.presale_date = l_pre_sale_date;
             cw.open_date = l_open_date;
             cw.faStatus = l_faStatus;
             cw.equipmentStatus = l_equipmentStatus;
             cw.onlinePresaleDate = l_onlinePresaleDate;
             cw.physicalPresaleDate = l_physicalPresaleDate;
             cw.projectedOpenDate = l_projectedOpenDate;

             clubWrappers.add( cw );
        }
        
        return clubWrappers ;    	      
    }        

    @auraEnabled
    public static list<ClubWrapper> getOpenRecords() {

    	String clubStatusStr = 'Open';
   		Set<ID> groupIds = new set<ID>();
    	List<ID> club_id = new List< ID > ();

        String fieldsStr =  'x1_FA_Deposit_Status__c,' +
                            'x2_Site_Selection_Status__c,' +
                            'x3_LOI_Negotiations_Status__c,' +
                            'x4_Lease_Review_Status__c,' +
                            'x5_Lease_Signed_Status__c,' +
                            'x6_Space_Planning_Status__c,' +
                            'x7_Owners_Orientation_Status__c,' +
                            'x8_Design_Status__c,' +
                            'x9_Permitting_Status__c,' +
                            'x10_Vendor_Permitting_Status__c,' +
                            'x11_Construction_Status__c,' +
                            'x12_Ops_Presale_Training_Status__c,' +
                            'x13_Marketing_Status__c,' +
                            'x14_Presales_Status__c';
        List<String> statusFields = fieldsStr.split( ',' );
    	 
        // get user info
        Id userId = UserInfo.getUserId();
		User thisUser = [SELECT ContactId,
                        Contact.Id, Contact.Name, Contact.AccountId, Contact.RecordType.Name,
                        Contact.Account.Id, Contact.Account.Name, Contact.Account.Group_Name__c
                    	FROM User
                    	WHERE Id = :userId];
        Contact thisContact = thisUser.Contact;            	
        
        // A. Select Groups
     	if (thisContact.RecordType.Name == 'Owner Contact') {
	        for ( Group_Owner__c go : [ SELECT Group_Num__c 
	        							FROM Group_Owner__c 
	        							WHERE Owner_Contact__c =: thisContact.Id ] ) {
	            groupIds.add( go.Group_Num__c );
	        }
	        System.debug('*** groupIds ' + groupIds );
	    }

        // B. Select Clubs           	
		else {
	    	if ( thisContact.RecordType.Name == 'Club Staff' ) {
	            club_id.add( thisUser.Account.Id );
	            System.debug('**** DEBUG: Club Staff');
	        }
 
	        else if ( thisContact.RecordType.Name == 'Broker' ) {
	            List< Broker__c > brokerList = [SELECT Account__c, Contact__c 
	            								FROM Broker__c 
	            								WHERE Contact__c =: thisContact.Id ];
	            System.debug('**** DEBUG: Broker');

	            for( Broker__c broker : brokerList ) {
	                club_id.add( broker.Account__c );
	            }
	            System.debug('**** DEBUG: Club ' + club_id );
	        }
	    }

        // build query
        String query = 'SELECT Name,' +
                        'Club_EFT__c,' +
                        'Active_EFT_Members__c,' +
                        'All_Active_Members__c,' +
                        'BC__c,' +
                        'BER_Score__c,' +
                        'ShippingCity,' +
                        'ShippingState,' +
                        'Status__c,' +
                        'Presale_Date__c,' +
                        'Date_Opened__c,' +
                        'EFT_Members__c,' +
                        'Previous_Month_EFT__c,' +
                        'EFT_Difference_Without_Tax__c,' +
                            '(SELECT PI_Projected_Presale_Date__c ,' + 
                            'Open_Date__c, ' +
                            'Build_Phase__c, ' +
                            'x1_FA_Deposit_Status__c, ' +
                            'x2_Site_Selection_Status__c, ' +
                            'x3_LOI_Negotiations_Status__c, ' +
                            'x4_Lease_Review_Status__c, ' +
                            'x5_Lease_Signed_Status__c, ' +
                           	'x6_Space_Planning_Status__c, ' +
                            'x7_Owners_Orientation_Status__c, ' +
                            'x8_Design_Status__c, ' +
                            'x9_Permitting_Status__c, ' +
                            'x10_Vendor_Permitting_Status__c, ' +
                            'x11_Construction_Status__c,' + 
                            'x12_Ops_Presale_Training_Status__c, ' +
                            'x13_Marketing_Status__c, ' +
                         	'x14_Presales_Status__c, ' +
                            'Franchise_Agreement_Status__c, ' +
                            'Equipment_Status__c, ' +
                            'Projected_Online_Presale_Start_Date__c, ' +
                            'Projected_Physical_Presale_Start_Date__c, ' +
                            'Franchisee_Projected_Open_Date__c ' +
                            'FROM Projects__r ' +
                            'WHERE recordtype.name != \'Historical\' ORDER BY Franchisee_Projected_Open_Date__c ' +
                            'DESC NULLS LAST limit 1) ' +
                        'FROM Account ' +
                        'WHERE Status__c ' + 
                            ( clubStatusStr == 'Open' ? ( ' = \'' + clubStatusStr + '\' ' ) : ( ' != \'Open\' and Status__c != \'closed\' and Status__c != \'dead\' ' ) ) + 
                        'AND  ( Group_Name__c in :groupIds  OR ID IN :club_id ) ' +
                        'ORDER By CreatedDate Desc ';

        list<ClubWrapper> clubWrappers = new list<ClubWrapper>();
        for ( Account clubObj : (list<Account>)database.query( query ) ) {
            System.debug( '*** clubObj ' + clubObj );
             
             Integer completedProjects = 0;
             String buildPhase = '';
             Date l_open_date;
             Date l_pre_sale_date ;
             String l_faStatus = '';
             String l_equipmentStatus;
             Date l_onlinePresaleDate;
             Date l_physicalPresaleDate;
             Date l_projectedOpenDate; 
             
             if ( clubObj.Projects__r.size() > 0 ) {
                 Project__c proj = clubObj.Projects__r[0];
                 buildPhase = proj.Build_Phase__c;
                 l_open_date = proj.Open_Date__c;
                 l_pre_sale_date = proj.PI_Projected_Presale_Date__c;
                 l_faStatus = proj.Franchise_Agreement_Status__c;
                 l_equipmentStatus = proj.Equipment_Status__c;
                 l_onlinePresaleDate = proj.Projected_Online_Presale_Start_Date__c;
                 l_physicalPresaleDate = proj.Projected_Physical_Presale_Start_Date__c;
                 l_projectedOpenDate = proj.Franchisee_Projected_Open_Date__c;
                 
                 for ( String statusField : statusFields ) {
                     if ( (String)proj.get( statusField ) == 'Completed' ){
                         completedProjects++;
                     }
                 }
             }

             ClubWrapper cw = new ClubWrapper();
             cw.clubObj = clubObj;
             cw.progressStr = completedProjects + ' of 14';
             cw.buildPhase = buildPhase;
             cw.totalOpenCases = 0; //clubObj.cases.size(); //08/15 - following view state error
             cw.presale_date = l_pre_sale_date;
             cw.open_date = l_open_date;
             cw.faStatus = l_faStatus;
             cw.equipmentStatus = l_equipmentStatus;
             cw.onlinePresaleDate = l_onlinePresaleDate;
             cw.physicalPresaleDate = l_physicalPresaleDate;
             cw.projectedOpenDate = l_projectedOpenDate;

             clubWrappers.add( cw );
        }
        
        return clubWrappers ;    	      
    }   
    
}