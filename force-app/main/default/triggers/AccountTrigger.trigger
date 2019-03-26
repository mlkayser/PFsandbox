trigger AccountTrigger on Account (After Insert, After Update) {
    
    AccountTriggerHandler accountHandler = new AccountTriggerHandler();
    
    if(Trigger.isInsert && Trigger.isAfter) {
        accountHandler.afterInsert(Trigger.new);
    }

    // 03/07/2018 - AVS:RD -> if Account's Group_Name__c changes, query through the Account's Related Contacts and
    // remove all relationships where Contacts' found Groups are not related to the new value.
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('!!!!!running AccountTrigger!!!!!');
        accountHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }
}