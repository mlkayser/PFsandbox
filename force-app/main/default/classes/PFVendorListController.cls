/**
* Class that retrives The list View 'Community_Vendors'
* 
* @Created: 9/14/2015 Andres Di Geronimo-Stenberg (Magnet360)
* @Jira: PFCC-2661 - Show Vendor List on Community
*/
public without sharing class PFVendorListController 
{
    public String list_view {get;set;}

    private Static String COMMUNITY_VENDORS = 'Community Vendors';

 /******************************************************************************
 * PFVendorListController
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 9/14/2015
 * @jira: PFCC-2661
 * @description: Controller
 * @param: None.
 * @return: None.
 ******************************************************************************/
    public PFVendorListController()
    {
        String l_query = 'SELECT Name FROM Account LIMIT 1';

        list_view = getListView( l_query , COMMUNITY_VENDORS );
    }

 /******************************************************************************
 * getListView
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 9/14/2015
 * @jira: PFCC-2661
 * @description: Gets the list view Id with name == a_list_view_name from the 
                 Record got from a_query
 * @param: String a_query
 * @param: String a_list_view_name
 * @return: None.
 ******************************************************************************/
    public static String getListView( String a_query, String a_list_view_name )
    {
        String l_list_view_iid = null;

        ApexPages.StandardSetController ssc = 
            new ApexPages.StandardSetController(Database.getQueryLocator(a_query));

        List<SelectOption> allViews = ssc.getListViewOptions();

        for (SelectOption so : allViews) 
        {
            if (so.getLabel() == a_list_view_name ) 
            {
                l_list_view_iid = so.getValue();
                break;
            }
        }
        if( l_list_view_iid != null )
        {
            // for some reason, won't work with 18 digit ID
            l_list_view_iid = l_list_view_iid.substring(0,15);
        }
        return l_list_view_iid;        
    }

}