trigger accountContactRelationTrigger on AccountContactRelation (After Insert, After Update, After Delete) {
    
    AccountContactRelationHandler acrHandler = new AccountContactRelationHandler();
    
    if(Trigger.isAfter) {
    
        if(Trigger.isInsert) {
            acrHandler.accountShares(Trigger.newMap, NULL);
            if(UserTriggerHandler.isUpdateUserFlag) { acrHandler.updateUser(Trigger.newMap, NULL); }
        }
        if(Trigger.isUpdate) {
            acrHandler.accountShares(Trigger.newMap, Trigger.oldMap);
            if(UserTriggerHandler.isUpdateUserFlag) { acrHandler.updateUser(Trigger.newMap, Trigger.oldMap); }
        }
        if(Trigger.isDelete) {
            acrHandler.accountShares(NULL, Trigger.oldMap);
            if(UserTriggerHandler.isUpdateUserFlag) { acrHandler.updateUser(NULL, Trigger.oldMap); }
        }
    }
}