/**
* Class that retrives the Banners from the Content Library 
* 
* @Updated: 8/27/2015 Andres Di Geronimo-Stenberg (Magnet360)
* @Jira: PFCC-2664 - Retrived URL related with each banner
*/
public class PFHomepageCarouselController {
    
/******************************************************************************
 * bannerImages
 * @Updated: 8/27/2015 Andres Di Geronimo-Stenberg (Magnet360)
 * @jira: PFCC-2664 - Retrived URL related with each banner
 * @return: List of ContentVersion with Contend ID and URL
 ******************************************************************************/
    public List< ContentVersion > bannerImages
    {
        get{
            List<ID> l_content_id = new List<ID>();

            if( bannerImages== null )
            {
                bannerImages= new list< ContentVersion >();

                List< ContentWorkspace > ContentWorkspaces = [ SELECT Id 
                                                               FROM ContentWorkspace 
                                                               WHERE Name = :Community_Settings__c.getInstance().Banner_Library_Name__c limit 1];
                if( !ContentWorkspaces.isEmpty() )
                {
                    for( ContentDocument cd :[ SELECT LatestPublishedVersionId
                                               FROM ContentDocument 
                                               WHERE ParentId = :ContentWorkspaces[0].Id] )
                    {
                         l_content_id.add( cd.LatestPublishedVersionId );      
                    }
                    for( ContentVersion cv :[ SELECT ID, url__c
                                              FROM ContentVersion 
                                              WHERE ID IN :l_content_id] )
                    {
                         bannerImages.add( cv );      
                    }

                }
            }
            return bannerImages;
        }set;
    }

}