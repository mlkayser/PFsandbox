/**
* Class that retrieves the Knowledge articles for Operations, filtering by
* Subtype Methods_of_Operation_Announcements
* 
* @Author: 9/9/2015 Andres Di Geronimo-Stenberg (Magnet360)
* @Jira: PFCC-2637 - Home Page: Operational Updates
*/
public with sharing class PFHomeOperationalUpdatesController {
    
    //public List<OperationalUpdates> operational_updates_list {get;set;}
    //private static String METHODS_OF_OPP_ANN = 'Methods_of_Operations_Announcements';

 /******************************************************************************
 * PFHomeOperationalUpdatesController
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 9/9/2015
 * @jira: PFCC-2637
 * @description: Selects all the Knowledge Articles related with Operations 
                 Type, and displays only the ones with Sub Category equals to
                 Methods_of_Operation_Announcements
 * @param: None.
 * @return: None.
 ******************************************************************************/
    /*public PFHomeOperationalUpdatesController() {
        operational_updates_list = new List<OperationalUpdates>();
        Id RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Operations').getRecordTypeId();

        Map<Id, Knowledge__kav>  operations_articleList = 
            new Map<id, Knowledge__kav> ([
              SELECT Id, 
                     Title,
                     LastPublishedDate, 
                     KnowledgearticleId,
                     Summary__c,
                     Summary 
              FROM Knowledge__kav 
              WHERE PublishStatus= 'Online' 
              AND Language = 'en_US'
              AND RecordTypeId = :RecordTypeId
              ORDER BY LastPublishedDate DESC
            ]);

        System.debug('DEBUG ***=> operations_articleList = ' + operations_articleList.size());

        if (operations_articleList != null && 
            operations_articleList.size() > 0) {
            List<Knowledge__DataCategorySelection> operations_categoryList = [
              SELECT Id, 
                       DataCategoryName, 
                       ParentId
              FROM Knowledge__DataCategorySelection 
              WHERE ParentId IN : operations_articleList.keySet() 
            ];

            Map <ID, List<String> > category_parentIdList = new Map <ID, List<String> >();
            for (Knowledge__DataCategorySelection categ : operations_categoryList){
                List<String> l_aux = new List<String>();

                if (category_parentIdList.containsKey(categ.ParentId)){
                    l_aux = category_parentIdList.get( categ.ParentId);
                }
                l_aux.add(categ.DataCategoryName);
                category_parentIdList.put(categ.ParentId, l_aux);
            }
            System.debug('DEBUG ***=> category_parentIdList = ' + category_parentIdList.size());

            for (Knowledge__kav operations_article : operations_articleList.values()){
                System.debug('DEBUG ***=> operations_article.Id = ' + operations_article.Id);

                if (category_parentIdList.containsKey( operations_article.Id )) {
                    for (String sub_category : category_parentIdList.get(operations_article.Id)) {
                        if (sub_category == METHODS_OF_OPP_ANN) {
                            if (operational_updates_list.size() < 4) {
                                operational_updates_list.add(new OperationalUpdates(operations_article));
                                System.debug('DEBUG ***=> added article to list operational_updates_list  = ' + operational_updates_list.size());
                            }
                        }
                    }
                }
            }
        }
    }*/

/**
* Wrapper Class, that contains the info to be displayed on the Component
* 
* @Author: 9/9/2015 Andres Di Geronimo-Stenberg (Magnet360)
* @Jira: PFCC-2637 - Home Page: Operational Updates
*/
    /*public Class OperationalUpdates{
        public String article_title {get;set;}
        public String article_summary {get;set;}
        public ID article_id {get;set;}
        public Boolean read_more {get;set;} // True if the summary has more than 260 charactes

        public OperationalUpdates( Knowledge__kav the_operations_article ) {
            article_title = the_operations_article.Title;
            try {
                article_summary = the_operations_article.Summary.substring( 0 , Math.Min ( the_operations_article.Summary.Length(), 260 ) );
            } catch(Exception e) {
                article_summary = the_operations_article.Summary;
            }
            article_id = the_operations_article.KnowledgearticleId;
            read_more = false;
            if (the_operations_article.Summary.Length() > 260){
                read_more = true;
            }
        }
    }*/

}