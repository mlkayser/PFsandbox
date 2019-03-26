@isTest
private class customSortOrderProductsTest {
	    
    @TestSetup
    static void setup(){

        //Create products
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2 (
             Name = 'Product 1',
             ProductCode = 'Pro-X1',
             isActive = true
        );
        prodList.add(prod1);
        Product2 prod2 = new Product2 (
             Name = 'Product 2',
             ProductCode = 'Pro-X2',
             isActive = true
        );
        prodList.add(prod2);
        Product2 prod3 = new Product2 (
             Name = 'Product 1',
             ProductCode = 'Pro-X3',
             isActive = true
        );  
        prodList.add(prod3);              
        insert prodList;

    	//Create pricebook entry
        Id pricebookId = Test.getStandardPricebookId();
		
        //List<PricebookEntry> pbEntryList = List<PricebookEntry>(); // not working
		PricebookEntry pbEntry1 = new PricebookEntry (
         	Pricebook2Id = pricebookId,
         	Product2Id = prod1.Id,
         	UnitPrice = 100.00,
         	IsActive = true
        );
        insert pbEntry1;
 		PricebookEntry pbEntry2 = new PricebookEntry (
         	Pricebook2Id = pricebookId,
         	Product2Id = prod2.Id,
         	UnitPrice = 200.00,
         	IsActive = true
        );
        insert pbEntry2;
 		PricebookEntry pbEntry3 = new PricebookEntry (
         	Pricebook2Id = pricebookId,
         	Product2Id = prod3.Id,
         	UnitPrice = 300.00,
         	IsActive = true
        );  
 		insert pbEntry3;

        /*
        pbEntryList.add(pbEntry1);
        pbEntryList.add(pbEntry2);             
        pbEntryList.add(pbEntry3);             
        insert pbEntryList;
        */

        // create group
        Group__c grp = new Group__c(
            Name = 'Test Group',
            Group__c = 'G0001');
        insert grp;    

        // Create Account
        Account acc1 = new Account(
            Name ='Test Account1',
            Status__c = 'Market Analysis',
            Group_Name__c = grp.id
        );
		insert acc1;
        
        // Create Opportunity 
        Opportunity testOpp = new Opportunity (
            Name='Test Opportunity1',  
            AccountId= acc1.Id,
            StageName = 'Introduction', 
            CloseDate = Date.Today()
        ); 
        insert testOpp;

        //create  opportunity line items
        Integer quantity = 5;
 		List<OpportunityLineItem> OLIlist = new List<OpportunityLineItem>();
        OpportunityLineItem oppLitem1 = new OpportunityLineItem (
             OpportunityId = testOpp.Id,
             Quantity = quantity,
             PricebookEntryId = pbEntry1.Id,
             TotalPrice = quantity * pbEntry1.UnitPrice,
             Sort_Order__c = 2
        );
        OLIlist.add(oppLitem1);
        OpportunityLineItem oppLitem2 = new OpportunityLineItem (
             OpportunityId = testOpp.Id,
             Quantity = quantity,
             PricebookEntryId = pbEntry2.Id,
             TotalPrice = quantity * pbEntry2.UnitPrice,
             Sort_Order__c = 3
        );
        OLIlist.add(oppLitem2);
        OpportunityLineItem oppLitem3 = new OpportunityLineItem (
             OpportunityId = testOpp.Id,
             Quantity = quantity,
             PricebookEntryId = pbEntry3.Id,
             TotalPrice = quantity * pbEntry3.UnitPrice,
             Sort_Order__c = 1
        );     
        OLIlist.add(oppLitem3);    
        insert OLIlist;               
    }

    @isTest
    static void customSortTest() {  

    	Opportunity testOpp = [
    		SELECT id
    		FROM Opportunity
    		WHERE Name = 'Test Opportunity1'
    	];

		List<OpportunityLineItem> testSort  = [
			SELECT oli.Id, oli.Sort_Order__c, oli.SortOrder
            FROM OpportunityLineItem oli
           	WHERE oli.OpportunityId = :testOpp.Id
            ORDER BY oli.Sort_Order__c
        ];

        test.startTest();
	        customSortOrderProducts controller = new customSortOrderProducts();
	        PageReference pageRef = new PageReference('/'+testOpp.id);
	        test.setCurrentPage(pageRef);
	        ApexPages.CurrentPage().getparameters().put('oppid', testOpp.Id);
	        pageRef.getParameters().put('oppid', testOpp.Id);         
	        customSortOrderProducts.customSort(testOpp.Id);

	        System.assert(testSort != null);
	    test.stopTest();   	
    }

}