/**
* Controller for PFTopSellingItemsSection.component
* 
* @Updated: 9/18/2015 Andres Di Geronimo-Stenberg (Magnet360)
* @Jira: PFCC-2696 - Controller for Judgement free press
*/
public without sharing class PFTopSellingSectionController 
{
    public List< Retail_Product__c > overal_products {get;set;}
    public List< Retail_Product__c > fusion_products{get;set;}
    public List< Retail_Product__c > tanning_products {get;set;}
    public List< Retail_Product__c > beverages_products {get;set;}

    private Static String FUSION = 'Fusion';
    private Static String TANNING = 'Tanning';
    private Static String BEVERAGES = 'Beverages';

 /******************************************************************************
 * PFTopSellingSectionController
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 9/18/2015 
 * @jira: PFCC-2696
 * @description: Gets the Top 20 Retail_Product__c base on the Number_Sold__c, 
                 and return the values splited by 3 categories: Fusion, Tanning
                 and Beverages
 * @param: None.
 * @return: None.
 ******************************************************************************/
    public PFTopSellingSectionController() 
    {
        overal_products = [ Select Category__c,
                                   Description__c,
                                   Name,
                                   Number_Sold__c,
                                   Black_Card_Member_Item__c,
                                   Planet_Fitness_Item__c
                            From Retail_Product__c
                            Where Category__c != NULL 
                            Order By Number_Sold__c DESC 
                            Limit 20 ];

         Map< String , List< Retail_Product__c > > product_category = 
                                new Map< String , List< Retail_Product__c > >();

        for( Retail_Product__c rp : overal_products )
        {
            List< Retail_Product__c > l_rp_aux = new List< Retail_Product__c >();

            if( product_category.containsKey( rp.Category__c) )
            {
                l_rp_aux = product_category.get( rp.Category__c);
            }

            l_rp_aux.add( rp );

            product_category.put( rp.Category__c , l_rp_aux );
        }

        for( String category : product_category.keySet() )
        {
            if( category == FUSION )
            {
                fusion_products = product_category.get( category );
            }
            else if ( category == TANNING )
            {
                tanning_products = product_category.get( category );
            }
            else if ( category == BEVERAGES )
            {
                beverages_products = product_category.get( category );
            }
        }
    }
}