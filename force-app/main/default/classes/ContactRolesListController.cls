public class ContactRolesListController {
	Public String myID{get;set;}
    public Id oppId {get;set;}
	
   
    private final Opportunity opp;

    public ContactRolesListController(ApexPages.StandardController Controller) {
       oppId = controller.getRecord().Id; 
    }

    
    public ContactRolesListController(){
    	myID = ApexPages.currentPage().getParameters().get('id');  
	}
 
	public List<opportunitycontactrole> getMyContacts() {  
     	List<opportunitycontactrole> mycontacts = new List<opportunitycontactrole>(); 
     	mycontacts = [SELECT Contact.Name, Contact.ID, Contact.Email, Contact.NDA_Effective_Date__c, Role, Contact.Phone, isPrimary FROM opportunitycontactrole WHERE opportunityid = :oppId]; 
        for(opportunitycontactrole o : mycontacts){
            
        }
       return mycontacts;   
	}    
    
}