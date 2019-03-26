/**
* Controller for PFImportandDates.component
* 
* @date: 9/4/15
* @Author: Andres Di Geronimo-Stenberg (Magnet360)
* @Jira: PFCC-2536
* @Comments: Search for the most recent 5 events (Custom object Events__c)
*/
public without sharing class PFImportantDatesController 
{

    public List< Event__c > recentEvents 
    {
        get
        {
            return  [ Select Id, 
                             Name, 
                             Event_Date__c 
                      From Event__c 
                      Where Event_Date__c >= TODAY
                      AND RecordType.Name <> 'FAC' 
                      Order by Event_Date__c Asc
                      Limit 5 ];
        }
        set;
    }
    
}