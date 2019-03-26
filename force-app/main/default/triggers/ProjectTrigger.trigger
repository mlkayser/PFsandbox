/**
* Trigger to be executed on insert and update of Project__c
*
* @Author:  Magnet 360
* @Updates:
**/
trigger ProjectTrigger on Project__c (before insert, before update, after insert, after update) {

    // Associate Project to Budget based on Open Date
    if (Trigger.isBefore) {
        //Re-enable after migration
        //ProjectTriggerHandler.associateProjectToBudget(trigger.new, trigger.oldMap, trigger.isUpdate);
    }

    if(Trigger.isAfter) {
        // Update Schedule based on Project data
        //ProjectTriggerHandler.updateSchedule(trigger.new, trigger.oldMap, trigger.isUpdate);
        
        // Vendor Notifications
        if (Trigger.isUpdate) {
            ProjectNotification.processVendorNotifications(trigger.newMap, trigger.oldMap);
        }

    }
}