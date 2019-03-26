@isTest
private class PFRetailTest {

	// test for empty controller
    @isTest
    static void testPFRetailController() {
        PFRetailController controller = new PFRetailController();
    }

    /*@isTest
	static void getBrandStandards(){
        User current_user = PFTestUtility.getCurrentUser();
        PFTestUtility.setKnowledgeUser( current_user );
    	Id brandStandards_RTId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName()
            .get('Brand Standards').getRecordTypeId();

        system.runAs(current_user){         
            Knowledge__kav article = new Knowledge__kav();
            article.Title = 'Test1';
            article.UrlName = 'Test1';
            article.Summary__C = 'Test1';
            article.RecordTypeId = brandStandards_RTId;
            insert article;

            //retrieve master article Id created on Operations__kav record 
            //insertion in order to get the KnowledgeArticleId
            article = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :article.Id];

            //publish it
            KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

            Knowledge__DataCategorySelection data_cat = new Knowledge__DataCategorySelection();
            data_cat.DataCategoryName = 'Brand_Standards';
            data_cat.ParentId = article.id;
            data_cat.DataCategoryGroupName = 'Club_Resources';
            insert data_cat;

            Test.startTest();
                PFRetailController controller = new PFRetailController();
                Id article_id = controller.getBrandStandards();
                system.assertEquals(article_id, article.KnowledgeArticleId);
            Test.stopTest();  
        }      
	}*/

    /*@isTest
    static void getInClubPresentation(){
        User current_user = PFTestUtility.getCurrentUser();
        PFTestUtility.setKnowledgeUser( current_user );
    	Id clubPresentations_RTId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName()
            .get('In Club Presentations').getRecordTypeId();

        system.runAs(current_user){   
            Knowledge__kav article = new Knowledge__kav();
            article.Title = 'Test1';
            article.UrlName = 'Test1';
            article.Summary__C = 'Test1';
            article.RecordTypeId = clubPresentations_RTId;
            insert article;

            //retrieve master article Id created on Operations__kav record 
            //insertion in order to get the KnowledgeArticleId
            article = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :article.Id];

            //publish it
            KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

            Knowledge__DataCategorySelection data_cat = new Knowledge__DataCategorySelection();
            data_cat.DataCategoryName = 'In_Club_Presentations';
            data_cat.ParentId = article.id;
            data_cat.DataCategoryGroupName = 'Club_Resources';
            insert data_cat;

            Test.startTest();
                PFRetailController controller = new PFRetailController();
                ID article_id = controller.getInClubPresentation();
                system.assertEquals(article_id, article.KnowledgeArticleId);
            Test.stopTest();   
        }     
    }*/

    /*@isTest
    static void getBarCode(){
        User current_user = PFTestUtility.getCurrentUser();
        PFTestUtility.setKnowledgeUser( current_user );
    	Id fusionRetBarcodes_RTId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName()
            .get('Fusion Retail Barcodes').getRecordTypeId();

        system.runAs(current_user){   
            Knowledge__kav article = new Knowledge__kav();
            article.Title = 'Test1';
            article.UrlName = 'Test1';
            article.Summary__C = 'Test1';
            article.RecordTypeId = fusionRetBarcodes_RTId;
            insert article;

            //retrieve master article Id created on Operations__kav record 
            //insertion in order to get the KnowledgeArticleId
            article = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :article.Id];

            //publish it
            KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

            Knowledge__DataCategorySelection data_cat = new Knowledge__DataCategorySelection();
            data_cat.DataCategoryName ='Fusion_Retail_Barcodes';
            data_cat.ParentId = article.id;
            data_cat.DataCategoryGroupName ='Club_Resources';
            insert data_cat;

            Test.startTest();
                PFRetailController controller = new PFRetailController();
                List<Knowledge__kav> article_list = controller.getFusionRetailBarcodes();
                system.assertEquals(article_list.size(), 1);
            Test.stopTest(); 
        }       
    }*/  

}