@isTest
private class PFRetailSubmitControllerTest {

    @isTest
    static void RetailSubmit(){
        PFRetailSubmitController r = new PFRetailSubmitController();
        r.searchstring = '012345678999';
        r.errors = '';
        r.myproductname = 'Test Product';
        r.mybarcode = '012345678999';
        r.mystatus = 'Approved';
        
        Retail_Product__c rp = new Retail_Product__c();
        rp.Name = r.myproductname;
        rp.barcode__c = r.mybarcode;
        rp.status__c = r.mystatus;
        insert rp;
        
        r.search();
        r.clear();
        
        r.searchstring = '012345678998';
        r.search();
    }
    
    static void search(){
        PFRetailSubmitController con = new PFRetailSubmitController();
    }
    
 
  
}