public with sharing class PFSubmitProductController 
{
    public list <Retail_Product__c> retailproduct {get;set;}  

    public PFSubmitProductController()
    {
        string userid = UserInfo.getUserId() ;
         string searchquery='SELECT Name, Status__c, Category__c, SubCategory__c, MSRP__c, Barcode__c From Retail_Product__c WHERE CreatedById = :userid LIMIT 999' ;  
     		retailproduct= Database.query(searchquery); 

    }

}