/**
* Crontoller for the visualForce PFRetail
* 
* @Author: 9/9/2015 Andres Di Geronimo-Stenberg (Magnet360)
* @Jira: PFCC-2690 & PFCC-2799
*/
public with sharing class PFRetailController {

    /*private static String BRAND_STAND = 'Brand_Standards';
    private static String IN_CLUB_PRESENTATION = 'In_Club_Presentations';
    private static String FUSION_RETAIL_BARCODE = 'Fusion_Retail_Barcodes';*/

 /******************************************************************************
 * getBrandStandards
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 9/9/2015
 * @jira: PFCC-2799
 * @description: Selects the most recent Knowledge Article realted with 
                 Brand_Standards Type, and filters to obtain only the one with 
                 Category equals to Brand_Standards 
 * @param: None.
 * @return: ID : articleId
 ******************************************************************************/
    /*public Id getBrandStandards(){
        Id brand_standards_article_id;
        Id brandStandards_RTId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName()
            .get('Brand Standards').getRecordTypeId();

        Map<Id, Knowledge__kav> l_articles_type = 
            new Map<Id, Knowledge__kav> ([ 
                SELECT Id, KnowledgeArticleId 
              	FROM Knowledge__kav 
              	WHERE PublishStatus= 'Online' 
              	AND Language = 'en_US'
                AND RecordTypeID = :brandStandards_RTId
              	ORDER BY LastPublishedDate DESC 
              	LIMIT 1 
        	]);
                                        
        if (l_articles_type != null && l_articles_type.size() > 0){
            List<Knowledge__DataCategorySelection> l_data_categories = [ 
                SELECT Id, DataCategoryName, ParentId
                FROM Knowledge__DataCategorySelection 
                WHERE ParentId IN : l_articles_type.keySet() 
            ];

            Map <Id, List< String> > l_parent_id_category = articleByCategories(l_data_categories);            
            try {
            	brand_standards_article_id = (Id)((Knowledge__kav)findArticles(BRAND_STAND, 
                                                                               l_articles_type.values(), 
                                                                               l_parent_id_category)[0]).KnowledgearticleId;
            }
            catch( exception e ){}
        }

        return brand_standards_article_id;
    }*/

 /******************************************************************************
 * getInClubPresentation
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 9/9/2015
 * @jira: PFCC-2690
 * @description: Selects the most recent Knowledge Article realted with 
                 In_Club_Presentations Type, and filters to obtain only the one 
                 with Category equals to In_Club_Presentations 
 * @param: None.
 * @return: ID : articleId
 ******************************************************************************/
    /*public ID getInClubPresentation(){
        ID in_club_article_id ;
        Id clubPresentations_RTId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName()
            .get('In Club Presentations').getRecordTypeId();

        Map<Id, Knowledge__kav> l_articles_type = 
            new Map<id, Knowledge__kav> ([ 
                SELECT Id, KnowledgeArticleId 
              	FROM Knowledge__kav 
              	WHERE PublishStatus= 'Online' 
              	AND Language = 'en_US'
                AND RecordTypeId = :clubPresentations_RTId
              	ORDER BY LastPublishedDate DESC 
              	LIMIT 1 
        ]);
                                        
        if (l_articles_type != null && l_articles_type.size() > 0){
            List<Knowledge__DataCategorySelection> l_data_categories = [ 
                SELECT Id, DataCategoryName, ParentId
              	FROM Knowledge__DataCategorySelection 
              	WHERE ParentId IN : l_articles_type.keySet() 
           	];

            Map<Id, List<String> > l_parent_id_category = articleByCategories( l_data_categories );
            try {
                in_club_article_id = (Id)((Knowledge__kav) findArticles(IN_CLUB_PRESENTATION, 
                                                                        l_articles_type.values(), 
                                                                        l_parent_id_category )[0]).KnowledgearticleId;
            }
            catch( exception e ){}
        }

        return in_club_article_id;
    }*/

 /******************************************************************************
 * getFusionRetailBarcodes
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 9/9/2015
 * @jira: PFCC-2690
 * @description: Selects a list of Knowledge Article realted with 
                 Fusion_Retail_Barcodes Type, and filters to obtain only the one 
                 with Category equals to Fusion_Retail_Barcodes 
 * @param: None.
 * @return: List< Fusion_Retail_Barcodes__kav >
 ******************************************************************************/
    /*public List<Knowledge__kav> getFusionRetailBarcodes(){
        List<Knowledge__kav > fusion_retail_barcode_list ;
        Id fusionRetBarcodes_RTId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName()
            .get('Fusion Retail Barcodes').getRecordTypeId();

        Map<Id, Knowledge__kav> l_articles_type = 
            new Map<id, Knowledge__kav> ([ 
                SELECT Id, KnowledgeArticleId, Summary__c, Title
              	FROM Knowledge__kav 
              	WHERE PublishStatus= 'Online' 
              	AND Language = 'en_US'
                AND RecordTypeId = :fusionRetBarcodes_RTId
              	ORDER BY LastPublishedDate DESC 
       	]);
                                        
        if (l_articles_type != null && l_articles_type.size() > 0) {
            List<Knowledge__DataCategorySelection> l_data_categories = [ 
                SELECT Id, DataCategoryName, ParentId
                FROM Knowledge__DataCategorySelection 
                WHERE ParentId IN : l_articles_type.keySet() ];

            Map<Id, List<String> > l_parent_id_category = articleByCategories(l_data_categories);
            try {
                fusion_retail_barcode_list = (List<Knowledge__kav>) findArticles(FUSION_RETAIL_BARCODE, 
                                                                                  l_articles_type.values(), 
                                                                                  l_parent_id_category);
            }
            catch( exception e ){}
        }

        return fusion_retail_barcode_list;
    }*/   

 /******************************************************************************
 * getInClubPresentation
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 9/9/2015
 * @jira: PFCC-2690
 * @description: Because an article type could have more than one category, this 
                 method grouped all the categories related with an article 
 * @param: List< sObject > a_data_categories
 * @return: Map < ID , List< String > > : <ArticleID, List< Categories > >
 ******************************************************************************/
    /*public Map <Id, List<String> > articleByCategories (List<sObject> a_data_categories ){
        
        Map <Id, List<String> > l_parent_id_category = new Map <Id, List<String> >();
        for (sObject so : a_data_categories) {
            List<String> l_aux = new List<String>();

            if (l_parent_id_category.containsKey((Id)so.get('ParentId'))) {
                l_aux = l_parent_id_category.get((Id)so.get('ParentId'));
            }
            l_aux.add((String)so.get('DataCategoryName'));
            l_parent_id_category.put((Id)so.get('ParentId'), l_aux);
        }

        return l_parent_id_category;
    }*/

 /******************************************************************************
 * getInClubPresentation
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 9/9/2015
 * @jira: PFCC-2690
 * @description: Search for all the categories from the Article to find the one
                 equals to a_data_category, and returns a list of Articles that 
                 match that category
 * @param: String a_data_category.
 * @param: List< sObject > a_data_categories
 * @param: Map < ID , List< String > > a_parent_id_category
 * @return: List< sObject > : List of Articles matching a_data_category
 ******************************************************************************/
    /*public List<sObject> findArticles(String a_data_category, 
                              List<sObject> a_data_categories, 
                              Map<Id, List<String> > a_parent_id_category){
        List<sObject> article_list = new List<sObject>();

        for (sObject so : a_data_categories){
            if (a_parent_id_category.containsKey((Id)so.get('Id'))) {
                for (String sub_category : a_parent_id_category.get((Id)so.get('Id'))) {
                    if (sub_category == a_data_category) {
                        article_list.add ( so );
                    }
                }
            }
        }
        return article_list;
    }*/
}