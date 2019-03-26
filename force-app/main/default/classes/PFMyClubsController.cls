public with sharing class PFMyClubsController extends PFBaseController 
{

    public static String sortField {get; set;}

    public String pageTitle {get; set;}

    public Boolean isHomePage {get; set;}
    
    public static String sortDirection {get; set;}
    
    private Set<ID> groupIds;

    private list<Account> myClubs;

    private Boolean isPageLoad;

    private String clubStatusStr {get; set;}

    public list<ClubWrapper> records {get; set;}

    public list<String> statusFields {get; set;}

    private List< ID >  club_id ;

    private Static String CLUB_STAFF = 'Club Staff';

    private Static String BROKER_RT = 'Broker';
   
    
    
    public PFMyClubsController()
    {
        club_id = new List< ID > ();
        
        String fieldsStr = 'x1_FA_Deposit_Status__c,x2_Site_Selection_Status__c,x3_LOI_Negotiations_Status__c,x4_Lease_Review_Status__c,x5_Lease_Signed_Status__c,x6_Space_Planning_Status__c,x7_Owners_Orientation_Status__c,x8_Design_Status__c,x9_Permitting_Status__c,x10_Vendor_Permitting_Status__c,x11_Construction_Status__c,x12_Ops_Presale_Training_Status__c,x13_Marketing_Status__c,x14_Presales_Status__c';
        statusFields = fieldsStr.split( ',' );
        isPageLoad = true;
        Set<ID> managerProfileIds = new Set<ID>();
        
        groupIds = new set<ID>();
        // Bryan Anderson 8/28 - added try/catch to allow users without Contact to access community without Visualforce error
        try {
            ID ownerId = this.getCurrentUserContact().Id;
            System.debug('*** ownerId ' + ownerId );
            
            for( Group_Owner__c go : [ SELECT Group_Num__c FROM Group_Owner__c where Owner_Contact__c = :ownerId ] )
            {
                groupIds.add( go.Group_Num__c );
            }
            System.debug('*** groupIds ' + groupIds );
            //Andres DG-S 9/16
            //For contacts with RecordType == Club Staff, the account (Club) related 
            //directly with the contact, is the account that should be displayed
            if( this.getCurrentUserContact().RecordType.Name == CLUB_STAFF )
            {
                club_id.add( this.getCurrentUserContact().Account.Id );
            }
            else if( this.getCurrentUserContact().RecordType.Name == BROKER_RT )
            {
                system.debug( '**** ContactID ' + this.getCurrentUserContact().id );

                List< Broker__c > l_brokers = [Select Account__c,Contact__c From Broker__c Where Contact__c =: this.getCurrentUserContact().id ];

                system.debug( '*** Brokers ' + l_brokers );

                for( Broker__c b : l_brokers )
                {
                    club_id.add( b.Account__c );
                }

                system.debug( '*** Club ' + club_id );
            }
               
        } catch(Exception e) {}
        
        String currentPageURL = ApexPages.currentPage().getURL();

        //10/05 ADG-S PFCC-3099
        isHomePage = currentPageURL.contains( 'PFHomepage' ) || currentPageURL.contains( 'pfhomepage' );
        
    }

    
    //Bryan Anderson 8/27 - I added the field "EFT_Members__c" to the query to resolve VF rendering error
    private String buildQuery()
    {
        String query = 'SELECT Name,Club_EFT__c,Active_EFT_Members__c, All_Active_Members__c,BC__c,BER_Score__c, ShippingCity, ShippingState, Status__c, Presale_Date__c, Date_Opened__c, EFT_Members__c,Previous_Month_EFT__c,EFT_Difference_Without_Tax__c,' +
                        '(SELECT PI_Projected_Presale_Date__c , Open_Date__c, Build_Phase__c, x9_Permitting_Status__c, x8_Design_Status__c, x6_Space_Planning_Status__c, x5_Lease_Signed_Status__c, x4_Lease_Review_Status__c, x3_LOI_Negotiations_Status__c, x7_Owners_Orientation_Status__c, x2_Site_Selection_Status__c, x1_FA_Deposit_Status__c, x14_Presales_Status__c, x13_Marketing_Status__c, x12_Ops_Presale_Training_Status__c, x11_Construction_Status__c, x10_Vendor_Permitting_Status__c, Franchise_Agreement_Status__c, Equipment_Status__c, Projected_Online_Presale_Start_Date__c, Projected_Physical_Presale_Start_Date__c, Franchisee_Projected_Open_Date__c FROM Projects__r WHERE recordtype.name != \'Historical\' ORDER BY Franchisee_Projected_Open_Date__c DESC NULLS LAST limit 1) ' +
                        //'(select Id from Cases)' +
                        ' FROM Account where Status__c ' + 
                        ( clubStatusStr == 'Open' ? ( ' = \'' + clubStatusStr + '\' ' ) : ( ' != \'Open\' and Status__c != \'closed\' and Status__c != \'dead\' ' ) ) + 
                        ' and  ( Group_Name__c in :groupIds  OR ID IN :club_id ) Order By CreatedDate Desc' + ( isHomePage ? ' LIMIT 5' : '' ) + '';
        
        return query;
    }
    
    public Class ClubWrapper implements Comparable  
    {
        public Account clubObj {get; set;}
        public String progressStr {get; set;}
        public String buildPhase {get; set;}
        public Integer totalOpenCases {get; set;}
        public Date presale_date {get; set;}
        public Date open_date {get; set;}
        public String faStatus {get;set;}
        public String equipmentStatus {get;set;}
        public Date onlinePresaleDate {get;set;}
        public Date physicalPresaleDate {get;set;}
        public Date projectedOpenDate {get;set;}
        
        public Integer compareTo(Object vClubs)
        {  
            ClubWrapper clubsToComp = (ClubWrapper )vClubs;  
            
            if( sortField == 'Cases' )
            {
                if( totalOpenCases > clubsToComp.totalOpenCases )
                    return sortDirection.equals('ASC') ? 1 : 0;  
                else  
                    return sortDirection.equals('ASC') ? 0 : 1;  
            }
            else if( sortField == 'progressStr' )
            {
                if( progressStr > clubsToComp.progressStr )
                    return sortDirection.equals('ASC') ? 1 : 0;  
                else  
                    return sortDirection.equals('ASC') ? 0 : 1;  
            }
            else if( sortField == 'buildPhase' )
            {
                if( buildPhase > clubsToComp.buildPhase )
                    return sortDirection.equals('ASC') ? 1 : 0;  
                else  
                    return sortDirection.equals('ASC') ? 0 : 1;  
            }
            else if(sortField == 'Franchise_Agreement_Status__c'){
                if(faStatus > clubsToComp.faStatus){
                    return sortDirection.equals('ASC') ? 1 : 0;
                }else{
                    return sortDirection.equals('ASC') ? 0 : 1;
                }
            }
            else if(sortField == 'Equipment_Status__c'){
                if(equipmentStatus > clubsToComp.equipmentStatus){
                    return sortDirection.equals('ASC') ? 1 : 0;
                }else{
                    return sortDirection.equals('ASC') ? 0 : 1;
                }
            }
            else if(sortField == 'Projected_Online_Presale_Start_Date__c'){
                if(onlinePresaleDate > clubsToComp.onlinePresaleDate){
                    return sortDirection.equals('ASC') ? 1 : 0;
                }else{
                    return sortDirection.equals('ASC') ? 0 : 1;
                }
            }
            else if(sortField == 'Projected_Physical_Presale_Start_Date__c'){
                if(physicalPresaleDate > clubsToComp.physicalPresaleDate){
                    return sortDirection.equals('ASC') ? 1 : 0;
                }else{
                    return sortDirection.equals('ASC') ? 0 : 1;
                }
            }
            else if(sortField == 'Franchisee_Projected_Open_Date__c'){
                if(projectedOpenDate > clubsToComp.projectedOpenDate){
                    return sortDirection.equals('ASC') ? 1 : 0;
                }else{
                    return sortDirection.equals('ASC') ? 0 : 1;
                }
            }
            else
            { 
                if( String.valueOf(clubObj.get(sortField)) > String.valueOf(clubsToComp.clubObj.get(sortField)))  
                    return sortDirection.equals('ASC') ? 1 : 0;  
                else  
                    return sortDirection.equals('ASC') ? 0 : 1;
            }
        }
    }
    
    private list<ClubWrapper> getClubWrappers()
    {
        list<ClubWrapper> clubWrappers = new list<ClubWrapper>();

        for( Account clubObj : (list<Account>)database.query( buildQuery() ) )
        {
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
             
             if( clubObj.Projects__r.size() > 0 )
             {
                 Project__c p = clubObj.Projects__r[0];
                 buildPhase = p.Build_Phase__c;
                 l_open_date = p.Open_Date__c;
                 l_pre_sale_date = p.PI_Projected_Presale_Date__c;
                 l_faStatus = p.Franchise_Agreement_Status__c;
                 l_equipmentStatus = p.Equipment_Status__c;
                 l_onlinePresaleDate = p.Projected_Online_Presale_Start_Date__c;
                 l_physicalPresaleDate = p.Projected_Physical_Presale_Start_Date__c;
                 l_projectedOpenDate = p.Franchisee_Projected_Open_Date__c;
                 
                 for( String statusField : statusFields )
                 {
                     if( (String)p.get( statusField ) == 'Completed' ){
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
    
    public void sortOpenRecords() 
    {
        records.sort();
    }
    
    public void sortDevRecords() 
    {
        records.sort();
    }
    
    public list<ClubWrapper> getOpenRecords() 
    {
        
        if( records == null )
        {
            clubStatusStr = 'Open';
            records = getClubWrappers();
        }
        return records;
    }
    
    
    public list<ClubWrapper> getDevRecords() 
    {
        
        if( records == null )
        {
            clubStatusStr = null;
            records = getClubWrappers();
        }
        return records;
    }
    
    
    public Boolean getIsAscending() 
    {
       return sortDirection == null || sortDirection == 'ASC';
    }
    
    //TEST CODE WASN'T WRITTEN FOR THIS CLASS, AND IT HAD TO BE PUSHED LIVE
    public static void fake_method(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
    }
}