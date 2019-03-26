public class PFFACController {

    Public List<Knowledge__kav> FACdocs_List {get;set;}
    Public List<Knowledge__kav> FACmin_List {get;set;}
    Public List<Event__c> FACevents_List {get;set;}
    
    public PFFACController() { 

        FACdocs_List = new List<Knowledge__kav>();
        FACmin_List = new List<Knowledge__kav>();

        Id CommitteesRTid = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName()
            .get('Committees').getRecordTypeId();

        // get all Committees articles
        Map<Id, Knowledge__kav> articles_Map = new Map<Id, Knowledge__kav>([
            SELECT Id, 
                Title, 
                Summary, 
                Governing_Documents__c,
                LastPublishedDate, 
                KnowledgearticleId  
            FROM Knowledge__kav
            WHERE PublishStatus = 'Online'
            AND Language = 'en_US'
            AND RecordTypeId = :CommitteesRTid
            ORDER BY LastPublishedDate DESC
        ]);

        // get all categories associated with selected articles
        // ParentId is Article Id
        List<Knowledge__DataCategorySelection> categories_List = [
            SELECT Id, 
                DataCategoryName, 
                ParentId
            FROM Knowledge__DataCategorySelection 
            WHERE ParentId IN : articles_Map.keySet() 
        ];

        // map articles and categories
        Map<ID, String > parentId_categoryName_Map = new Map<ID, String>();
        for (Knowledge__DataCategorySelection category : categories_List) {
            if (articles_Map.containsKey(category.ParentId)) {
                parentId_categoryName_Map.put(category.ParentId, category.DataCategoryName);
            }
        }

        for (Knowledge__kav article : articles_Map.values()) {
            if (parentId_categoryName_Map.get(article.Id) == 'FAC') {
                if (article.Governing_Documents__c == False) {
                    FACdocs_List.add(article);
                }
                else if (article.Governing_Documents__c == True) {
                    FACmin_List.add(article);
                }
            }
        }

        FACevents_List = [
        	SELECT Id, Name, Event_Date__c 
        	FROM Event__c 
        	WHERE RecordType.Name = 'FAC' 
        	AND Event_Date__c >= TODAY 
        	ORDER BY Event_Date__c Asc
        ];
    }
}