@isTest
public class ProjectTriggerAttachmentsTest {

    
    
     static testMethod void ProjectTrigger(){
    	Group__c g = new Group__c(
    			Name = 'Test Group',
        		Group__c = 'G0001');
    	insert g;
         
         Account a = new Account();
       a.Name ='Test Account';
         a.Group_Name__c = g.id;
         insert a;
         
         Project__c p = new Project__c();
       p.Name ='Test Project';
         p.Club_Location__c = a.id;
       insert p;
         
       p.Name = 'Test Project 2';
       update p;

        /* Project_Information__c pi = new Project_Information__c();
        pi.Name ='Test Project';
        pi.Project__c = p.id;
       insert pi;
         
       pi.Name = 'Test Project 2';
       update pi;*/


  }  
    
    
     

}