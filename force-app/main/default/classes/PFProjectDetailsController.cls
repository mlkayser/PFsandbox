/**
* Controller for the Page PFProjectDetails. Obtains the Club_id related with 
* a Project.
* 
* @Updated: 9/08/2015 Andres Di Geronimo-Stenberg (Magnet360)
* @Jira: PFCC-2857 
*/
public class PFProjectDetailsController 
{
    public ID club_id {get;set;}

    
/******************************************************************************
 * PFProjectDetailsController
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 9/08/2015
 * @jira: PFCC-2857
 * @description: Constructor - Obtains the Club_id related with a Project.
 * @param: ApexPages.StandardController controller
 * @return: None.
 ******************************************************************************/    
    public PFProjectDetailsController(ApexPages.StandardController controller) 
    {
        club_id = [ Select Club_Location__c From Project__c Where Id = :controller.getID()].Club_Location__c; 
    }

}