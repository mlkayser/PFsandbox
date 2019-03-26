@isTest
public class PFSubmitProductControllerTest {
@isTest
     static void RetailLoad(){
        PFSubmitProductController r = new PFSubmitProductController();
        
        Retail_Product__c rp = new Retail_Product__c();
        rp.Name = 'Test Product';
        rp.barcode__c = '012345678999';
        rp.status__c = 'Approved';
        rp.Category__c = 'Clothing';
        rp.SubCategory__c = 'Accessories';
        rp.MSRP__c = 9.99;
        insert rp;
        
        PFSubmitProductController con = new PFSubmitProductController();
       
    }
}