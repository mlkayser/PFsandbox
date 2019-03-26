@isTest
private class PFHomeOperationalUpdatesTest{

    // test for empty controller
    @isTest
    static void testPFHomeOperationalUpdates(){
        PFHomeOperationalUpdatesController controller = new PFHomeOperationalUpdatesController();
    }

    /*@isTest
    static void testPFHomeOperationalUpdates(){

       Id RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName()
                    .get('Operations').getRecordTypeId();
        User current_user = PFTestUtility.getCurrentUser();
        PFTestUtility.setKnowledgeUser(current_user);

        System.runAs(current_user) {  
            Knowledge__kav article = new Knowledge__kav();
            article.Title = 'Test1';
            article.UrlName = 'Test1';
            article.Summary__C = 'Test1';
            article.Summary = 'Test1';
            article.RecordTypeId = RecordTypeId;
            insert article;

            //retrieve master article Id created on Operations__kav record 
            //insertion in order to get the KnowledgeArticleId
            article = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :article.Id];

            //publish it
            KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

            List<Knowledge__DataCategorySelection> data_cat_list = new List<Knowledge__DataCategorySelection>();
            Knowledge__DataCategorySelection data_cat = new Knowledge__DataCategorySelection();
            data_cat.DataCategoryName ='Methods_of_Operations_Announcements';
            data_cat.ParentId = article.id;
            data_cat.DataCategoryGroupName ='Club_Operations';
            data_cat_list.add( data_cat );
            insert data_cat_list;

            Test.startTest();
                PFHomeOperationalUpdatesController controller = new PFHomeOperationalUpdatesController();
                system.assertEquals( controller.operational_updates_list.size() , 1 );
                system.assertEquals( controller.operational_updates_list[0].read_more , false );
            Test.stopTest();
        }
    }*/
}