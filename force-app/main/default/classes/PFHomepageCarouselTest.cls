@isTest
private class PFHomepageCarouselTest
{

   @testSetup static void setUpMethod()
   {
        Community_Settings__c l_comm_settings =  new Community_Settings__c();
        l_comm_settings.Banner_Library_Name__c = 'Community Banner Images'; //'Community Banner Images';
        insert l_comm_settings;
   }

    @isTest
    static void Carousel()
    {
        Set<ID> contentVersionIds = new Set<ID>();
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        List<ContentWorkspaceDoc> contentWorkDocs = new List<ContentWorkspaceDoc>();
        ID contentWorkSpaceID;
        
        // query for the Workspace ID, error and quit if one is not found
        try
        {
            contentWorkSpaceID = [ Select Id 
                                   From ContentWorkspace 
                                   Where Name = :Community_Settings__c.getInstance().Banner_Library_Name__c 
                                   Limit 1].Id;
        }
        catch(QueryException e)
        {
            System.debug(e.getMessage());
            //System.assert(false);
        }
    
        // insert new ContentVersion records
        for( Integer i = 0; i < 2; i++ )
        {
                contentVersions.add( new ContentVersion(
                                        Title = 'Test Title ' + i,
                                        PathOnClient = 'C:\FilePath' + i + '.txt',
                                        VersionData = Blob.valueOf('Test Content Version File Body')
                                        ));
            }
    
            insert contentVersions; 
    
            // create a set of the new ContentVersion record IDs
            for( ContentVersion cv : contentVersions )
            {
                contentVersionIds.add(cv.Id);
            }
    
            // get updated values on ContentVersion records
            contentVersions.clear();
            contentVersions = [ Select Id, 
                                       Title, 
                                       ContentDocumentId, 
                                       TagCsv 
                               From ContentVersion 
                               Where Id In :contentVersionIds ];
    
            // create the ContentWorkspaceDoc for each ContentVersion record
            // update tag on ContentVersion records
            for( ContentVersion cv : contentVersions )
            {
                contentWorkDocs.add(new ContentWorkspaceDoc(
                                        ContentDocumentId = cv.ContentDocumentId,
                                        ContentWorkspaceId = contentWorkSpaceID
                                    ));
                cv.TagCsv = 'Test Tag';
            }
    
            insert contentWorkDocs;
            update contentVersions;
    
            Test.startTest();
                PFHomepageCarouselController cc = new PFHomepageCarouselController();
                List< ContentVersion > cont_ver_list = cc.bannerImages;
            Test.stopTest();
    
            system.assertEquals( cont_ver_list.size() , 2 );
        }
}