public class PFRetailSubmitController {
    
    public list <Retail_Product__c> retailproduct {get;set;}  
    public string searchstring {get;set;}  
    public string errors {get;set;} 
    public string myproductname {get;set;}
    public string mybarcode {get;set;}
    public string mystatus {get;set;}

    public void search(){
        errors = '';
        myproductname = '';
        mybarcode = '';
        mystatus = '';
        if (searchstring <> ''){
            string searchquery='SELECT status__c, Name, barcode__c FROM Retail_Product__c WHERE barcode__c like \'%'+searchstring+'%\' LIMIT 1';  
     		retailproduct= Database.query(searchquery); 
       		if (retailproduct.size() == 0){
                errors = 'No Results Found';
                myproductname = '';
                mybarcode = '';
                mystatus = '';
            }
            if (retailproduct.size() == 1){
                errors = 'Barcode ';
                myproductname = ([SELECT Name FROM Retail_Product__c WHERE barcode__c = :searchstring LIMIT 1].Name);
                mybarcode = ([SELECT barcode__c FROM Retail_Product__c WHERE barcode__c = :searchstring LIMIT 1].barcode__c);
                mybarcode = mybarcode + ' has already been ';
                mystatus = ([SELECT status__c FROM Retail_Product__c WHERE barcode__c = :searchstring LIMIT 1].status__c);
                mystatus = mystatus + ' for ';
            }
        }
    }
    public void clear(){  
    retailproduct.clear();
    }  
}