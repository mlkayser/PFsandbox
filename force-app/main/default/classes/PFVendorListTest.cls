@isTest
private class PFVendorListTest
{
	@isTest
	static void vendorTest()
	{
        Group__c g = new Group__c(
    			Name = 'Test Group',
        		Group__c = 'G0001');
    	insert g;
        
        Account l_vendor_acc = new Account();
        l_vendor_acc.Name = 'Test Vendor';
        l_vendor_acc.Type = 'Construction';
        l_vendor_acc.Group_Name__c = g.id;
        l_vendor_acc.Community_View__c = 'Yes';

        insert l_vendor_acc;

        Test.startTest();
        
            PFVendorListController l_controller = new PFVendorListController();

        Test.stopTest();
	}

    @isTest
    static void ProductTest()
    {
        Retail_Product__c l_retail_product = new Retail_Product__c();
        l_retail_product.Name = 'Product';
        l_retail_product.Barcode__c = '12345612';

        insert l_retail_product;

        Test.startTest();
        
            PFSubmitProductController l_controller = new PFSubmitProductController();

        Test.stopTest();
    }


}