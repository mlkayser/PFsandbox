/**
* Crontoller for the visualForce PFAcountViewRedirect.page
* 
* @Author: 9/17/2015 Andres Di Geronimo-Stenberg (Magnet360)
* @Jira: PFCC-3003
*/
public without sharing class PFAcountViewRedirectController 
{
    public Boolean is_vendor {get;set;}

 /******************************************************************************
 * PFAcountViewRedirectController
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 9/17/2015
 * @jira: PFCC-3003
 * @description: Checks the account record type and set the Boolean is_vendor if 
                 true
 * @param: ApexPages.StandardController controller
 * @return: ID : articleId
 ******************************************************************************/   
    public PFAcountViewRedirectController( ApexPages.StandardController controller ) 
    {
        String recordId = controller.getId();

        ID l_acc_rt = [ Select RecordTypeID From Account Where Id = :recordId].RecordTypeID;

        ID l_vendor_rt = [ Select ID 
                           From RecordType 
                           Where DeveloperName = :'Vendor' 
                           And SobjectType =: 'Account' ].Id;

        is_vendor = false;

        if( l_acc_rt == l_vendor_rt )
        {
            is_vendor = true;
        }

    }
}