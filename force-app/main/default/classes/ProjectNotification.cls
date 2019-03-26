public class ProjectNotification {

	public projectNotification() {

	}

	public static void processVendorNotifications(Map<Id, Project__c> newMap, Map<Id, Project__c> oldMap) {
		Map<String, List<Project__c>> projectNotificationMap = new Map<String, List<Project__c>>();
		boolean runProjectNotification = false;

		for (Project__c project : newMap.values()) {
			Project__c oldProject = oldMap.get(project.Id);
			System.debug('****DEBUG project Id = ' + project.Id);

			// Step 1 Notification
			if (project.Franchise_Agreement_Status__c == 'FA Signed' 
				&& project.Franchise_Agreement_Status__c != oldProject.Franchise_Agreement_Status__c) {
				
				//Set the notification to run
				runProjectNotification = true;
				if (projectNotificationMap.get('01') != null) {
					projectNotificationMap.get('01').add(project);
				} 
				else {
					List<Project__c> projectList = new List<Project__c>();
					projectList.add(project);
					projectNotificationMap.put('01', projectList);
				}
			} 

			// Step 11 Notification
			if (project.Pre_Sale_Status__c != oldProject.Pre_Sale_Status__c 
				&& oldProject.Pre_Sale_Status__c == 'Not Started' 
				&& (project.Pre_Sale_Status__c == 'Online Presale' || project.Pre_Sale_Status__c =='Physical Presale')){
				
				//Set the notification to run
				runProjectNotification = true;
				if (projectNotificationMap.get('11') != null) {
					projectNotificationMap.get('11').add(project);
				} 
				else {
					List<Project__c> projectList = new List<Project__c>();
					projectList.add(project);
					projectNotificationMap.put('11', projectList);
				}
			}

			// Step 14 Notification
			if (project.Pre_Sale_Status__c  == 'Presale Completed' && 
				project.Pre_Sale_Status__c != oldProject.Pre_Sale_Status__c) {
				
				//Set the notification to run
				runProjectNotification = true;
				if (projectNotificationMap.get('14') != null) {
					projectNotificationMap.get('14').add(project);
				} 
				else {
					List<Project__c> projectList = new List<Project__c>();
					projectList.add(project);
					projectNotificationMap.put('14', projectList);
				}
			}
		}

		// Run the notifications if there are records to process
		if (runProjectNotification) {
			runVendorNotifications(projectNotificationMap);
		}
	}

	public static void runVendorNotifications(Map<String, List<Project__c>> projectNotificationMap) {

		OrgWideEmailAddress fromAddress = [
			SELECT Id 
			FROM OrgWideEmailAddress 
			WHERE Address = 'timeline@pfhq.com' 
			LIMIT 1
		];

		EmailTemplate faSignedTemplate = [
			SELECT id 
			FROM EmailTemplate 
			WHERE developerName = 'Project_Franchise_Agreement_Signed' 
			LIMIT 1
		];

		EmailTemplate clubInPresaleTemplate = [
			SELECT id 
			FROM EmailTemplate 
			WHERE developerName = 'Project_Club_in_Presale' 
			LIMIT 1
		];

		EmailTemplate clubOpenTemplate = [
			SELECT id 
			FROM EmailTemplate 
			WHERE developerName = 'Project_Club_Open' 
			LIMIT 1
		];

		Id VendorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		List<Id> contactIds = new List<Id>();

		for (String key : projectNotificationMap.keySet()) {
			
            if (key == '01') {
				for (Contact c : [SELECT Id FROM Contact WHERE Project_Step_Notification__c INCLUDES ('01') and recordtypeId =: VendorRecordTypeId] ) {
					contactIds.add(c.Id);
				}
				for (Project__c prj : projectNotificationMap.get(key)) {
					for (Id contactId : contactIds) {
						emails.add(buildEmail(contactId, prj.Id, faSignedTemplate, fromAddress));
					}
				}
			}

			if (key == '11') {
				for (Contact c : [SELECT Id FROM Contact WHERE Project_Step_Notification__c INCLUDES ('11') and recordtypeId =: VendorRecordTypeId]) {
					contactIds.add(c.Id);
				}
				for (Project__c prj : projectNotificationMap.get(key)) {
					for (Id contactId : contactIds) {
						emails.add(buildEmail(contactId, prj.Id, clubInPresaleTemplate,fromAddress ));
					}
				}
			}

			if (key == '14') {
				for (Contact c : [SELECT Id FROM Contact WHERE Project_Step_Notification__c INCLUDES ('14') and recordtypeId =: VendorRecordTypeId]) {
					contactIds.add(c.Id);
				}
				for (Project__c prj : projectNotificationMap.get(key)) {
					for (Id contactId : contactIds) {
						emails.add(buildEmail(contactId, prj.Id, clubOpenTemplate, fromAddress));
					}
				}
			}			
		}

        // Do not send emails from unit tests
        if (Test.isRunningTest() == false) {
 			sendEmail(emails);
    	}
	}

	public static Messaging.SingleEmailMessage buildEmail(Id contactId, Id projectId, EmailTemplate template, OrgWideEmailAddress fromAddress) {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(contactId);
        email.setOrgWideEmailAddressId(fromAddress.Id);
        email.setWhatId(projectId);
        email.setTemplateId(template.Id);
        email.setUseSignature(false);
        email.setBccSender(false);
        email.setSaveAsActivity(false);
        return email;
	}

	private static void sendEmail(List<Messaging.SingleEmailMessage> emails) {
		Messaging.sendEmail(emails);
	}
}