public class PFClubsController extends PFBaseController {
    
    private Set<ID> groupIds;
    private String clubStatusStr;
    public list<String> statusFields {get; set;}
    public PFClubsController(){
        String fieldsStr = 'x1_FA_Deposit_Status__c,x2_Site_Selection_Status__c,x3_LOI_Negotiations_Status__c,x4_Lease_Review_Status__c,x5_Lease_Signed_Status__c,x6_Space_Planning_Status__c,x7_Owners_Orientation_Status__c,x8_Design_Status__c,x9_Permitting_Status__c,x10_Vendor_Permitting_Status__c,x11_Construction_Status__c,x12_Ops_Presale_Training_Status__c,x13_Marketing_Status__c,x14_Presales_Status__c';
        statusFields = fieldsStr.split( ',' );
        groupIds = new set<ID>();
        //ID ownerId = this.getCurrentUserContact().Id;
        
        //for( Group_Owner__c go : [SELECT Group_Num__c FROM Group_Owner__c where Owner_Contact__c = :ownerId] ){
        //    groupIds.add( go.Group_Num__c );
        //}
    }
    
    private String buildQuery(){
        String query = 'SELECT Club_EFT__c,BER_Score__c,BC__c,Name, ShippingCity, ShippingState, Status__c, Presale_Date__c, Date_Opened__c, EFT_Members__c, ' +
                        '(SELECT Build_Phase__c, x9_Permitting_Status__c, x8_Design_Status__c, x6_Space_Planning_Status__c, x5_Lease_Signed_Status__c, x4_Lease_Review_Status__c, x3_LOI_Negotiations_Status__c, x7_Owners_Orientation_Status__c, x2_Site_Selection_Status__c, x1_FA_Deposit_Status__c, x14_Presales_Status__c, x13_Marketing_Status__c, x12_Ops_Presale_Training_Status__c, x11_Construction_Status__c, x10_Vendor_Permitting_Status__c FROM Projects__r limit 1)' +
            			' FROM Account where Status__c ' +
            			( clubStatusStr == 'Open' ? ( ' = \'' + clubStatusStr + '\' ' ) : ( ' != \'Open\' and Status__c != \'closed\' ' ) ) + 
            			' and Group_Name__c in :groupIds';
        
        return query;
    }
    
    
    public list<ClubWrapper> getOpenRecords() {
        clubStatusStr = 'Open';
        return getClubWrappers();
    }
    
    public list<ClubWrapper> getDevRecords() {
        clubStatusStr = null;
        return getClubWrappers();
    }
    
    public Class ClubWrapper{
        public Account clubObj {get; set;}
        public String progressStr {get; set;}
        public String buildPhase {get; set;}
    }
    
    private list<ClubWrapper> getClubWrappers(){
        list<ClubWrapper> clubWrappers = new list<ClubWrapper>();
        for( Account clubObj : (list<Account>)database.query( buildQuery() )  ){
             Integer completedProjects = 0;
             String buildPhase = '';
             if( clubObj.Projects__r.size() > 0 ){
                 Project__c p = clubObj.Projects__r[0];
                 buildPhase = p.Build_Phase__c;
                 
                 for( String statusField : statusFields ){
                     if( (String)p.get( statusField ) == 'Completed' ){
                         completedProjects++;
                     }
                 }
             }
             ClubWrapper cw = new ClubWrapper();
             cw.clubObj = clubObj;
             cw.progressStr = completedProjects + ' of 14';
             cw.buildPhase = buildPhase;
             clubWrappers.add( cw );
        }
        return clubWrappers ;
    }
}