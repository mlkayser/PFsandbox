trigger siteTrigger on Sites__c (after Insert, after Update) {
    
    SiteTriggerHandler handler = new SiteTriggerHandler();
    
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            handler.createSitesSharing(Trigger.new, NULL);
        } 
        
        if(trigger.isUpdate) {
            handler.createSitesSharing(Trigger.new, Trigger.oldMap);
        }
    }
}