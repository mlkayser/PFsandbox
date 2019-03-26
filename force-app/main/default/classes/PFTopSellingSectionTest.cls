@isTest
private class PFTopSellingSectionTest
{
    @isTest
    static void topSelling()
    {
        List< Retail_Product__c > l_products_list = new List< Retail_Product__c >();

        l_products_list.add( PFTestUtility.createProduct('Fusion') );
        l_products_list.add( PFTestUtility.createProduct('Tanning') );
        l_products_list.add( PFTestUtility.createProduct('Beverages') );
        l_products_list.add( PFTestUtility.createProduct('Beverages') );
        l_products_list.add( PFTestUtility.createProduct('Beverages') );

        insert l_products_list;

        Test.startTest();
            PFTopSellingSectionController l_controller = new PFTopSellingSectionController();
        Test.stopTest();

        System.assertEquals( l_controller.overal_products.size() , 5 );
    }
}