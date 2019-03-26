@isTest
private class PFAcountViewRedirectTest
{
    @isTest
    static void vendorAccount()
    {
        Account l_vendor_acc =  new Account();
        l_vendor_acc.RecordTypeId = PFTestUtility.vendor_account_rt.id;
        l_vendor_acc.Name = 'Vendor Test';
        l_vendor_acc.Type = 'Retail';
        insert l_vendor_acc;

        Test.startTest();

            ApexPages.StandardController sc =  new ApexPages.StandardController( l_vendor_acc );
            PFAcountViewRedirectController l_controller = new PFAcountViewRedirectController( sc );
            system.assertEquals( l_controller.is_vendor , true );

        Test.stopTest();

	}
}