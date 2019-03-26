public class SitesAttachmentsController {
    public string thesite {get;set;}
    
    Sites__c mySite;
    
  	List<Sites__c> relatedAttachments;
    
	private final ApexPages.StandardController controller;
    
  	public SitesAttachmentsController(ApexPages.StandardController controller){
		this.controller = controller;
		mySite = (Sites__c)controller.getRecord();
        thesite = mySite.id;
		//relatedAttachments = [select Id, Name from Case where WhateverYourLookupFieldIs = :mySite.Id];
        relatedAttachments = [Select o.Name, o.Id, (Select Id, IsNote, Title From NotesAndAttachments) From Sites__c o where o.id=:mySite.id limit 1];         
        //relatedAttachments = oo.NotesAndAttachments; 
   }
    
    
    public List<Sites__c> getallatt() {
        List<Sites__c> allatt;
        if(allatt == null) {
           allatt = [Select o.Name, o.Id, (Select Id, Title, CreatedDate From NotesAndAttachments) From Sites__c o where o.id=:mySite.id limit 1];
        }
        return allatt;
    }
    
    public void Save() {

    }
    
    
    
    
}