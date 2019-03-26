@isTest
public class SitesAttachmentsControllerTest {

    @testSetup static void setUpMethod()
    {
        PFTestUtility.initCustomSetting();
    }
    
    @isTest
    static void testsites()
    {
        Group__c g = new Group__c(
    			Name = 'Test Group',
        		Group__c = 'G0001');
    	insert g;
        
        Account acc = new Account();
        acc.Name='Acme Inc';   
        acc.Group_Name__c = g.id;
        insert acc;
            
        Project__c prj = new Project__c();
        prj.Name='Acme Inc'; 
        prj.Club_Location__c = acc.id;
        insert prj;
        
        Sites__c ste = new Sites__c();
        ste.Name='Acme Inc';   
        ste.Project__c = prj.id;      
        insert ste;
        
Test.startTest();
            SitesAttachmentsController l_controller_open_club = new SitesAttachmentsController( new ApexPages.StandardController( ste ) );
            List<Sites__c> l_sites_att = l_controller_open_club.getallatt();



		     
        Test.stopTest();
    }
    
}