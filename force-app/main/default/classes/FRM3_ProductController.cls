public class FRM3_ProductController {

    @auraEnabled
    public List<Retail_Product__c> getProducts() {
        String userid = UserInfo.getUserId();
        List<Retail_Product__c> products = new List<Retail_Product__c>();
        products = [
        	SELECT Name, Status__c, Category__c, SubCategory__c, MSRP__c, Barcode__c 
        	FROM Retail_Product__c 
        	WHERE CreatedById = :userid  
     	];
     	return products; 
    }

}