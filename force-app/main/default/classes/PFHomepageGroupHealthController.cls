public class PFHomepageGroupHealthController extends PFBaseController {

    public MyGroupHealthWrapper myGroupHealth {get; set;}

    public Integer lastDraftStatus {get; set;}
	public Integer lastDraftTaxStatus {get; set;}
    
    public Integer FacebookCount{get;set;}
    public Integer GoogleCount{get;set;}
    public Integer TwitterCount{get;set;}
    public Integer YelpCount{get;set;}
    public Date StartDate{get;set;}
    public Date EndDate{get;set;}
    public Boolean ShowMe{get;set;}
    
    private Static String CLUB_STAFF = 'Club Staff';

    public PFHomepageGroupHealthController(){
        
        myGroupHealth = new MyGroupHealthWrapper();
        
        myGroupHealth.eft = new EFTWrapper();
        myGroupHealth.members = new MembersWrapper();
        myGroupHealth.totalCases = 0;
        
        myGroupHealth.eft.sumOfEFT = 0;
        myGroupHealth.eft.sumOfEFTTax = 0;
        myGroupHealth.eft.lastDraft = 0;
        myGroupHealth.eft.lastDraftTax = 0;
        myGroupHealth.members.totalMembers = 0;
        myGroupHealth.members.totalEFTMembers = 0;
        myGroupHealth.members.totalBCMMembers = 0;
        myGroupHealth.members.totalBCMEFTMembers = 0;
        myGroupHealth.members.bcm = 0;
        
        set<ID> groupIds = new set<ID>();

        //PFCC-2537 9/3/15 ADG-S Integreate this component in the club detail page
        String l_account_id = ApexPages.currentPage().getParameters().get('id');
        system.debug('*** l_account_id ' + l_account_id );

        
        //if l_account_id !=null, then the call has been made from 
        //PFClubDetail.page, if not, the call has been made from the Home page
        
        //if (l_account_id == null) {
        //    ShowMe = True;
		//  Date SelectedDate = Date.today();
	    //   StartDate = SelectedDate.addMonths(-1).toStartOfMonth();
    	//    EndDate = StartDate.addDays(date.daysInMonth(StartDate.year(), StartDate.month()));
        //	EndDate = EndDate.addDays(-1);
       
	    //    FacebookCount = [select Count () FROM Case WHERE RecordType.Name = 'Social' AND Origin = 'Facebook' AND CreatedDate = LAST_MONTH ]; //AND CreatedDate < THIS_MONTH
    	//    TwitterCount = [select Count () FROM Case WHERE RecordType.Name = 'Social' AND Origin = 'Twitter' AND CreatedDate = LAST_MONTH ]; //AND CreatedDate < THIS_MONTH
        //	GoogleCount = [select Count () FROM Case WHERE RecordType.Name = 'Social' AND Origin = 'Google+' AND CreatedDate = LAST_MONTH ]; //AND CreatedDate < THIS_MONTH
        //	YelpCount = [select Count () FROM Case WHERE RecordType.Name = 'Social' AND Origin = 'Yelp' AND CreatedDate = LAST_MONTH ]; //AND CreatedDate < THIS_MONTH  
        //}
        
        
        
        if( String.isBlank( l_account_id ) )
        {
            // Bryan Anderson 8/28 - added try/catch to allow users without Contact to access community without Visualforce error
            try {
    	        ID ownerId = this.getCurrentUserContact().Id;
    	        for( Group_Owner__c go : [SELECT Group_Num__c FROM Group_Owner__c where Owner_Contact__c = :ownerId] ){
    	            groupIds.add( go.Group_Num__c );
    	        }

                //Andres DG-S 9/16
                //For contacts with RecordType == Club Staff, the account (Club) related 
                //directly with the contact, is the account that should be displayed
                if( this.getCurrentUserContact().RecordType.Name == CLUB_STAFF )
                {
                    l_account_id = this.getCurrentUserContact().Account.Id;
                }


    	    } catch(Exception e) {}
        }
        
        //PFCC-2613 9/2/15 ADG-S lastDraft value Calculated and color assigment
        for( AggregateResult ar : [select SUM( Club_EFT__c ) eftSum,
                                   		  SUM( Club_EFT_Tax__c) eftTaxSum,
                                          SUM( All_Active_Members__c ) sftMembers,
                                          SUM( Active_EFT_Members__c ) sftEFTMembers,
                                   		  SUM( BCM__c ) sftBCMMembers,
                                   		  SUM( EFT_BCM_Number__c ) sftEFTBCMMembers,
                                          SUM( BCM__c ) bmsSum,
                                          SUM( EFT_Difference_Without_Tax__c ) difference,
                                   	      SUM( EFT_Difference_With_Tax__c ) differenceTax,
                                          MAX( EFT_Run_Date__c  ) EFTDate
                                     From Account 
                                     where ( Group_Name__c in :groupIds OR ID =: l_account_id) and Status__c = 'Open' Group By RecordTypeId  ] ){

            myGroupHealth.eft.sumOfEFT += (Decimal) ( ar.get('eftSum') != null ? ar.get('eftSum') : 0);
            myGroupHealth.eft.sumOfEFTTax += (Decimal) ( ar.get('eftTaxSum') != null ? ar.get('eftTaxSum') : 0);
            myGroupHealth.eft.lastDraft += Integer.valueOf( ar.get('difference') != null ? ar.get('difference') : 0);
            myGroupHealth.eft.lastDraftTax += Integer.valueOf( ar.get('differenceTax') != null ? ar.get('differenceTax') : 0);
            myGroupHealth.members.totalMembers += Integer.valueOf( ar.get('sftMembers') != null ? ar.get('sftMembers') : 0);
            myGroupHealth.members.totalEFTMembers += Integer.valueOf( ar.get('sftEFTMembers') != null ? ar.get('sftEFTMembers') : 0);
            myGroupHealth.members.totalBCMMembers += Integer.valueOf( ar.get('sftBCMMembers') != null ? ar.get('sftBCMMembers') : 0);
            myGroupHealth.members.totalBCMEFTMembers += Integer.valueOf( ar.get('sftEFTBCMMembers') != null ? ar.get('sftEFTBCMMembers') : 0);
            myGroupHealth.members.bcm += Integer.valueOf( ar.get('bmsSum') != null ? ar.get('bmsSum') : 0);
            myGroupHealth.eft.validEFTDate = (String) ( ar.get('EFTDate') != null ? ((Date) ar.get('EFTDate')).format()  : null);
        }


        //lastDraftStatus is used to redner lastDraft with different color
        if( myGroupHealth.eft.lastDraft > 0 )
        {
            lastDraftStatus = 1; 
        }
        else if( myGroupHealth.eft.lastDraft < 0)
        {
            lastDraftStatus = -1;
        }
        else
        {
            lastDraftStatus = 0;
        }
        
        //lastDraftTaxStatus is used to redner lastDraftTax with different color
        if( myGroupHealth.eft.lastDraftTax > 0 )
        {
            lastDraftTaxStatus = 1; 
        }
        else if( myGroupHealth.eft.lastDraftTax < 0)
        {
            lastDraftTaxStatus = -1;
        }
        else
        {
            lastDraftTaxStatus = 0;
        }

        myGroupHealth.eft.lastDraft = math.abs(myGroupHealth.eft.lastDraft);
         myGroupHealth.eft.lastDraftTax = math.abs(myGroupHealth.eft.lastDraftTax);
        
        for( Account acc : [ Select ( Select Id 
                                      From Cases 
                                      Where Status = :'Transfer to Group'
                                      AND ClosedDate = LAST_N_DAYS:30 ) 
                             From Account where ( Group_Name__c in :groupIds or ID =: l_account_id)  ] )
        {
            myGroupHealth.totalCases += acc.Cases.size();
        }

        // get user profile
        showMe = true;
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id = :profileId].Name;
        system.debug('ProfileName'+profileName);
        IF (profileName == 'Customer Community Plus Login Broker') {
            showMe = false;
        }
    }
    
    public Class MyGroupHealthWrapper{
        public EFTWrapper eft {get; set;}
        public MembersWrapper members {get; set;}
        public Integer totalCases {get; set;}
    }
    
    public Class EFTWrapper{
        public Decimal sumOfEFT {get; set;}
        public Decimal sumOfEFTTax {get; set;}
        public String validEFTDate {get; set;}
        public Decimal lastDraft {get; set;}
        public Decimal lastDraftTax {get; set;}
    }
    
    public Class MembersWrapper{
        public Integer totalMembers {get; set;}
        public Integer totalEFTMembers {get; set;}
        public Integer totalBCMMembers {get; set;}
        public Integer totalBCMEFTMembers {get; set;}
        public Integer bcm {get; set;}
    }
    

}