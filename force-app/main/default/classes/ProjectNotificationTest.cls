@isTest
public class ProjectNotificationTest {

	static Account createAccount() {
        Group__c g = new Group__c(
    			Name = 'Test Group',
        		Group__c = 'G0001');
    	insert g;
        
        Account a = new Account(
        		Name='TestAccount',
        		PF_Club_ID__c = '1234',
        		Group_Name__c = g.id);
        insert a;
        return a;
	}

	static Contact createContact(Id accountId) {
    	Contact c = new Contact(
    		firstName = 'First',
    		lastName = 'Last',
    		accountId = accountId,
    		email = 'test@test.com',
    		Project_Step_Notification__c = '01'
        );
    	insert c;
    	return c;
	}

    static OrgWideEmailAddress getOrgEmail() {
         OrgWideEmailAddress fromAddress = [
            SELECT Id 
            FROM OrgWideEmailAddress 
            WHERE Address = 'timeline@pfhq.com' 
            LIMIT 1
        ];      

        return fromAddress;
    }

    static EmailTemplate getEmailTemplate() {
        EmailTemplate template = [
            SELECT id 
            FROM EmailTemplate 
            LIMIT 1
        ];
        return template;
    }

    static testMethod void testStep1_Notification() {
    	Account acc = createAccount();
    	Contact con = createContact(acc.Id);
        OrgWideEmailAddress fromAddress = getOrgEmail();
        EmailTemplate template = getEmailTemplate();
 
    	Project__c project = new Project__c(
    		Name = 'Test',
    		Club_Location__c = acc.Id,
    		x1_FA_Deposit_Status__c = 'In Progress'
        );
    	insert project;

        project.Franchise_Agreement_Status__c = 'FA Signed';
    	update project;	

        Messaging.SingleEmailMessage testMail = ProjectNotification.buildEmail(con.Id, project.Id, template, fromAddress);
        system.assertEquals(testMail.WhatId, project.id);
	}

    static testMethod void testStep11_Notification() {
        Account acc = createAccount();
        Contact con = createContact(acc.Id);
        OrgWideEmailAddress fromAddress = getOrgEmail();
        EmailTemplate template = getEmailTemplate();

        Project__c project = new Project__c(
            Name = 'Test',
            Club_Location__c = acc.Id,
            Pre_Sale_Status__c = 'Not Started'
        );
        insert project;

        project.Pre_Sale_Status__c ='Physical Presale';
        update project;    

        Messaging.SingleEmailMessage testMail = ProjectNotification.buildEmail(con.Id, project.Id, template, fromAddress);
        system.assertEquals(testMail.WhatId, project.id);
    }

    static testMethod void testStep14_Notification() {
    	Account acc = createAccount();
    	Contact con = createContact(acc.Id);
        OrgWideEmailAddress fromAddress = getOrgEmail();
        EmailTemplate template = getEmailTemplate();

    	Project__c project = new Project__c(
    		Name = 'Test',
    		Club_Location__c = acc.Id,
    		x14_Presales_Status__c = 'In Progress',
            Pre_Sale_Status__c = 'Not Started'
        );
    	insert project;

    	project.x14_Presales_Status__c = 'Completed';
        project.Pre_Sale_Status__c  = 'Presale Completed';
    	update project;		

        Messaging.SingleEmailMessage testMail = ProjectNotification.buildEmail(con.Id, project.Id, template, fromAddress);
        system.assertEquals(testMail.WhatId, project.id);
	}
}