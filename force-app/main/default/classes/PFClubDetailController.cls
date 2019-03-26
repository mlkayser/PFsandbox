/**
* Class that retrives the Banners from the Content Library 
* 
* @Updated: 8/31/2015 Andres Di Geronimo-Stenberg (Magnet360)
* @Jira: PFCC-2680 - Update Club Contacts section in Club detail page
*/
public without sharing class PFClubDetailController {

    Public String TerritoryId {get; set;}    
    public List< User > corporateContacts;
    public Account clubInfo{get;set;}
    public Account clubInfo2{get;set;}
    public String ABCid{get;set;}
    public Decimal sqfoot{get;set;}
    public datetime opendate{get;set;}
    public date projectedopendate{get;set;}
    public date physicalpresaledate{get;set;}
    public String groupname{get;set;}
    public String groupfullname{get;set;}
    public String clubemail{get;set;}    
    public Map< ID , String > user_role { get; set; }
    private static String OPEN = 'Open';
    public ID photo_id { get; set; }
    public string project_id { get; set; }
    public string project_name { get; set; }
    
    public String UserId {get; set;}
    
    public integer REStatNum { get; set; }
    public string REProgress { get; set; }
    public integer FAStatNum { get; set; }
    public string FAProgress { get; set; }
    public integer PermitStatNum { get; set; }
    public string PermitProgress { get; set; }
    public integer DesignStatNum { get; set; }
    public string DesignProgress { get; set; }
    public integer ConStatNum { get; set; }
    public string ConProgress { get; set; }
    public integer EquipStatNum { get; set; }
    public string EquipProgress { get; set; }
    public integer ITStatNum { get; set; }
    public string ITProgress { get; set; }
    public integer PreStatNum { get; set; }
    public string PreProgress { get; set; }
    public integer SaleStatNum { get; set; }
    public string SaleProgress { get; set; }
    public string teststring { get; set; }
    
    /*
    public List<Project__c> allSteps {
        get {
            if (allSteps == null) {
                allSteps = [ select Id, x1_FA_Deposit_Status__c, x2_Site_Selection_Status__c, x3_LOI_Negotiations_Status__c, x4_Lease_Review_Status__c, 
                            x5_Lease_Signed_Status__c, x6_Space_Planning_Status__c, x7_Owners_Orientation_Status__c, x8_Design_Status__c, 
                            x9_Permitting_Status__c, x10_Vendor_Permitting_Status__c, x11_Construction_Status__c, x12_Ops_Presale_Training_Status__c,
                            x13_Marketing_Status__c, x14_Presales_Status__c 
                             from Project__c 
                             where Club_Location__c = :clubInfo.id AND Scope_Type__c = 'New - Franchisee'
                             ORDER BY CreatedDate desc LIMIT 1];
            }
            return allSteps;
        }   
        set;
    }
    */

    /*
    public list<String> statusFields {
        get {
            if (statusFields == null) {
                String fieldsStr = 'x1_FA_Deposit_Status__c, x2_Site_Selection_Status__c, x3_LOI_Negotiations_Status__c, x4_Lease_Review_Status__c,'+
                                   'x5_Lease_Signed_Status__c, x6_Space_Planning_Status__c,x7_Owners_Orientation_Status__c, x8_Design_Status__c,'+
                                   'x9_Permitting_Status__c, x10_Vendor_Permitting_Status__c,x11_Construction_Status__c,'+
                                   'x12_Ops_Presale_Training_Status__c, x13_Marketing_Status__c, x14_Presales_Status__c';
                statusFields = fieldsStr.split( ',' );
            }
            return statusFields;
        } 
        set;
    }
    */
    
/******************************************************************************
 * PFClubDetailController
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 08/31/2015
 * @jira: PFCC-2680
 * @description: Constructor
 * @param: ApexPages.StandardController sc
 * @return: None.
 ******************************************************************************/
    public PFClubDetailController( ApexPages.StandardController sc ) {

        //sc.addFields( new List<String>{'Status__c'});
        clubInfo = [select Status__c from Account where Id = :sc.getId() ];//(Account)sc.getRecord();
        clubInfo2 = [select Operations_Region__c from Account where Id = :sc.getId() ];//(Account)sc.getRecord();
        ABCid = [select POS_Club_Id__c from Account where Id = :sc.getId() ].POS_Club_Id__c;//(Account)sc.getRecord();
        sqfoot = [select Square_Footage__c from Account where Id = :sc.getId() ].Square_Footage__c;//(Account)sc.getRecord();
        opendate = [select Date_Opened__c from Account where Id = :sc.getId() ].Date_Opened__c;//(Account)sc.getRecord();        
        groupname = [select Group_Name__r.Group__c from Account where Id = :sc.getId() ].Group_Name__r.Group__c;//(Account)sc.getRecord();
        groupfullname = [select Group_Name__r.Name from Account where Id = :sc.getId() ].Group_Name__r.Name;//(Account)sc.getRecord();
        clubemail = [select Club_Assigned_Email__c from Account where Id = :sc.getId() ].Club_Assigned_Email__c;//(Account)sc.getRecord();
        getProject();
        getClubImage();
        
        UserId = Userinfo.getUserId();
    }    
    
    //Get all the Status' for Real Estate Milestone
     public List<String> getREStatus() {
         String REStat = [select Real_Estate_Status__c from Project__c where Id = :project_id].Real_Estate_Status__c;
         Integer REStatNumTemp = 0;
         REStatNum = 1;
         List<String> options = new List<String>();
         Schema.DescribeFieldResult fieldResult = Project__c.Real_Estate_Status__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for (Schema.PicklistEntry f : ple) {
             if (f.getLabel().indexOf('Denied') == -1 && f.getLabel().indexOf('Dead') == -1 && f.getLabel().indexOf('On Hold') == -1  && f.getLabel().indexOf('Not Applicable') == -1 && f.getLabel().indexOf('Not Started') == -1) {
                REStatNumTemp = REStatNumTemp + 1;
                 options.add(f.getLabel());
                 if (f.getlabel() == REStat){
                     REStatNum = REStatNumTemp;
                 }
             }   
              decimal i=REStatNumTemp;
              decimal k=REStatNum;
             if (i==0){
                 REProgress = '0';
             } else {
              double d = (k/i)*100;
              REProgress = string.valueof(d);
            }
             if (REStat == 'Lease Signed' || REStat == 'Building Purchased') {
                //REStatNum = REStatNum + 1;
                 REProgress = '100';
             } 
         }
         return options;
     }
    
    //Get all the Status' for Franchise Agreement Milestone
     public List<String> getFAStatus() {

         String FAStat = [select Franchise_Agreement_Status__c from Project__c where Id = :project_id].Franchise_Agreement_Status__c;
         Integer FAStatNumTemp = 0;
         FAStatNum = 0;
         List<String> options = new List<String>();
         Schema.DescribeFieldResult fieldResult = Project__c.Franchise_Agreement_Status__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for(Schema.PicklistEntry f : ple) {
             if (f.getLabel().indexOf('Not Started') == -1 && f.getLabel().indexOf('Rejected') == -1) {
                FAStatNumTemp = FAStatNumTemp + 1;
                 options.add(f.getLabel());
                 if (f.getlabel() == FAStat){
                     FAStatNum = FAStatNumTemp;
                 }
             }
              decimal i=FAStatNumTemp;
              decimal k=FAStatNum;
             if (i==0){
                 FAProgress = '0';
             } else {
              double d = (k/i)*100;
              FAProgress = string.valueof(d);
            }
         }
         return options;
     }
    
    //Get all the Status' for Design Milestone
     public List<String> getDesignStatus() {
         String DesignStat = [select Design_Status_new__c from Project__c where Id = :project_id].Design_Status_new__c;
         Integer DesignStatNumTemp = 0;
         DesignStatNum = 0;
         List<String> options = new List<String>();
         Schema.DescribeFieldResult fieldResult = Project__c.Design_Status_new__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for(Schema.PicklistEntry f : ple) {
             if (f.getLabel().indexOf('Not Started') == -1) {
                DesignStatNumTemp = DesignStatNumTemp + 1;
                 options.add(f.getLabel());
                 if (f.getlabel() == DesignStat){
                     DesignStatNum = DesignStatNumTemp;
                 }
             }       
             decimal i=DesignStatNumTemp;
              decimal k=DesignStatNum;
             if (i==0){
                 DesignProgress = '0';
             } else {
              double d = (k/i)*100;
              DesignProgress = string.valueof(d);
            }
         }
         return options;
     }
        
    //Get all the Status' for Permitting Milestone
     public List<String> getPermitStatus() {
         String PermitStat = [select Permitting_Status_New__c from Project__c where Id = :project_id].Permitting_Status_New__c;
         Integer PermitStatNumTemp = 0;
         PermitStatNum = 0;
         List<String> options = new List<String>();
         Schema.DescribeFieldResult fieldResult = Project__c.Permitting_Status_New__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for(Schema.PicklistEntry f : ple) {
             if (f.getLabel().indexOf('Not Started') == -1) {
                PermitStatNumTemp = PermitStatNumTemp + 1;
                 options.add(f.getLabel());
                 if (f.getlabel() == PermitStat){
                     PermitStatNum = PermitStatNumTemp;
                 }
             }
             decimal i=PermitStatNumTemp;
              decimal k=PermitStatNum;
             if (i==0){
                 PermitProgress = '0';
             } else {
              double d = (k/i)*100;
              PermitProgress = string.valueof(d);
            }
         }
         return options;
     }
    
    //Get all the Status' for Construction Milestone
     public List<String> getConStatus() {
         String ConStat = [select Construction_Status__c from Project__c where Id = :project_id].Construction_Status__c;
         Integer ConStatNumTemp = 0;
         ConStatNum = 0;
         List<String> options = new List<String>();
         Schema.DescribeFieldResult fieldResult = Project__c.Construction_Status__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for(Schema.PicklistEntry f : ple) {
             if (f.getLabel().indexOf('Not Started') == -1) {
                ConStatNumTemp = ConStatNumTemp + 1;
                 options.add(f.getLabel());
                 if (f.getlabel() == ConStat){
                     ConStatNum = ConStatNumTemp;
                 }
             }   
             decimal i=ConStatNumTemp;
              decimal k=ConStatNum;
             if (i==0){
                 ConProgress = '0';
             } else {
              double d = (k/i)*100;
              ConProgress = string.valueof(d);
            }
         }
         return options;
     }
      
    //Get all the Status' for Equipment Milestone
     public List<String> getEquipStatus() {
         String EquipStat = [select Equipment_Status__c from Project__c where Id = :project_id].Equipment_Status__c;
         Integer EquipStatNumTemp = 0;
         EquipStatNum = 0;
         List<String> options = new List<String>();
         Schema.DescribeFieldResult fieldResult = Project__c.Equipment_Status__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for(Schema.PicklistEntry f : ple) {
             if (f.getLabel().indexOf('Not Started') == -1) {
                EquipStatNumTemp = EquipStatNumTemp + 1;
                 options.add(f.getLabel());
                 if (f.getlabel() == EquipStat){
                     EquipStatNum = EquipStatNumTemp;
                 }
             }       
             decimal i=EquipStatNumTemp;
              decimal k=EquipStatNum;
             if (i==0){
                 EquipProgress = '0';
             } else {
              double d = (k/i)*100;
              EquipProgress = string.valueof(d);
            }
         }
         return options;
     }
        
     //Get all the Status' for IT Milestone
     public List<String> getITStatus() {
         String ITStat = [select IT_Status__c from Project__c where Id = :project_id].IT_Status__c;
         Integer ITStatNumTemp = 0;
         ITStatNum = 0;
         List<String> options = new List<String>();
         Schema.DescribeFieldResult fieldResult = Project__c.IT_Status__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for(Schema.PicklistEntry f : ple) {
             if (f.getLabel().indexOf('Not Started') == -1) {
                ITStatNumTemp = ITStatNumTemp + 1;
                 options.add(f.getLabel());
                 if (f.getlabel() == ITStat){
                     ITStatNum = ITStatNumTemp;
                 }
             }       
             decimal i = ITStatNumTemp;
              decimal k = ITStatNum;
             if (i==0){
                 ITProgress = '0';
             } else {
              double d = (k/i)*100;
              ITProgress = string.valueof(d);
            }
         }
         return options;
     }

    //Get all the Status' for Pre-Opening Milestone
     public List<String> getPreStatus() {
         String PreStat = [select Presale_Operations_Status__c from Project__c where Id = :project_id].Presale_Operations_Status__c;
         Integer PreStatNumTemp = 0;
         PreStatNum = 0;
         List<String> options = new List<String>();
         Schema.DescribeFieldResult fieldResult = Project__c.Presale_Operations_Status__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for(Schema.PicklistEntry f : ple) {
             if (f.getLabel().indexOf('Not Started') == -1) {
                PreStatNumTemp = PreStatNumTemp + 1;
                 options.add(f.getLabel());
                 if (f.getlabel() == PreStat){
                     PreStatNum = PreStatNumTemp;
                 }
             }  
             decimal i=PreStatNumTemp;
              decimal k=PreStatNum;
             if (i==0){
                 PreProgress = '0';
             } else {
              double d = (k/i)*100;
              PreProgress = string.valueof(d);
            }
         }
         return options;
     }
    
    //Get all the Status' for PreSale Milestone
     public List<String> getSaleStatus() {
         String SaleStat = [select Pre_Sale_Status__c from Project__c where Id = :project_id].Pre_Sale_Status__c;
         Integer SaleStatNumTemp = 0;
         SaleStatNum = 0;
         List<String> options = new List<String>();
         Schema.DescribeFieldResult fieldResult = Project__c.Pre_Sale_Status__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for(Schema.PicklistEntry f : ple) {
             if (f.getLabel().indexOf('Not Started') == -1) {
                SaleStatNumTemp = SaleStatNumTemp + 1;
                 options.add(f.getLabel());
                 if (f.getlabel() == SaleStat){
                     SaleStatNum = SaleStatNumTemp;
                 }
             }     
             decimal i=SaleStatNumTemp;
              decimal k=SaleStatNum;
             if (i==0){
                 SaleProgress = '0';
             } else {
              double d = (k/i)*100;
              SaleProgress = string.valueof(d);
            }
         }
         return options;
     }
    

/******************************************************************************
 * getProject
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 09/04/2015
 * @jira: PFCC-2805
 * @description: Obtains the ProjectID and ProjectName related with Club, in
                 order to pass it as parameter if the Submite Site button is 
                 clicked.
 * @param: None.
 * @return: None.
 ******************************************************************************/
    private void getProject() {
        try{
            System.Debug('Club Location: ' + clubInfo.id);
            try{
                Project__c l_project = [ Select Id, Name
                                         From Project__c
                                         Where Build_Phase__c != 'Open' AND Club_Location__c = :clubInfo.id AND RecordType.Name != 'Historical'
                                         limit 1];
                                        //Removed Where Scope_Type__c = :'New - Franchisee'
                project_name = l_project.Name;
                project_id = l_project.Id;
                System.debug(':::project_id111::::' + project_id);
                //project_id = ([SELECT Id FROM Project__c WHERE Club_Location__c = :clubInfo.id AND RecordType.Name != 'Historical' limit 1].id);
                //projectedopendate = [select Franchisee_Projected_Open_Date__c, from Project__c where Id = :project_id limit 1].Franchisee_Projected_Open_Date__c;
            } catch (Exception e){
                System.Debug('Exception Occurred'); 
            }
        
            List<Project__c> projList = [SELECT Id,Franchisee_Projected_Open_Date__c,Open_Date__c FROM Project__c WHERE Club_Location__c = :clubInfo.id AND RecordType.Name != 'Historical' AND Scope_Type__c = 'Relo' ORDER BY Open_Date__c DESC limit 1];
            if(projList.size() > 0) {
                project_id = projList[0].Id;
                projectedopendate = projList[0].Open_Date__c;
            }
            
            System.debug(':::project_id222::::' + project_id);
            
        }catch ( exception e ){
            System.debug(':::Exception Occured::::');
        }                 
    }
        
/******************************************************************************
 * getClubImage
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 09/03/2015
 * @jira: PFCC-2685
 * @description: Obtains the image related with the club from the attachemnts 
                 of the club. The name of the image is storage in the community
                 custon setting
 * @param: None
 * @return: None
 ******************************************************************************/
    private void getClubImage() {
        String image_name = Community_Settings__c.getInstance().Club_Image_Name__c;
        try {
            Club_Image__c l_club_image = [ Select Id From Club_Image__c Where Account__c = :clubInfo.Id Order by createdDate DESC Limit 1 ];
            system.debug( '*** Club image ' + l_club_image );
            photo_id = [ Select Id From Attachment Where ParentId = :l_club_image.Id And Name = : image_name limit 1 ].id;
        }
        catch(exception e){}
    }
}