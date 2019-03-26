@isTest
public class PFFACTest {

    @isTest
	static void testPFFACController() {

        User current_user = PFTestUtility.getCurrentUser();
        PFTestUtility.setKnowledgeUser(current_user);

        Id RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName()
            .get('Committees').getRecordTypeId();

        System.runAs(current_user) {  
            // create test articles
            
            Knowledge__kav facDoc = new Knowledge__kav(
                Title = 'Test Doc',
                UrlName = 'Test-Doc',
                Governing_Documents__c = False,
                RecordTypeId = RecordTypeId
                ); 
            insert facDoc;
            
            facDoc = [
                SELECT KnowledgeArticleId 
                FROM Knowledge__kav 
                WHERE Id = :facDoc.Id
            ];
            KbManagement.PublishingService.publishArticle(facDoc.KnowledgeArticleId, true);

            Knowledge__kav facGov = new Knowledge__kav(
                Title = 'Test Gov',
                UrlName = 'Test-Gov',
                Governing_Documents__c = True,
                RecordTypeId = RecordTypeId
                ); 
            insert facGov;

            facGov = [
                SELECT KnowledgeArticleId 
                FROM Knowledge__kav 
                WHERE Id = :facGov.Id
            ];
            KbManagement.PublishingService.publishArticle(facGov.KnowledgeArticleId, true);

            // create data categories
            List<Knowledge__DataCategorySelection> category_List = new List<Knowledge__DataCategorySelection>();

            Knowledge__DataCategorySelection data_cat1 = new Knowledge__DataCategorySelection();
            data_cat1.DataCategoryName = 'FAC';
            data_cat1.ParentId = facDoc.Id;
            data_cat1.DataCategoryGroupName = 'All_Content';
            category_List.add(data_cat1);
            
            Knowledge__DataCategorySelection data_cat2 = new Knowledge__DataCategorySelection();
            data_cat2.DataCategoryName = 'FAC';
            data_cat2.ParentId = facGov.Id;
            data_cat2.DataCategoryGroupName = 'All_Content';
            category_List.add(data_cat2);

            insert category_List;
        }

		Test.startTest();
            PFFACController FACcontroller = new PFFACController();
            List<Knowledge__kav> FACdocs_List = FACcontroller.FACdocs_List; 
            List<Knowledge__kav> FACmin_List = FACcontroller.FACmin_List;        
        Test.stopTest();

        System.debug('FacDocs size = ' + FACdocs_List.size());
        System.debug('FacMin size = ' + FACmin_List.size());
        system.assertEquals(FACdocs_List.size(), 1);
        system.assertEquals(FACmin_List.size(), 1);
    }
}