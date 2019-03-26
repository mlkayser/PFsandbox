/******************************************************************************
* A batch/ scheduled process that excecutes to updates the Default Date  of the
* ADA_Schedule__c records for the Grace Periods whose Paid End Date has passed and Cure Date in not Set
* 
*@Author: Usman Aslam (Magnet 360)
* 
*/
global class GracePeriodJob implements Database.Batchable<sObject>, Schedulable  {
    
    /**
    * 
    * Description : Method execute to run the batch process.
    * 
    *  */
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new GracePeriodJob(), 200); 
    }
    
    /**
    * Description : Method executes on the start of the batch process that query Grace Period records
    * that will be processed
    *  */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id, Paid_End_Date__c, '+
            ' (select Id, Default_Start_Date__c, ' +
                'Development_Obligation_Status__c from ADA_Schedule__r ' + 
                'where Development_Obligation_Status__c = \'Unmet\' ) ' + 
            'from Grace_Period__c where '  + 
            ' Cure_Date__c = null ' + 
            (Test.isRunningTest() ? ' limit 200 ' : '');
        
        return Database.getQueryLocator(query);
    }
    
    /**
    * Description : Method executes to update Grace Period record's Cure Date.
    * 
    *  */
    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Grace_Period__c> gps = (List<Grace_Period__c>) scope;

        List<ADA_Schedule__c> schedulesToUpdate = new List<ADA_Schedule__c>();

        for(Grace_Period__c gp : gps) {
            if(gp.ADA_Schedule__r == null || gp.ADA_Schedule__r.isEmpty()) continue;

            List<ADA_Schedule__c> schedules = gp.ADA_Schedule__r;

            for(ADA_Schedule__c s : schedules) {
                s.Development_Obligation_Status__c = 'Default';
                s.Default_Start_Date__c = gp.Paid_End_Date__c;

                schedulesToUpdate.add(s);
            }
        }


        if(schedulesToUpdate.isEmpty())  return;

        update schedulesToUpdate;
    }

    /**
    * 
    * Description : Method execute at the end of the batch process.
    * 
    *  */
    global void finish(Database.BatchableContext BC) { }
}