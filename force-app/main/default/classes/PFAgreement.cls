/**
 * Created by ephillips on 4/20/18.
 */

global without sharing class PFAgreement {
    global static List<Id> getAgreementsForResponsibleOwner(Id contactId, Id recordTypeId) {
        List<Id> results = new List<Id>();
        List<PFAgreement__c> agreements = [SELECT Club_Name__c FROM PFAgreement__c where Responsible_Owner__c=:contactId and RecordTypeId=:recordTypeId];
        for(PFAgreement__c a : agreements) {
            results.add(a.Club_Name__c);
        }
        return results;
    }
}