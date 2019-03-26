public with sharing class PFTermsAndConditionsController {

    public User u {get; set;}
    public Datetime termsAcceptedDateTime {get; set;}
    public Boolean areTermsAccepted {get; set;}

    public List<Knowledge__kav> termsContent {get; private set;}
    String RecordTypeId;
    
    public PFTermsAndConditionsController() { 
        System.debug('*** DEBUG PFTermsAndConditionsController running');

        u = [
            SELECT Are_Terms_and_Conditions_Accepted__c, Date_Time_Terms_and_Conditions_Accepted__c 
            FROM User 
            WHERE id = :UserInfo.getUserId()
        ];        
        System.debug('*** DEBUG u: ' + u);

        termsAcceptedDateTime = u.Date_Time_Terms_and_Conditions_Accepted__c;
        areTermsAccepted = u.Are_Terms_and_Conditions_Accepted__c;

        if (Test.isRunningTest()) {
            RecordTypeId = '012210000004Y93AAE';
        }
        else {
            RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Terms & Conditions').getRecordTypeId();
        }       
        System.debug('*** DEBUG record type ID = ' + RecordTypeId);

        termsContent = [
            SELECT Id, Title, UrlName, Summary, Content__c, LastPublishedDate 
            FROM Knowledge__kav 
            WHERE IsLatestVersion = true 
            AND PublishStatus = 'online' 
            AND RecordTypeID = :RecordTypeId
            AND Language = 'en_US' 
            ORDER BY LastPublishedDate DESC
            LIMIT 1
        ];        
        System.debug('*** DEBUG termsContent: ' + termsContent);
    }
    
    public PageReference updateTermsAcceptance() {
        u.Are_Terms_and_Conditions_Accepted__c = true;
        u.Date_Time_Terms_and_Conditions_Accepted__c = System.Now();
        update u;

        PageReference pageRef = Page.PFHomepage;
        pageRef.setRedirect(true);
        return pageRef;
    } 

}