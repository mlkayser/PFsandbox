trigger PFAgreementTrigger on PFAgreement__c (After Insert, After Update, Before Delete) {
        
    PFAgreementTriggerHandler handler = new PFAgreementTriggerHandler();
    
    System.debug('PFAgreementTriggerHandler.isFirstExecution:::' + PFAgreementTriggerHandler.isFirstExecution);
    if (PFAgreementTriggerHandler.isFirstExecution) {
        PFAgreementTriggerHandler.isFirstExecution = FALSE;
        
        if(Trigger.isUpdate && Trigger.isAfter) {
            handler.createGroupOwner(Trigger.newMap, Trigger.oldMap);
        } else if(Trigger.isInsert && Trigger.isAfter){
            handler.createGroupOwner(Trigger.newMap, NULL);
        }
        
        if (Trigger.isDelete && Trigger.isBefore) {
            handler.deletePFAgreement(trigger.oldMap);
        }
    }

    // update Account field
    PFAgreementUpdateAccount agrAcc = new PFAgreementUpdateAccount();

    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        agrAcc.updateActiveAgrmntCount(Trigger.new);
    }
    else if (Trigger.isDelete) {
        agrAcc.updateActiveAgrmntCount(Trigger.old);
    } 
}