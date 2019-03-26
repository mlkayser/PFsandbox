@isTest
public class ContactRolesListControllerTest {
	
    @isTest
    static void testgetMyContacts() {
       
       Test.startTest();
       // Create two contacts
           Contact ct1 = new Contact();
           Contact ct2 = new Contact();
           ct1.FirstName = 'Larrys';
           ct1.LastName = 'Page';
        ct1.Email = 'test@test.com';
        ct1.Phone = '1-800-123-1234';
        
           ct2.FirstName = 'Marc';
           ct2.LastName = 'Buymeoff';
        ct2.Email = 'test2@test.com';
        ct2.Phone = '1-800-123-1234';
            
           Insert ct1;    
           Insert ct2;
           system.debug('Completed Contact Creation'); 
           
     
        // Create Opportunity
          Opportunity op1 = new Opportunity();
          op1.name = 'Opportunity Contact Insertion Test';
          op1.CloseDate =  Date.today()+2;
          op1.StageName = 'Prospecting';
          //insert op1;
          Database.SaveResult sr1 = Database.insert(op1, true);
          System.assert(sr1.isSuccess());
          system.debug('Inserted new opportunity');
          
       // Update Opportunity with new contact
          //update op1;
          Database.SaveResult sr2 = Database.update(op1, true);
          System.assert(sr2.isSuccess());
          system.debug('Opportunity updated');
          
        
        ContactRolesListController o_controller = new ContactRolesListController( new ApexPages.StandardController( op1 ) );
        
     apexpages.currentpage().getparameters().put('id' , op1.id);
	ContactRolesListController controller = new ContactRolesListController() ;
        
          Test.stopTest();
          System.assert(sr2.isSuccess());
        
    }
}