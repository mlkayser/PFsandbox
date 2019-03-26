/******************************************************************************
* 
*   Nightly job reviewing all unmet schedules if passed the development obligation date either 
*   generate grace period record and set all grace period fields if grace period is allowed OR 
*   set schedule "Default Date" and "Schedule Status" to "Default"

*   Confirm on create of Grace Period record to ensure only N Grace Periods are applied to ADA (trigger/dev); 
*   based on value of entry within "Number of Grace Periods Allowed" on ADA record
*   If maximum number of Grace Periods has been reached, set Schedule Status to Default and do not generate Grace Period
*
* 
*   @Author: Usman Aslam (Magnet 360)
* 
*/
global class ScheduleGracePeriodJob implements Database.Batchable<sObject>, Schedulable  {
    
    /**
    * 
    * Description : Method execute to run the batch process.
    * 
    *  */
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new ScheduleGracePeriodJob(), 200); 
    }
    
    /**
    * Description : Method executes on the start of the batch process that query Schedule records
    * that will be processed
    *  
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Development_Obligation_Date__c, Area_Development_Agreement__c, Area_Development_Agreement__r.Id, ' + 
                'Area_Development_Agreement__r.Number_of_Allowed_Grace_Periods__c, '+
                'Grace_Period__r.Id, Grace_Period__r.Cure_Date__c, ' +
                'Development_Obligation_Status__c ' + 
                'from ADA_Schedule__c where '  + 
            'Development_Obligation_Date__c != null and Development_Obligation_Date__c < TODAY and Development_Obligation_Status__c = \'Unmet\' ' + 
            (Test.isRunningTest() ? ' limit 200 ' : '');
        
        return Database.getQueryLocator(query);
    }

    // get agreements with schedules and grace periods
    private List<PFAgreement__c> getAgreements(Set<Id> agreementIds) {
        return [select Id, Number_of_Allowed_Grace_Periods__c,
                    (SELECT Id, Area_Development_Agreement__c, Development_Obligation_Date__c, Development_Obligation_Status__c,
                        Default_Start_Date__c, Grace_Period__r.Cure_Date__c
                        FROM Development_Obligations__r 
                         where Development_Obligation_Date__c != null),
                    (SELECT Id, Cure_Date__c, Free_Start_Date__c, Area_Development_Agreement__c
                        FROM Grace_Period__r where Cure_Date__c = null)
                    from PFAgreement__c where Id in :agreementIds];
    }
    
    /**
    * Description : Method executes to update Grace Period record's Cure Date.
    * 
    *  */
    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<ADA_Schedule__c> schedules = (List<ADA_Schedule__c>) scope;
        
        // get agreements id from schedules
        Set<Id> agreementIds = new Set<Id>();
        for(ADA_Schedule__c s : schedules) {
            agreementIds.add(s.Area_Development_Agreement__c);
        }

        // get agreements with schedules and grace periods
        List<PFAgreement__c> agreements = getAgreements(agreementIds);

        // list for new grace periods
        List<Grace_Period__c> gpsToCreate = new List<Grace_Period__c>();

        // create grace periods based on number of allowed grace periods for agreement
        // this is done to simplify the logic. Un-used grace periods will get deleted at the end.
        for(PFAgreement__c a : agreements) {
            if(a.Number_of_Allowed_Grace_Periods__c == null || a.Number_of_Allowed_Grace_Periods__c == 0) continue;

            Integer existingGps = (a.Grace_Period__r == null || a.Grace_Period__r.isEmpty()) ? 0 : a.Grace_Period__r.size();

            for(Integer i = 0; i < a.Number_of_Allowed_Grace_Periods__c - existingGps; i++) {
                gpsToCreate.add(new Grace_Period__c(Area_Development_Agreement__c = a.Id));
            }
        }

        // insert blank grace periods
        insert gpsToCreate;

        // get agreements with schedules and grace periods
        agreements = getAgreements(agreementIds);

        // map to hold schedules related to one agreement and has the same obligation date
        Map<String, List<ADA_Schedule__c>> agreementDateSchedules = new Map<String, List<ADA_Schedule__c>>();
        for(PFAgreement__c a : agreements) {
            for(ADA_Schedule__c s : a.Development_Obligations__r) {
                List<ADA_Schedule__c> dateSchedules = agreementDateSchedules.get(String.valueOf(a.Id) +
                                                    String.valueOf(s.Development_Obligation_Date__c));

                if(dateSchedules == null) {
                    dateSchedules = new List<ADA_Schedule__c>();
                    agreementDateSchedules.put(String.valueOf(a.Id) +
                                                    String.valueOf(s.Development_Obligation_Date__c), dateSchedules);

                }

                dateSchedules.add(s);
            }
        }

        // Map to hold schedules related to one agreement and grace period
        Map<Id, Map<Id, List<ADA_Schedule__c>>> agrToGpToSchedulesMap = new Map<Id, Map<Id, List<ADA_Schedule__c>>>();
        
        // populate the map above
        for(PFAgreement__c a : agreements) {

            if(a.Development_Obligations__r == null || a.Grace_Period__r == null 
                || a.Development_Obligations__r.isEmpty() || a.Grace_Period__r.isEmpty() )  continue;

            Map<Id, List<ADA_Schedule__c>> gpToSchedulesMap = agrToGpToSchedulesMap.get(a.Id);

            if(gpToSchedulesMap == null) {
                gpToSchedulesMap = new Map<Id, List<ADA_Schedule__c>>();
                agrToGpToSchedulesMap.put(a.Id, gpToSchedulesMap);
            }

            for(Grace_Period__c gp : a.Grace_Period__r) {
                List<ADA_Schedule__c> gpSchedules = new List<ADA_Schedule__c>();
                gpToSchedulesMap.put(gp.Id, gpSchedules);
            }

            for(Grace_Period__c gp : a.Grace_Period__r) {
                for(ADA_Schedule__c s : a.Development_Obligations__r) {
                    if(s.Grace_Period__c == gp.Id) {
                        List<ADA_Schedule__c> gpSchedules = gpToSchedulesMap.get(gp.Id);
                        gpSchedules.add(s);
                    }
                }
            }   
        }

        // holds the schedules that needs to be updated
        Map<Id, ADA_Schedule__c> schedulesToUpdate = new Map<Id, ADA_Schedule__c>();

        // holds grace periods related to be updated
        List<Grace_Period__c> gpsToUpdate = new List<Grace_Period__c>();
        
        
        for(PFAgreement__c a : agreements) {
			Boolean hasOpenGracePeriod = false;
            // if new schedules, move to next agreement
            if(a.Development_Obligations__r == null || a.Development_Obligations__r.isEmpty() ) continue;

            // get schedules realted to grace period based on agreement id
            Map<Id, List<ADA_Schedule__c>> gpToSchedulesMap = agrToGpToSchedulesMap.get(a.Id);

            // find any open grace period
            for(Grace_Period__c gp : a.Grace_Period__r) {
                if(gp.Free_Start_Date__c != null && gp.Cure_Date__c == null) {
                    hasOpenGracePeriod = true;
                    break;
                }
            }

            // iterate over all grace periods related to agreement
            for(Grace_Period__c gp : a.Grace_Period__r) {

                // iterate over all grace periods related to agreement
                for(ADA_Schedule__c s : a.Development_Obligations__r) {
					
                    if(s.Development_Obligation_Date__c >= Date.today()) continue;
                    
                    // get schedules relate to agreement and have the same obl. date
                    List<ADA_Schedule__c> dateSchedules = agreementDateSchedules.get(String.valueOf(a.Id) +
                                                    String.valueOf(s.Development_Obligation_Date__c));


                    Boolean isDefaulted = false;

                    // if there are more than two schedules under an agreement the same date, make them default
                    if(dateSchedules != null && dateSchedules.size() > 2) {
                        for(ADA_Schedule__c ds : dateSchedules) {

                            if(ds.Id == s.Id) {
                                isDefaulted = true;
                                s.Development_Obligation_Status__c = 'Default';
                                s.Default_Start_Date__c   = s.Development_Obligation_Date__c;
                                schedulesToUpdate.put(s.Id, s);
                                System.debug('add 1');
                            }
                        }
                    } 

                    // schedule is defaulted? yes, move to next schedule
                    if(isDefaulted) continue;

                    // if Grace periods are not allowed, default sechedule
                    if(a.Number_of_Allowed_Grace_Periods__c == null || a.Number_of_Allowed_Grace_Periods__c == 0) {
                        s.Development_Obligation_Status__c = 'Default';
                        s.Default_Start_Date__c   = s.Development_Obligation_Date__c;
                        schedulesToUpdate.put(s.Id, s);
                        System.debug('add 2');
                        continue;
                    // if schedule has a grace period and its cure date is null, defualt schedule
                    } /*else if(s.Grace_Period__r != null && s.Grace_Period__r.Cure_Date__c == null) {
                        s.Development_Obligation_Status__c = 'Default';
                        schedulesToUpdate.put(s.Id, s);
                        System.debug('add 3');
                        continue;
                    // if scheudle is not associated with any grace period, assign a grace period
                    } */ else if(s.Grace_Period__c == null) {
                        
                        
                        // get schedules assoicated with the grace period
                        List<ADA_Schedule__c> gpSchedules = gpToSchedulesMap.get(gp.Id);
                        
                        // if schedules assoicated with grace period are less than 2, assoicate this grace period with schedule
                        if(gpSchedules != null && gpSchedules.size() < 2 ) {
                            // if schedule obl. date and grace period free start date is the same use
                            if(s.Development_Obligation_Date__c == gp.Free_Start_Date__c) {
                                // assign grace perion to schedule
                                s.Grace_Period__c = gp.Id;
                                schedulesToUpdate.put(s.Id, s);
                                s.Development_Obligation_Status__c = 'Default';
                                System.debug('add 3');
                                gpSchedules.add(s);  
                                continue;
                            }

                            if(hasOpenGracePeriod) {
                                s.Default_Start_Date__c   = s.Development_Obligation_Date__c;
                                s.Development_Obligation_Status__c = 'Default';
                                schedulesToUpdate.put(s.Id, s);
                                System.debug('add 4');
                                continue;
                            }

                            // if this grace perion is blank, initialize all of date fields
                            if(gp.Free_Start_Date__c == null) {
                                gp.Free_Start_Date__c = s.Development_Obligation_Date__c;
                                gp.Free_End_Date__c = s.Development_Obligation_Date__c.addMonths(6).addDays(-1);
                                gp.Paid_Start_Date__c = s.Development_Obligation_Date__c.addMonths(6); 
                                gp.Paid_End_Date__c = s.Development_Obligation_Date__c.addMonths(12).addDays(-1);
                                
                                hasOpenGracePeriod = true;
                                gpsToUpdate.add(gp);
                                s.Grace_Period__c = gp.Id;
                                s.Development_Obligation_Status__c = 'Default';

                                schedulesToUpdate.put(s.Id, s);
                                System.debug('add 5');
                                gpSchedules.add(s);  
                            }


                            
                        }
                    }                   
                }
            }
            
            // after process of all schedules above, if there is one that doesn't have any grace period, make is default
            for(ADA_Schedule__c s : a.Development_Obligations__r) {
                if(s.Development_Obligation_Date__c >= Date.today()) continue;
                if(s.Grace_Period__c == null) {
                   	s.Development_Obligation_Status__c = 'Default';
                    s.Default_Start_Date__c   = s.Development_Obligation_Date__c;
                    schedulesToUpdate.put(s.Id, s);
                    System.debug('add 6'); 
                }
            	
            }
        }

        // update grace periods
        if(gpsToUpdate.size() > 0) {
            update gpsToUpdate;
        }

        // delete blank grace periods if there is not schedule assoicated with it.
        List<Grace_Period__c> gpsToDelete = new List<Grace_Period__c>();
        for(PFAgreement__c a : agreements) {
            Map<Id, List<ADA_Schedule__c>> gpToSchedulesMap = agrToGpToSchedulesMap.get(a.Id);

            if(gpToSchedulesMap == null) continue;

            for(Grace_Period__c gp : a.Grace_Period__r) {
                List<ADA_Schedule__c> gpSchedules = gpToSchedulesMap.get(gp.Id);

                if(gpSchedules.isEmpty()) gpsToDelete.add(new Grace_Period__c(Id = gp.Id));
            }
        }

        if(gpsToDelete.size() > 0) delete gpsToDelete;

        // get agreement back
        agreements = getAgreements(agreementIds);
        System.debug('schedulesToUpdate ' + schedulesToUpdate);

        Set<Id> schedulesProcessed = schedulesToUpdate.keySet();
        // default schedules when agreement ran out of grace perionds
        for(PFAgreement__c a : agreements) {
            for(ADA_Schedule__c s : a.Development_Obligations__r) {
                if(s.Development_Obligation_Date__c >= Date.today()) continue;
                if(a.Number_of_Allowed_Grace_Periods__c == a.Grace_Period__r.size() && !schedulesProcessed.contains(s.Id)) {
                    s.Development_Obligation_Status__c = 'Default';
                    s.Default_Start_Date__c   = s.Development_Obligation_Date__c;
                    schedulesToUpdate.put(s.Id, s);
                }
            }
        }


        // if no schedules to update, exit
        if(schedulesToUpdate.isEmpty())  return;

        // update schedules
        update schedulesToUpdate.values();
    }

    /**
    * 
    * Description : Method execute at the end of the batch process.
    * 
    *  */
    global void finish(Database.BatchableContext BC) { }
}