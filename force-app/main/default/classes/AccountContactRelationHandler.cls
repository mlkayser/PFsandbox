public without sharing class AccountContactRelationHandler {
    
    public void accountShares(Map<Id,AccountContactRelation> newACRs, Map<Id,AccountContactRelation> oldACRs) {
        
        Boolean isInsert = FALSE;
        Boolean isUpdate = FALSE;
        Boolean isDelete = FALSE;
        List<AccountShare> createAccShares = new List<AccountShare>();
        Set<Id> conIds = new Set<Id>();
        
        if(newACRs == NULL || newACRs.size() == 0) isDelete = TRUE;
        if(newACRs != NULL && oldACRs != NULL && newACRs.size() > 0 && oldACRs.size() > 0) isUpdate = TRUE;
        if(oldACRs == NULL || oldACRs.size() == 0) isInsert = TRUE;
        
        List<AccountContactRelation> acrs = new List<AccountContactRelation>();
        
        if(isInsert || isUpdate) {
            acrs = newACRs.values();
        } else if(isDelete) {
            acrs = oldACRs.values();
        }
        
        for(AccountContactRelation acr : acrs) {
            conIds.add(acr.ContactId);
        }
        
        Map<Id,User> userMap = new Map<Id, User>([SELECT Id,ContactId,isActive FROM User WHERE ContactId IN :conIds]);
        Map<Id, User> conIdUserMap = new Map<Id, User>();
        Set<Id> delAccShareUserIds = new Set<Id>();
        Set<Id> delAccShareAccIds = new Set<Id>();
        PFAgreementTriggerHandler handler = new PFAgreementTriggerHandler();
        
        for(User usr : userMap.values()) {
            conIdUserMap.put(usr.ContactId, usr);
        }
        
        if(isInsert || isUpdate) {
            
            for(AccountContactRelation acr : newACRs.values()) {
                
                AccountContactRelation oldACR = isUpdate ? oldACRs.get(acr.Id) : NULL;
                
                if(acr.isShared__c && (isInsert || (isUpdate && oldACR.isShared__c != acr.isShared__c))) {
                    
                    if(conIdUserMap.get(acr.ContactId) != NULL && conIdUserMap.get(acr.ContactId).isActive) {
                        AccountShare accShare = handler.createAccountShare(acr.AccountId, conIdUserMap.get(acr.ContactId).Id);
                        if(accShare != NULL) createAccShares.add(accShare);
                    }
                    
                } else if(isUpdate && (oldACR.isShared__c != acr.isShared__c)) {
                    if(conIdUserMap.get(acr.ContactId) != NULL) delAccShareUserIds.add(conIdUserMap.get(acr.ContactId).Id);
                    delAccShareAccIds.add(acr.AccountId);
                }
            }
        }
        
        if(isDelete) {
            for(AccountContactRelation acr : oldACRs.values()) {
                
                if(conIdUserMap.get(acr.ContactId) != NULL) delAccShareUserIds.add(conIdUserMap.get(acr.ContactId).Id);
                delAccShareAccIds.add(acr.AccountId);
            }
        }
        
        if(delAccShareAccIds.size() > 0 && delAccShareUserIds.size() > 0) {
            delete [SELECT Id FROM AccountShare WHERE AccountId IN :delAccShareAccIds AND UserOrGroupId IN :delAccShareUserIds];
        }
        
        if(createAccShares.size() > 0) insert createAccShares;
         
    }
    
    public void updateUser(Map<Id,AccountContactRelation> newACRs, Map<Id,AccountContactRelation> oldACRs) {
        
        Boolean isInsert = FALSE;
        Boolean isUpdate = FALSE;
        Boolean isDelete = FALSE;
        Set<Id> comUserConIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Map<Id, User> conIdAndUserMap = new Map<Id, User>();
        Map<Id, Account> accountsMap = new Map<Id, Account>();
        
        if(newACRs == NULL || newACRs.size() == 0) isDelete = TRUE;
        if(newACRs != NULL && oldACRs != NULL && newACRs.size() > 0 && oldACRs.size() > 0) isUpdate = TRUE;
        if(oldACRs == NULL || oldACRs.size() == 0) isInsert = TRUE;
        
        System.debug('isInsert:::' + isInsert + '\nisUpdate:::' + isUpdate + '\nisDelete:::' + isDelete);
        
        if(isInsert || isUpdate) {
            
            for(AccountContactRelation acr : newACRs.values()) {
                comUserConIds.add(acr.ContactId);
                accIds.add(acr.AccountId);
            }
        }
        
        if(isDelete) {
            
            for(AccountContactRelation acr : oldACRs.values()) {
                comUserConIds.add(acr.ContactId);
                accIds.add(acr.AccountId);
            }
        }
        
        System.debug('comUserConIds:::' + comUserConIds + '\ncomUserConIds size:::' + comUserConIds.size());
        System.debug('accIds:::' + accIds + '\naccIds size:::' + accIds.size());
        
        accountsMap = new Map<Id, Account>([SELECT Id,PF_Club_Id__c FROM Account WHERE Id IN :accIds AND RecordType.DeveloperName = 'Club_Location']);
        
        for(User usr : [SELECT Id,Club_Access__c,ContactId FROM User WHERE ContactId IN :comUserConIds]) {
            conIdAndUserMap.put(usr.ContactId, usr);
        }
        
        System.debug('accountsMap:::' + accountsMap + '\naccountsMap size:::' + accountsMap.size());
        System.debug('conIdAndUserMap:::' + conIdAndUserMap + '\nconIdAndUserMap size:::' + conIdAndUserMap.size());
        
        if(isInsert || isUpdate) {
            for(Id acrId : newACRs.keySet()) {
                
                AccountContactRelation newACR = newACRs.get(acrId);
                AccountContactRelation oldACR = (isUpdate ? oldACRs.get(acrId) : NULL);
                
                System.debug('newACR:::' + newACR + '\noldACR:::' + oldACR);
                
                if(conIdAndUserMap.containsKey(newACR.ContactId) && accountsMap.containsKey(newACR.AccountId)) {
                    
                    Account acc = accountsMap.get(newACR.AccountId);
                    User usr = conIdAndUserMap.get(newACR.ContactId);
                    
                    System.debug('acc:::' + acc + '\nusr:::' + usr);
                    
                    if(isInsert && newACR.isShared__c) {
                        usr.Club_Access__c = generateClubAccess(usr.Club_Access__c, acc.PF_Club_Id__c, 'ADD');
                    }
                    
                    if(isUpdate && newACR.isShared__c != oldACR.isShared__c) {
                        if(newACR.isShared__c) {
                            usr.Club_Access__c = generateClubAccess(usr.Club_Access__c, acc.PF_Club_Id__c, 'ADD');
                        } else {
                            usr.Club_Access__c = generateClubAccess(usr.Club_Access__c, acc.PF_Club_Id__c, 'REMOVE');
                        }
                    }
                }
            }
        } 
        
        if(isDelete) {
            
            for(AccountContactRelation oldACR : oldACRs.values()) {
                
                if(conIdAndUserMap.containsKey(oldACR.ContactId) && accountsMap.containsKey(oldACR.AccountId)) {
                    Account acc = accountsMap.get(oldACR.AccountId);
                    User usr = conIdAndUserMap.get(oldACR.ContactId);
                    
                    usr.Club_Access__c = generateClubAccess(usr.Club_Access__c, acc.PF_Club_Id__c, 'REMOVE');
                }
            }
        }  
        System.debug(':::conIdAndUserMap:::' + conIdAndUserMap);
        if(conIdAndUserMap.size() > 0) update conIdAndUserMap.values();      
    }
    
    public string generateClubAccess(String clubAccessValue, String pfClubId, String operation) {
        
        System.debug('clubAccessValue:::' + clubAccessValue + '\n:::' + pfClubId + '\n:::' + operation);
        
        String mergeStr = '';
        if(String.isNotBlank(clubAccessValue) && String.isNotBlank(pfClubId)) {
            Set<String> clubAccess = new Set<String>(clubAccessValue.split(';'));
            
            if(operation == 'REMOVE') {
                clubAccess.remove(pfClubId);
            } else if(operation == 'ADD') {
                clubAccess.add(pfClubId);
            }
            
            for(String str : clubAccess) {
                if(mergeStr == '') {
                    mergeStr = str;
                } else {
                    mergeStr += ';' + str;
                }
            }
        } else if(String.isBlank(clubAccessValue) && String.isNotBlank(pfClubId) && operation == 'ADD') {
            mergeStr = pfClubId;
        }
        return mergeStr;
    }
}