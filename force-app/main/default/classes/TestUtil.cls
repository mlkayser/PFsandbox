/**
* Core utility class for unit tests.  Creates object records to be used in tests.
*
* @Author:   Usman Aslam (Magnet 360)  
* @Date:   04.26.2016
* @Updates:
**/

@isTest
public class TestUtil {

    public static testMethod void checkRecords() {
        TestUtil.insertCustomSettings();
        
        Group__c g = new Group__c(
            Name = 'Test Group',
            Group__c = 'G0001');
        insert g;
        
        Account account = new Account( 
            Name='Club', 
            RecordTypeID = PFTestUtility.club_location_account_rt.id , 
            PF_Club_ID__c = '8888',
            Group_Name__c = g.id);
        insert account;        
        
        Project__c project = TestUtil.getProjects(2, account, true )[0];
        //Project_Information__c projectInfo = TestUtil.getProjectInfo(2, project, true)[0] ; 
        //Id rtId = [ SELECT Id FROM RecordType WHERE SObjectType = 'Apttus__APTS_Agreement__c' AND DeveloperName ='ADA_FA_Amendment' LIMIT 1 ].Id;
        // Apttus__APTS_Agreement__c agreement = TestUtil.getAgreements(1, true)[0] ;
        PFAgreement__c pfagreement = TestUtil.getAgreements(1, true)[0] ;
        TestUtil.getSchedules(1, pfagreement, account, true);
    }
    
    // Method to insert custom settings
    public static void insertCustomSettings() {
        Global_Royalty_Rates__c globalSettings = new Global_Royalty_Rates__c(  
            Current_Royalty_Rate__c = '5A', 
            Future_Royalty_Rate__c = '7',             
            Future_Royalty_Rate_Date__c = Date.today().addYears(1) 
        );
        insert globalSettings;
        System.debug('UA: globalSettings ' + globalSettings );
    }
    
    // Method to create account records 
    public static List<Account> getAccounts(Integer numOfRecords, Boolean doInsert ) {

        List<Account> accounts = new List<Account>();
        Group__c g = new Group__c(
            Name = 'Test Group',
            Group__c = 'G0001'
        );
        insert g;

        for (Integer i = 0; i < numOfRecords; i++) {
            String randNo = String.valueOf(Crypto.getRandomInteger());
            Account acct = new Account(  
                Name = 'Test' + randNo, 
                Group_Name__c = g.id 
            );
            accounts.add(acct);
        }
        
        if (doInsert) insert accounts;
        System.debug('UA: accounts ' + accounts );
        
        return accounts ; 
    }
    
    // Method to create Project records 
    public static List<Project__c> getProjects(Integer numOfRecords, Account account, Boolean doInsert ) {
 
        List<Project__c> projects = new List<Project__c>();        
        for (Integer i = 0; i < numOfRecords; i++) {
            String randNo = String.valueOf(Crypto.getRandomInteger());
            Project__c project = new Project__c( 
                Name = 'Test' + randNo, 
                Club_Location__c = account.Id,                
                Open_Date__c = Date.today(), 
                Open_Date_Status__c = 'Actual', 
                PI_FA_Status__c ='FA Signed',
                PI_Real_Estate_Status__c ='Lease Signed', 
                PI_Executed_Lease_Date__c = Date.today() 
            );
            projects.add(project);
        }
        
        if (doInsert) insert projects;
        System.debug('UA: projects ' + projects );
        
        return projects ;
    }
    
    public static List<PFAgreement__c> getAgreements(Integer numOfRecords, Boolean doInsert ) {

        List<PFAgreement__c> agreements = new List<PFAgreement__c>();        
        for (Integer i = 0; i < numOfRecords; i++) {
            String randNo = String.valueOf(Crypto.getRandomInteger());
            PFAgreement__c agreement = new PFAgreement__c( Name = 'Test' + randNo);
            agreements.add(agreement);
        }
        
        if (doInsert) insert agreements;
        System.debug('UA: agreements ' + agreements );
        
        return agreements ;
    }

    // method to create Area Development Agreements
    public static List<PFAgreement__c> getADAagreements(Integer numOfRecords, Boolean doInsert ) {
        Id ADA_rti = Schema.SObjectType.PFAgreement__c.getRecordTypeInfosByName().get('Area Development Agreement').getRecordTypeId();

        List<PFAgreement__c> agreements = new List<PFAgreement__c>();        
        for (Integer i = 0; i < numOfRecords; i++) {
            String randNo = String.valueOf(Crypto.getRandomInteger());
            PFAgreement__c agreement = new PFAgreement__c( 
                Name = 'TestADA' + randNo,
                ADA_Status__c = 'Active',
                RecordTypeId = ADA_rti
            );
            agreements.add(agreement);
        }
        
        if (doInsert) insert agreements;
        System.debug('UA: agreements ' + agreements );
        
        return agreements ;
    }      
    // Method to create ADA_Schedule records 
    public static List<ADA_Schedule__c> getSchedules(Integer numOfRecords, PFAgreement__c agreement, Account account, Boolean doInsert ) {

        List<ADA_Schedule__c> schedules = new List<ADA_Schedule__c>();        
        for (Integer i = 0; i < numOfRecords; i++) {
            String randNo = String.valueOf(Crypto.getRandomInteger());
            ADA_Schedule__c schedule = new ADA_Schedule__c( 
                Dev_Obligation_No__c = randNo.left(5), 
                Area_Development_Agreement__c = agreement.Id, 
                Development_Obligation_Date__c = Date.today(), 
                Club__c = account.Id,
                Action__c ='Lease Signed By', 
                FA_Signed__c = false, 
                Projected_Actual_Open_Date__c = Date.today()  
            );
            schedules.add(schedule);
        }
        
        if (doInsert) insert schedules;
        System.debug('UA: schedules ' + schedules );        
        
        return schedules ;
    }
    
    public static List<Grace_Period__c> getGracePeriods(Integer numOfRecords, PFAgreement__c agreement, Boolean doInsert) {

        List<Grace_Period__c> gracePeriods = new List<Grace_Period__c>();
        for (Integer i = 0; i < numOfRecords; i++) {
            Grace_Period__c gracePeriod = new Grace_Period__c(
                Area_Development_Agreement__c = agreement.Id, 
                Free_Start_Date__c = Date.today().addMonths(-12),
                Free_End_Date__c = Date.today().addMonths(-6).addDays(-1),
                Paid_Start_Date__c = Date.today().addMonths(-6), 
                Paid_End_Date__c = Date.today().addDays(-1)
            );
            gracePeriods.add(gracePeriod);
        }
        
        if (doInsert) insert gracePeriods;        
        
        return gracePeriods ;  
    }
    
    public static List<Grace_Period__c> getGracePeriodsWithPFA(Integer numOfRecords, PFAgreement__c agreement, Boolean doInsert) {

        List<Grace_Period__c> gracePeriods = new List<Grace_Period__c>();        
        for (Integer i = 0; i < numOfRecords; i++) {
            Grace_Period__c gracePeriod = new Grace_Period__c(
                Area_Development_Agreement__c = agreement.Id, 
                Free_Start_Date__c = Date.today().addMonths(-12),
                Free_End_Date__c = Date.today().addMonths(-6).addDays(-1),
                Paid_Start_Date__c = Date.today().addMonths(-6), 
                Paid_End_Date__c = Date.today().addDays(-1)
            );
            gracePeriods.add(gracePeriod);
        }
        
        if (doInsert) insert gracePeriods;
        
        return gracePeriods ;  
    }
    
}