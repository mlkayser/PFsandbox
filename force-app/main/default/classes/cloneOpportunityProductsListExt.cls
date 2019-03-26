public with sharing class cloneOpportunityProductsListExt {

    public String thisOppId = ApexPages.currentPage().getParameters().get('id');
    public Opportunity thisOpp {get;set;}
    public String oppWithProdsName {get;set;}
    public Opportunity oppWithProds;

    public cloneOpportunityProductsListExt(ApexPages.StandardController stdController) {
        // load current record
        thisOpp = [SELECT Id, Name, Pricebook2Id, CurrencyIsoCode, Total_Number_of_Products__c 
                FROM Opportunity 
                WHERE Id = :thisOppId];
    }

    public PageReference addProducts() {
        // get Opportunity with products
        if (String.isNotBlank(oppWithProdsName)) {
            oppWithProds = [SELECT Id, Name, Pricebook2Id, CurrencyIsoCode 
                            FROM Opportunity 
                            WHERE Name = :oppWithProdsName];
            System.debug(oppWithProds.Id + ' --- ' + oppWithProds.Name );

        } else {
            return null;
        }

        // add Pricebook to Opportunity to update
        if (thisOpp.Pricebook2Id != null) {
            thisOpp.Pricebook2Id = oppWithProds.Pricebook2Id;
            thisOpp.CurrencyIsoCode = oppWithProds.CurrencyIsoCode;
            update thisOpp;    
        }

        // reload updated Opportunity
        thisOpp = [SELECT Id, Name, Pricebook2Id, CurrencyIsoCode  
                    FROM Opportunity 
                    WHERE Id = :thisOppId];

        // find all Opportunity Products associated with existing opportunity
        List<OpportunityLineItem> oppLineItems = [
            SELECT id, name, Product2Id, Quantity, SortOrder 
            FROM OpportunityLineItem
            WHERE OpportunityId = :oppWithProds.Id
        ];
        System.debug(oppLineItems.size());

        // create a list of new Opportunity Products to associate with Opportunity to update
        List<OpportunityLineItem> newOppLineItems = new List<OpportunityLineItem>();
        for (OpportunityLineItem oppLI : oppLineItems) {
           OpportunityLineItem newOppLineItem = new OpportunityLineItem();

           newOppLineItem.OpportunityId = thisOpp.Id;
           newOppLineItem.Quantity = oppLI.Quantity;
           newOppLineItem.Sort_Order__c = oppLI.SortOrder; // copy sort order to custom sort order field

            PriceBookEntry pbookEntry = [SELECT Id                                
                                        FROM PriceBookEntry 
                                        WHERE Product2Id = :oppLI.Product2Id 
                                        AND Pricebook2Id = :oppWithProds.Pricebook2Id 
                                        AND CurrencyIsoCode = :oppWithProds.CurrencyIsoCode
                                        LIMIT 1];
           newOppLineItem.PricebookEntryId = pbookEntry.Id;

           System.debug(newOppLineItem.OpportunityId);    
           System.debug(newOppLineItem.Product2Id);     
           System.debug(newOppLineItem.Quantity);     

           newOppLineItems.add(newOppLineItem);   
        }

        try {
            // update opportunity
            insert newOppLineItems;   

            // Send the user back to record page 
            //PageReference oppPage = new PageReference('/' + thisOppId);
            //PageReference oppPage = new PageReference(ApexPages.currentPage().getUrl());
            PageReference oppPage = new PageReference('/apex/cloneOpportunityProductList?scontrolCaching=1&id=' + thisOppId);
            oppPage.setRedirect(true);
            return oppPage;
        } catch(exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }       
    }

    public PageReference close() {
        //PageReference returnPage = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        PageReference returnPage = new PageReference('/' + thisOppId);
        return returnPage;
    }

}