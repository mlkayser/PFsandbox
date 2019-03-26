/**
 * Created by manuela.lkayser on 6/4/18.
 */

@isTest
public with sharing class cloneOpportunityProductListExtTest {
    
    @TestSetup
    static void setup(){

        //Create product
        Product2 prod = new Product2 (
             Name = 'Product X',
             ProductCode = 'Pro-X',
             isActive = true
        );
        insert prod;

    	//Create pricebook entry
        Id pricebookId = Test.getStandardPricebookId();
		PricebookEntry pbEntry = new PricebookEntry (
         	Pricebook2Id = pricebookId,
         	Product2Id = prod.Id,
         	UnitPrice = 100.00,
         	IsActive = true
        );
        insert pbEntry;

        // create group
        Group__c grp = new Group__c(
            Name = 'Test Group',
            Group__c = 'G0001');
        insert grp;    

        // Create Account1
        Account acc1 = new Account(
            Name ='Test Account1',
            Status__c = 'Market Analysis',
            Group_Name__c = grp.id
        );
		insert acc1;
        
        // Create Opportunity to be updated
        Opportunity opp1 = new Opportunity (
            Name='Test Opportunity1',  
            AccountId= acc1.Id,
            StageName = 'Introduction', 
            CloseDate = Date.Today()
        ); 
        insert opp1;

        // Create Account2
        Account acc2 = new Account(
           Name ='Test Account2',
           Status__c = 'Market Analysis',
           Group_Name__c = grp.id
        );
		insert acc2;
                
        // Create Opportunity with Products
        Opportunity opp2 = new Opportunity (
            Name='Test Opportunity2',  
            AccountId= acc2.Id,
            StageName = 'Introduction', 
            CloseDate = Date.Today(),
            Pricebook2Id = pricebookId
        ); 
        insert opp2;

        //create  opportunity line item.
        Integer quantity = 5;
        OpportunityLineItem oppLitem = new OpportunityLineItem (
             OpportunityId = opp2.Id,
             Quantity = quantity,
             PricebookEntryId = pbEntry.Id,
             TotalPrice = quantity * pbEntry.UnitPrice
        );
        insert oppLitem;               
    }

    @isTest
    static void addProductsTestPos() {  
        Opportunity opp1 = [SELECT id FROM Opportunity WHERE Name = 'Test Opportunity1'];

        Test.StartTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(opp1);
        	ApexPages.currentPage().getParameters().put('id', opp1.Id);
        	cloneOpportunityProductsListExt  extension = new cloneOpportunityProductsListExt(controller);
        	extension.oppWithProdsName = 'Test Opportunity2';
			PageReference oppPage = extension.addProducts();

        	opp1 = [SELECT id, Pricebook2Id, CurrencyIsoCode 
                    FROM Opportunity 
                    WHERE Name = 'Test Opportunity1'];
        	Opportunity opp2 = [SELECT id, Pricebook2Id, CurrencyIsoCode 
                    FROM Opportunity 
                    WHERE Name = 'Test Opportunity2'];
			System.assertEquals(opp1.Pricebook2Id, opp2.Pricebook2Id);
			System.assertEquals(opp1.CurrencyIsoCode, opp2.CurrencyIsoCode);
                
        	List<OpportunityLineItem> oppLineItems = [
                SELECT id, name, Product2Id 
                FROM OpportunityLineItem
                WHERE OpportunityId = :opp1.Id
            ];
            System.assert(oppLineItems.size() > 0,'Products added to opp1');
    	Test.StopTest();
    }

    @isTest
    static void addProductsTestNeg() {  
        Opportunity opp1 = [SELECT id FROM Opportunity WHERE Name = 'Test Opportunity1'];

        Test.StartTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(opp1);
        	ApexPages.currentPage().getParameters().put('id', opp1.Id);
        	cloneOpportunityProductsListExt  extension = new cloneOpportunityProductsListExt(controller);
        	extension.oppWithProdsName = '';
			PageReference oppPage = extension.addProducts();
                
        	 List<OpportunityLineItem> oppLineItems = [
                SELECT id, name, Product2Id 
                FROM OpportunityLineItem
                WHERE OpportunityId = :opp1.Id
            ];
            System.assert(oppLineItems.size() == 0,'Products NOT added to opp1');
    	Test.StopTest();
    }
}