public class PFAgreementTriggerHandler {
    
    public static Boolean isFirstExecution = TRUE;
    Set<String> avoidDupAccShare = new Set<String>();
    Set<String> notDelAccShares = new Set<String>();
    List<AccountShare> delAccountShares = new List<AccountShare>();
    List<AccountShare> creareShares = new List<AccountShare>();
    
    public void createGroupOwner(Map<Id,PFAgreement__c> newPFAgrmnt, Map<Id,PFAgreement__c> oldPFAgrmnt) {
        
        System.debug(':::newPFAgrmnt:::' + newPFAgrmnt + '\n:::oldPFAgrmnt:::' + oldPFAgrmnt);
        
        Set<Id> contactIdsForUserQry = new Set<Id>();        
        Set<Id> newGroupOwnerIds = new Set<Id>();
        Set<Id> newGroupIds = new Set<Id>();
        Set<Id> createAccSharePFIds = new Set<Id>();
        Set<Id> deleteAccSharePFIds = new Set<Id>();
        Set<Id> accIdForFAs = new Set<Id>();
        Set<Id> delAccIdForFAs = new Set<Id>();
        Set<String> existGOKeys = new Set<String>();
        Set<Id> RespOwnerAndAppOperIds = new Set<Id>();
        Set<Id> notRemoveClubAccessFA = new Set<Id>();
        Set<String> closedStatus = new Set<String> { 'Expired', 'Terminated' };
        Set<Id> pfIdsForADA = new Set<Id>();
        
        Map<Id, PFAgreement__c> createPFAMap = new Map<Id, PFAgreement__c>();
        Map<Id, PFAgreement__c> deletePFAMap = new Map<Id, PFAgreement__c>();
        Map<Id, List<Group_Owner__c>> conIdAndGroupOwnersMap = new Map<Id, List<Group_Owner__c>>();
        Map<Id, List<Group_Owner__c>> groupIdAndGOMap = new Map<Id, List<Group_Owner__c>>();
        Map<Id, User> conIdAndUserMap = new Map<Id, User>();
        Map<Id, Id> usrIdAndConIdMap = new Map<Id, Id>();
        Map<Id, RecordType> recTypeMap = new Map<Id, RecordType>([SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'PFAgreement__c']);
        
        List<Group_Owner__c> createGOList = new List<Group_Owner__c>();
        List<Group_Owner__c> deleteGOList = new List<Group_Owner__c>();
        List<Group_Owner__c> createFinalGOList = new List<Group_Owner__c>();
        List<AccountShare> deleteShares = new List<AccountShare>();
        
        System.debug(':::recTypeMap::' + recTypeMap);
        
        if(newPFAgrmnt != null && newPFAgrmnt.size() > 0) {
        
            Boolean isUpdate = FALSE;
            
            if(oldPFAgrmnt != null && oldPFAgrmnt.size() > 0) {
                isUpdate = TRUE;
            }    
            System.debug(':::isUpdate:::' + isUpdate);
 
            for(PFAgreement__c pfAgrmnt : newPFAgrmnt.values()) {
            
                PFAgreement__c oldPFA = (isUpdate == TRUE) ? oldPFAgrmnt.get(pfAgrmnt.Id) : NULL;
                Set<Id> tempNotDetIds = new Set<Id>();
                Boolean isFranchisee = (recTypeMap.get(pfAgrmnt.RecordTypeId) != NULL && recTypeMap.get(pfAgrmnt.RecordTypeId).DeveloperName == 'Franchise_Agreement' && !pfAgrmnt.Reset_Franchisee_Security__c) ? TRUE : FALSE;
                
                System.debug(':::isFranchisee:::' + isFranchisee);
                
                if(!closedStatus.contains(pfAgrmnt.ADA_Status__c) || isFranchisee) {
                    if(String.IsNotBlank(pfAgrmnt.Delegated_Administrator_1__c)) {
                        tempNotDetIds.add(pfAgrmnt.Delegated_Administrator_1__c);
                    }
                    
                    if(String.IsNotBlank(pfAgrmnt.Delegated_Administrator_2__c)) {
                        tempNotDetIds.add(pfAgrmnt.Delegated_Administrator_2__c);
                    }
                    
                    if(String.IsNotBlank(pfAgrmnt.Responsible_Owner__c)) {
                        RespOwnerAndAppOperIds.add(pfAgrmnt.Responsible_Owner__c);
                        tempNotDetIds.add(pfAgrmnt.Responsible_Owner__c);
                    }
                    
                    if(String.IsNotBlank(pfAgrmnt.Approved_Operator__c)) {
                        RespOwnerAndAppOperIds.add(pfAgrmnt.Approved_Operator__c);
                        tempNotDetIds.add(pfAgrmnt.Approved_Operator__c);
                    }
                
                    if(isUpdate && pfAgrmnt.Delegated_Administrator_1__c != oldPFA.Delegated_Administrator_1__c) {
                        if(String.IsBlank(oldPFA.Delegated_Administrator_1__c) && String.IsNotBlank(pfAgrmnt.Delegated_Administrator_1__c)) {
                            createPFAMap.put(pfAgrmnt.Delegated_Administrator_1__c, pfAgrmnt);
                            contactIdsForUserQry.add(pfAgrmnt.Delegated_Administrator_1__c);
                            createAccSharePFIds.add(pfAgrmnt.Id);
                            
                        } else if(String.IsBlank(pfAgrmnt.Delegated_Administrator_1__c) && String.IsNotBlank(oldPFA.Delegated_Administrator_1__c)) {
                            deletePFAMap.put(oldPFA.Delegated_Administrator_1__c, pfAgrmnt);
                            if(!tempNotDetIds.contains(oldPFA.Delegated_Administrator_1__c)) {
                                contactIdsForUserQry.add(oldPFA.Delegated_Administrator_1__c);                                
                                deleteAccSharePFIds.add(oldPFA.Id); 
                            } 
                                                
                        } else if(String.IsNotBlank(pfAgrmnt.Delegated_Administrator_1__c)) {
                            createPFAMap.put(pfAgrmnt.Delegated_Administrator_1__c, pfAgrmnt);
                            deletePFAMap.put(oldPFA.Delegated_Administrator_1__c, pfAgrmnt);
                            contactIdsForUserQry.add(pfAgrmnt.Delegated_Administrator_1__c);
                            createAccSharePFIds.add(pfAgrmnt.Id);
                            if(!tempNotDetIds.contains(oldPFA.Delegated_Administrator_1__c)) {
                                contactIdsForUserQry.add(oldPFA.Delegated_Administrator_1__c);
                                deleteAccSharePFIds.add(oldPFA.Id);
                            }
                        }
                    } else if(!isUpdate && String.IsNotBlank(pfAgrmnt.Delegated_Administrator_1__c)) {
                    
                        createPFAMap.put(pfAgrmnt.Delegated_Administrator_1__c, pfAgrmnt);
                        contactIdsForUserQry.add(pfAgrmnt.Delegated_Administrator_1__c);
                        createAccSharePFIds.add(pfAgrmnt.Id);
                    }               
                    
                    if(isUpdate && pfAgrmnt.Delegated_Administrator_2__c != oldPFA.Delegated_Administrator_2__c) {
                        if(String.IsBlank(oldPFA.Delegated_Administrator_2__c) && String.IsNotBlank(pfAgrmnt.Delegated_Administrator_2__c)) {
                            createPFAMap.put(pfAgrmnt.Delegated_Administrator_2__c, pfAgrmnt);
                            contactIdsForUserQry.add(pfAgrmnt.Delegated_Administrator_2__c);
                            createAccSharePFIds.add(pfAgrmnt.Id);
                            
                        } else if(String.IsBlank(pfAgrmnt.Delegated_Administrator_2__c) && String.IsNotBlank(oldPFA.Delegated_Administrator_2__c)) {
                            deletePFAMap.put(oldPFA.Delegated_Administrator_2__c, pfAgrmnt);
                            if(!tempNotDetIds.contains(oldPFA.Delegated_Administrator_2__c)) {
                                contactIdsForUserQry.add(oldPFA.Delegated_Administrator_2__c);
                                deleteAccSharePFIds.add(oldPFA.Id);
                            }
                        } else if(String.IsNotBlank(pfAgrmnt.Delegated_Administrator_2__c)){
                            createPFAMap.put(pfAgrmnt.Delegated_Administrator_2__c, pfAgrmnt);
                            deletePFAMap.put(oldPFA.Delegated_Administrator_2__c, pfAgrmnt);
                            
                            contactIdsForUserQry.add(pfAgrmnt.Delegated_Administrator_2__c);
                            createAccSharePFIds.add(pfAgrmnt.Id);
                            if(!tempNotDetIds.contains(oldPFA.Delegated_Administrator_2__c)) {
                                contactIdsForUserQry.add(oldPFA.Delegated_Administrator_2__c);
                                deleteAccSharePFIds.add(oldPFA.Id);
                            }
                        }
                    } else if(!isUpdate && String.IsNotBlank(pfAgrmnt.Delegated_Administrator_2__c)) {
                        createPFAMap.put(pfAgrmnt.Delegated_Administrator_2__c, pfAgrmnt);
                        contactIdsForUserQry.add(pfAgrmnt.Delegated_Administrator_2__c);
                        createAccSharePFIds.add(pfAgrmnt.Id);
                    }
                    
                    if(isUpdate && pfAgrmnt.Responsible_Owner__c != oldPFA.Responsible_Owner__c) {
                        if(String.IsBlank(oldPFA.Responsible_Owner__c) && String.IsNotBlank(pfAgrmnt.Responsible_Owner__c)) {
                            createPFAMap.put(pfAgrmnt.Responsible_Owner__c, pfAgrmnt);
                            contactIdsForUserQry.add(pfAgrmnt.Responsible_Owner__c);
                            createAccSharePFIds.add(pfAgrmnt.Id);
                            
                        } else if(String.IsBlank(pfAgrmnt.Responsible_Owner__c) && String.IsNotBlank(oldPFA.Responsible_Owner__c)) {
                            deletePFAMap.put(oldPFA.Responsible_Owner__c, pfAgrmnt);
                            if(!tempNotDetIds.contains(oldPFA.Responsible_Owner__c)) {
                                contactIdsForUserQry.add(oldPFA.Responsible_Owner__c);
                                deleteAccSharePFIds.add(oldPFA.Id);
                            }
                        } else if(String.IsNotBlank(pfAgrmnt.Responsible_Owner__c)){
                            createPFAMap.put(pfAgrmnt.Responsible_Owner__c, pfAgrmnt);
                            deletePFAMap.put(oldPFA.Responsible_Owner__c, pfAgrmnt);
                            
                            contactIdsForUserQry.add(pfAgrmnt.Responsible_Owner__c);
                            createAccSharePFIds.add(pfAgrmnt.Id);
                            if(!tempNotDetIds.contains(oldPFA.Responsible_Owner__c)) {
                                contactIdsForUserQry.add(oldPFA.Responsible_Owner__c);
                                deleteAccSharePFIds.add(oldPFA.Id);
                            }
                        }
                    } else if(!isUpdate && String.IsNotBlank(pfAgrmnt.Responsible_Owner__c)) {
                        createPFAMap.put(pfAgrmnt.Responsible_Owner__c, pfAgrmnt);
                        contactIdsForUserQry.add(pfAgrmnt.Responsible_Owner__c);
                        createAccSharePFIds.add(pfAgrmnt.Id);
                    }
                    
                    if(isUpdate && pfAgrmnt.Approved_Operator__c != oldPFA.Approved_Operator__c) {
                        if(String.IsBlank(oldPFA.Approved_Operator__c) && String.IsNotBlank(pfAgrmnt.Approved_Operator__c)) {
                            createPFAMap.put(pfAgrmnt.Approved_Operator__c, pfAgrmnt);
                            contactIdsForUserQry.add(pfAgrmnt.Approved_Operator__c);
                            createAccSharePFIds.add(pfAgrmnt.Id);
                            
                        } else if(String.IsBlank(pfAgrmnt.Approved_Operator__c) && String.IsNotBlank(oldPFA.Approved_Operator__c)) {
                            deletePFAMap.put(oldPFA.Approved_Operator__c, pfAgrmnt);
                            if(!tempNotDetIds.contains(oldPFA.Approved_Operator__c)) {
                                contactIdsForUserQry.add(oldPFA.Approved_Operator__c);
                                deleteAccSharePFIds.add(oldPFA.Id);
                            }
                        } else if(String.IsNotBlank(pfAgrmnt.Approved_Operator__c)){
                            createPFAMap.put(pfAgrmnt.Approved_Operator__c, pfAgrmnt);
                            deletePFAMap.put(oldPFA.Approved_Operator__c, pfAgrmnt);
                            
                            contactIdsForUserQry.add(pfAgrmnt.Approved_Operator__c);
                            createAccSharePFIds.add(pfAgrmnt.Id);
                            if(!tempNotDetIds.contains(oldPFA.Approved_Operator__c)) {
                                contactIdsForUserQry.add(oldPFA.Approved_Operator__c);
                                deleteAccSharePFIds.add(oldPFA.Id);
                            }
                        }
                    } else if(!isUpdate && String.IsNotBlank(pfAgrmnt.Approved_Operator__c)) {
                        createPFAMap.put(pfAgrmnt.Approved_Operator__c, pfAgrmnt);
                        contactIdsForUserQry.add(pfAgrmnt.Approved_Operator__c);
                        createAccSharePFIds.add(pfAgrmnt.Id);
                    }
                }
                
                if(isUpdate && pfAgrmnt.ADA_Status__c != oldPFA.ADA_Status__c) {
                    if(recTypeMap.containsKey(pfAgrmnt.RecordTypeId) && recTypeMap.get(pfAgrmnt.RecordTypeId).DeveloperName == 'Area_Development_Agreement') {
                        if(!closedStatus.contains(oldPFA.ADA_Status__c) && closedStatus.contains(pfAgrmnt.ADA_Status__c)) {
                            pfIdsForADA.add(pfAgrmnt.Id);
                        } 
                    }
                }
                
                if(recTypeMap.containsKey(pfAgrmnt.RecordTypeId) && recTypeMap.get(pfAgrmnt.RecordTypeId).DeveloperName == 'Franchise_Agreement') {
                    if(isUpdate && pfAgrmnt.Reset_Franchisee_Security__c != oldPFA.Reset_Franchisee_Security__c) {
                        if(pfAgrmnt.Reset_Franchisee_Security__c) {
                            deleteAccSharePFIds.add(pfAgrmnt.Id);
                            delAccIdForFAs.add(pfAgrmnt.Club_Name__c);
                        } else {
                            createAccSharePFIds.add(pfAgrmnt.Id);
                            accIdForFAs.add(pfAgrmnt.Club_Name__c);
                        }
                    }
                }
            }
            
            Set<Id> accIds = new Set<Id>();
            Set<Id> conIds = new Set<Id>();
            Set<Id> usrIds = new Set<Id>();
            Map<Id, Set<Id>> grpIdAndClubIdsMap = new Map<Id, Set<Id>>();
            Set<Id> revokeACRAccIds = new Set<Id>();
            Set<Id> revokeACRConIds = new Set<Id>();
            Set<Id> accIdForRevoke = new Set<Id>();
            Set<Id> conIdForRevoke = new Set<Id>();
            Set<Id> usrIdForRevoke = new Set<Id>();
            
            System.debug(':::pfIdsForADA:::' + pfIdsForADA + '\n:::' + pfIdsForADA.size());
            
            if(accIdForFAs.size() > 0 || delAccIdForFAs.size() > 0) {
                
                Set<Id> groupIdsForCreate = new Set<Id>();
                Set<Id> groupIdsForDelete = new Set<Id>();
                
                for(Account acc : [SELECT Id,Group_Name__c FROM Account WHERE (Id IN :accIdForFAs OR Id IN :delAccIdForFAs) AND Group_Name__c <> NULL]) {
                    if(groupIdsForCreate.contains(acc.Id)) {
                        groupIdsForCreate.add(acc.Group_Name__c);
                    } else {
                        groupIdsForDelete.add(acc.Group_Name__c);
                    }
                }
                
                if(groupIdsForCreate.size() > 0 || groupIdsForDelete.size() > 0) {
                    for(Group_Owner__c grpOwner : [SELECT Id,Name,Owner_Contact__c,Group_Num__c FROM Group_Owner__c WHERE Group_Num__c IN :groupIdsForCreate OR Group_Num__c IN :groupIdsForDelete]) {
                        if(groupIdsForCreate.contains(grpOwner.Group_Num__c)) {
                            contactIdsForUserQry.add(grpOwner.Owner_Contact__c);
                        } else {
                            contactIdsForUserQry.add(grpOwner.Owner_Contact__c);
                        }    
                    }
                }
            }
            
            if(pfIdsForADA.size() > 0) {
                
                List<PFAgreement__c> pfaList = [SELECT Id,Name,RecordType.DeveloperName,Club_Name__c,Club_Name__r.Group_Name__c,
                                                   (SELECT Id,Name,Status__c,Group_Name__c FROM Accounts__r) 
                                               FROM PFAgreement__c WHERE Id IN :pfIdsForADA];
                
                Map<Id, Set<Id>> groupIdAndAccIdsMap = new Map<Id, Set<Id>>();
                
                for(PFAgreement__c pfa : pfaList) {     
                    system.debug('::::pfa.RecordType.DeveloperName:::'+pfa.RecordType.DeveloperName);
                    if(pfa.RecordType.DeveloperName == 'Franchise_Agreement') {
                        if(String.isNotBlank(pfa.Club_Name__r.Group_Name__c)) {
                            if(groupIdAndAccIdsMap.get(pfa.Club_Name__r.Group_Name__c) == NULL) 
                                groupIdAndAccIdsMap.put(pfa.Club_Name__r.Group_Name__c, new Set<Id>());
                            groupIdAndAccIdsMap.get(pfa.Club_Name__r.Group_Name__c).add(pfa.Club_Name__c);
                        }
                    } else if(pfa.RecordType.DeveloperName == 'Area_Development_Agreement') {
                    
                        for(Account acc : pfa.Accounts__r) {
                            accIds.add(acc.Id);
                            if(!groupIdAndAccIdsMap.containsKey(acc.Group_Name__c))
                                groupIdAndAccIdsMap.put(acc.Group_Name__c, new Set<Id>());
                            groupIdAndAccIdsMap.get(acc.Group_Name__c).add(acc.Id);
                        }
                    }
                }
                
                if(groupIdAndAccIdsMap.size() > 0) {
                    for(Group__c grp : [SELECT Id,Name,(SELECT Id,Name,Owner_Contact__c FROM Group_Owners__r) FROM Group__c 
                                           WHERE Id IN :groupIdAndAccIdsMap.keySet()]) {
                        for(Group_Owner__c grpOwner : grp.Group_Owners__r) {
                            conIdForRevoke.add(grpOwner.Owner_Contact__c);
                            contactIdsForUserQry.add(grpOwner.Owner_Contact__c);
                        }
                        accIdForRevoke.addAll(groupIdAndAccIdsMap.get(grp.Id));
                    }
                }
                
                System.debug(':::groupIdAndAccIdsMap:::' + groupIdAndAccIdsMap + '\n:::' + groupIdAndAccIdsMap.size());
                
                if(accIds.size() > 0) {
                    for(PFAgreement__c pfa : [SELECT Id,Name,Club_Name__c,Club_Name__r.Group_Name__c,Active_Agreement__c FROM PFAgreement__c 
                                              WHERE Club_Name__c IN :accIds AND RecordType.DeveloperName = 'Franchise_Agreement'
                                             ]) {
                        if(String.isNotBlank(pfa.Club_Name__c)) {
                            if(!pfa.Active_Agreement__c && String.isNotBlank(pfa.Club_Name__r.Group_Name__c)) {
                                if(!grpIdAndClubIdsMap.containsKey(pfa.Club_Name__r.Group_Name__c)) 
                                    grpIdAndClubIdsMap.put(pfa.Club_Name__r.Group_Name__c, new Set<Id>());
                                grpIdAndClubIdsMap.get(pfa.Club_Name__r.Group_Name__c).add(pfa.Club_Name__c);
                            } else {
                                //createAccSharePFIds.add(pfa.Id);
                                notRemoveClubAccessFA.add(pfa.Club_Name__c);
                            }
                        }
                    }
                }
                
                for(Group_Owner__c grpOwner : [SELECT Id,Name,Owner_Contact__c,Group_Num__c FROM Group_Owner__c WHERE Group_Num__c IN :grpIdAndClubIdsMap.keySet()]) {
                    conIds.add(grpOwner.Owner_Contact__c);
                    contactIdsForUserQry.add(grpOwner.Owner_Contact__c);
                }
            }
            
            if(contactIdsForUserQry.size() > 0) {
                for(User usr : [SELECT Id,Name,ContactId FROM User WHERE ContactId IN :contactIdsForUserQry]) {
                    conIdAndUserMap.put(usr.ContactId, usr);
                    usrIdAndConIdMap.put(usr.Id, usr.ContactId);
                    
                    if(conIds.contains(usr.ContactId)) {
                        usrIds.add(usr.Id);
                    }
                    
                    if(conIdForRevoke.contains(usr.ContactId)) {
                        usrIdForRevoke.add(usr.Id);
                    }
                }
            }
            
            System.debug(':::usrIdForRevoke:::' + usrIdForRevoke + '\n:::' + usrIdForRevoke.size());
            System.debug(':::accIdForRevoke:::' + accIdForRevoke + '\n:::' + accIdForRevoke.size());
            System.debug(':::conIdForRevoke:::' + conIdForRevoke + '\n:::' + conIdForRevoke.size());
            System.debug(':::grpIdAndClubIdsMap:::' + grpIdAndClubIdsMap + '\n:::' + grpIdAndClubIdsMap.size());
            System.debug(':::conIds:::' + conIds + '\n:::' + conIds.size());
            System.debug(':::usrIds:::' + usrIds + '\n:::' + usrIds.size());
            
            if(accIdForRevoke.size() > 0) {
                if(conIdForRevoke.size() > 0) {
                    revokeACRAccIds.addAll(accIdForRevoke);
                    revokeACRConIds.addAll(conIdForRevoke);
                }
                
                if(usrIdForRevoke.size() > 0) {
                    delAccountShares.addAll([SELECT Id,UserOrGroupId,AccountId FROM AccountShare WHERE AccountId IN :accIdForRevoke AND UserOrGroupId IN :usrIdForRevoke]);
                }
            }
            
            if(grpIdAndClubIdsMap.size() > 0) {
                
                Set<Id> aIds = new Set<Id>();
                
                if(conIds.size() > 0) {
                    for(Id aId : grpIdAndClubIdsMap.keySet()) {
                        revokeACRAccIds.addAll(grpIdAndClubIdsMap.get(aId));
                        aIds.addAll(grpIdAndClubIdsMap.get(aId));
                    }
                    revokeACRConIds.addAll(conIds);
                }
                
                if(usrIds.size() > 0) {
                    delAccountShares.addAll([SELECT Id,UserOrGroupId,AccountId FROM AccountShare WHERE AccountId IN :aIds AND UserOrGroupId IN :usrIds]);
                }
            }
            
            System.debug(':::createPFAMap:::' + createPFAMap);
            System.debug(':::deletePFAMap:::' + deletePFAMap);
            System.debug(':::RespOwnerAndAppOperIds:::' + RespOwnerAndAppOperIds);
            System.debug(':::contactIdsForUserQry:::' + contactIdsForUserQry);
            System.debug(':::conIdAndUserMap:::' + conIdAndUserMap);
            
            for(Group_Owner__c grpOwner : [SELECT Id,Name,Owner_Contact__c,Group_Num__c,Delegated__c FROM Group_Owner__c WHERE Owner_Contact__c IN :RespOwnerAndAppOperIds 
                                              OR Owner_Contact__c IN :deletePFAMap.keySet()
                                          ]) {
                if(!conIdAndGroupOwnersMap.containsKey(grpOwner.Owner_Contact__c)) 
                    conIdAndGroupOwnersMap.put(grpOwner.Owner_Contact__c, new List<Group_Owner__c>());
                conIdAndGroupOwnersMap.get(grpOwner.Owner_Contact__c).add(grpOwner);
                
                if(deletePFAMap.keySet().contains(grpOwner.Owner_Contact__c) && grpOwner.Delegated__c) {
                    if(!groupIdAndGOMap.containsKey(grpOwner.Group_Num__c)) 
                        groupIdAndGOMap.put(grpOwner.Group_Num__c, new List<Group_Owner__c>());
                    groupIdAndGOMap.get(grpOwner.Group_Num__c).add(grpOwner);
                }
            } 
            
            System.debug(':::conIdAndGroupOwnersMap:::' + conIdAndGroupOwnersMap + '\n:::groupIdAndGOMap:::' + groupIdAndGOMap);    
            
            if(createPFAMap.size() > 0) {
                for(Id createConId : createPFAMap.keySet()) {
                    PFAgreement__c pfAgr = createPFAMap.get(createConId);
                    
                    List<Group_Owner__c> mergeGOs = new List<Group_Owner__c>();
                    
                    if(String.IsNotBlank(pfAgr.Approved_Operator__c) && conIdAndGroupOwnersMap.containsKey(pfAgr.Approved_Operator__c)) {
                        mergeGOs.addAll(conIdAndGroupOwnersMap.get(pfAgr.Approved_Operator__c));
                    }
                    
                    if(String.IsNotBlank(pfAgr.Responsible_Owner__c) && conIdAndGroupOwnersMap.containsKey(pfAgr.Responsible_Owner__c)) {
                        mergeGOs.addAll(conIdAndGroupOwnersMap.get(pfAgr.Responsible_Owner__c));
                    }                    
                    
                    for(Group_Owner__c grpOwner : mergeGOs) {
                        
                        if(!(newGroupOwnerIds.contains(createConId) && newGroupIds.contains(grpOwner.Group_Num__c))) {
                            Group_Owner__c grpOwn = new Group_Owner__c(Owner_Contact__c=createConId, Group_Num__c=grpOwner.Group_Num__c, Delegated__c=TRUE);
                            createGOList.add(grpOwn);
                            newGroupOwnerIds.add(createConId);
                            newGroupIds.add(grpOwner.Group_Num__c);
                        }
                    }
                }
            }
            System.debug(':::createGOList:::' + createGOList);
            
            if(createGOList.size() > 0) {
                for(Group_Owner__c go : [SELECT Id,Name,Owner_Contact__c,Group_Num__c FROM Group_Owner__c WHERE Owner_Contact__c IN :newGroupOwnerIds 
                                            AND Group_Num__c IN :newGroupIds
                                        ]) {
                    String key = String.valueOf(go.Group_Num__c) + String.valueOf(go.Owner_Contact__c);
                    existGOKeys.add(key);       
                }
                
                if(existGOKeys.size() > 0) {
                    for(Group_Owner__c newGO : createGOList) {
                        String key = String.valueOf(newGO.Group_Num__c) + String.valueOf(newGO.Owner_Contact__c);
                        if(!existGOKeys.contains(key)) {
                            createFinalGOList.add(newGO);
                        }
                    }
                } else {
                    createFinalGOList.addAll(createGOList);
                }
            }
            
            if(deletePFAMap.size() > 0) {
                deleteGOList = confirmDeleteGOFunction(deletePFAMap.keySet(), groupIdAndGOMap, NULL);
            } 
            
            //AccountShare Creation & Deletion
            
            Set<Id> accountIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            
            System.debug(':::createAccSharePFIds:::' + createAccSharePFIds + '\ncreateAccSharePFIds size:::' + createAccSharePFIds.size());
            System.debug(':::deleteAccSharePFIds:::' + deleteAccSharePFIds + '\ndeleteAccSharePFIds size:::' + deleteAccSharePFIds.size());
            
            if(createAccSharePFIds.size() > 0 || deleteAccSharePFIds.size() > 0) {
                
                Set<Id> delAccShareAccIds = new Set<Id>();
                Set<Id> delAccShareUsrIds = new Set<Id>();
                Set<Id> donotRemoveAccess = new Set<Id>();
                Map<Id, Set<Id>> grpIdAndAccIdsForShare = new Map<Id, Set<Id>>();
                Map<Id, Set<Id>> grpIdAndAccIdsForDelete = new Map<Id, Set<Id>>();
                
                for(PFAgreement__c pfAgrmnt : [SELECT Id,Name,RecordType.DeveloperName,Club_Name__c,Club_Name__r.Group_Name__c,
                                                  (SELECT Id,Name,Status__c,Group_Name__c FROM Accounts__r WHERE Group_Name__c != NULL),
                                                  Approved_Operator__c,Responsible_Owner__c,Delegated_Administrator_1__c,Delegated_Administrator_2__c
                                                  FROM PFAgreement__c WHERE Id IN :createAccSharePFIds OR Id IN :deleteAccSharePFIds
                                              ]) {
                    
                    if(createAccSharePFIds.contains(pfAgrmnt.Id)) {
                        system.debug(':::::isUpdate:::'+isUpdate);
                        system.debug(pfAgrmnt.RecordType.DeveloperName+'::::pfAgrmnt.Accounts__r:::'+pfAgrmnt.Accounts__r+'::::pfAgrmnt::'+pfAgrmnt.Id);
                        if(pfAgrmnt.RecordType.DeveloperName == 'Area_Development_Agreement') {
                            for(Account acc : pfAgrmnt.Accounts__r) {
                                
                                if(String.isNotBlank(pfAgrmnt.Approved_Operator__c) && conIdAndUserMap.containsKey(pfAgrmnt.Approved_Operator__c)) {
                                    User usr = conIdAndUserMap.get(pfAgrmnt.Approved_Operator__c);
                                    AccountShare accShare = createAccountShare(acc.Id, usr.Id);
                                    accountIds.add(acc.Id);
                                    contactIds.add(pfAgrmnt.Approved_Operator__c);
                                    if(accShare != null) creareShares.add(accShare);
                                }
                                if(String.isNotBlank(pfAgrmnt.Responsible_Owner__c) && conIdAndUserMap.containsKey(pfAgrmnt.Responsible_Owner__c)) {
                                    User usr = conIdAndUserMap.get(pfAgrmnt.Responsible_Owner__c);
                                    AccountShare accShare = createAccountShare(acc.Id, usr.Id);
                                    accountIds.add(acc.Id);
                                    contactIds.add(pfAgrmnt.Responsible_Owner__c);
                                    if(accShare != null) creareShares.add(accShare);
                                }
                                if(String.isNotBlank(pfAgrmnt.Delegated_Administrator_1__c) && conIdAndUserMap.containsKey(pfAgrmnt.Delegated_Administrator_1__c)) {
                                    User usr = conIdAndUserMap.get(pfAgrmnt.Delegated_Administrator_1__c);
                                    AccountShare accShare = createAccountShare(acc.Id, usr.Id);
                                    accountIds.add(acc.Id);
                                    contactIds.add(pfAgrmnt.Delegated_Administrator_1__c);
                                    if(accShare != null) creareShares.add(accShare);
                                }
                                if(String.isNotBlank(pfAgrmnt.Delegated_Administrator_2__c) && conIdAndUserMap.containsKey(pfAgrmnt.Delegated_Administrator_2__c)) {
                                    User usr = conIdAndUserMap.get(pfAgrmnt.Delegated_Administrator_2__c);
                                    AccountShare accShare = createAccountShare(acc.Id, usr.Id);
                                    accountIds.add(acc.Id);
                                    contactIds.add(pfAgrmnt.Delegated_Administrator_2__c);
                                    if(accShare != null) creareShares.add(accShare);
                                }
                            }
                        } else if(pfAgrmnt.RecordType.DeveloperName == 'Franchise_Agreement') {
                            
                            if(String.isNotBlank(pfAgrmnt.Club_Name__c)) {
                                if(String.isNotBlank(pfAgrmnt.Approved_Operator__c) && conIdAndUserMap.containsKey(pfAgrmnt.Approved_Operator__c)) {
                                        User usr = conIdAndUserMap.get(pfAgrmnt.Approved_Operator__c);
                                        AccountShare accShare = createAccountShare(pfAgrmnt.Club_Name__c, usr.Id);
                                        accountIds.add(pfAgrmnt.Club_Name__c);
                                        contactIds.add(pfAgrmnt.Approved_Operator__c);
                                        if(accShare != null) creareShares.add(accShare);
                                    }
                                    if(String.isNotBlank(pfAgrmnt.Responsible_Owner__c) && conIdAndUserMap.containsKey(pfAgrmnt.Responsible_Owner__c)) {
                                        User usr = conIdAndUserMap.get(pfAgrmnt.Responsible_Owner__c);
                                        AccountShare accShare = createAccountShare(pfAgrmnt.Club_Name__c, usr.Id);
                                        accountIds.add(pfAgrmnt.Club_Name__c);
                                        contactIds.add(pfAgrmnt.Responsible_Owner__c);
                                        if(accShare != null) creareShares.add(accShare);
                                    }
                                    if(String.isNotBlank(pfAgrmnt.Delegated_Administrator_1__c) && conIdAndUserMap.containsKey(pfAgrmnt.Delegated_Administrator_1__c)) {
                                        User usr = conIdAndUserMap.get(pfAgrmnt.Delegated_Administrator_1__c);
                                        AccountShare accShare = createAccountShare(pfAgrmnt.Club_Name__c, usr.Id);
                                        accountIds.add(pfAgrmnt.Club_Name__c);
                                        contactIds.add(pfAgrmnt.Delegated_Administrator_1__c);
                                        if(accShare != null) creareShares.add(accShare);
                                    }
                                    if(String.isNotBlank(pfAgrmnt.Delegated_Administrator_2__c) && conIdAndUserMap.containsKey(pfAgrmnt.Delegated_Administrator_2__c)) {
                                        User usr = conIdAndUserMap.get(pfAgrmnt.Delegated_Administrator_2__c);
                                        AccountShare accShare = createAccountShare(pfAgrmnt.Club_Name__c, usr.Id);
                                        accountIds.add(pfAgrmnt.Club_Name__c);
                                        contactIds.add(pfAgrmnt.Delegated_Administrator_2__c);
                                        if(accShare != null) creareShares.add(accShare);
                                    }
                                
                                if(String.isNotBlank(pfAgrmnt.Club_Name__r.Group_Name__c)) {
                                    if(!grpIdAndAccIdsForShare.containsKey(pfAgrmnt.Club_Name__r.Group_Name__c)) 
                                        grpIdAndAccIdsForShare.put(pfAgrmnt.Club_Name__r.Group_Name__c, new Set<Id>());
                                    grpIdAndAccIdsForShare.get(pfAgrmnt.Club_Name__r.Group_Name__c).add(pfAgrmnt.Club_Name__c);
                                }
                            }
                        }
                    } 
                    
                    if(deleteAccSharePFIds.contains(pfAgrmnt.Id)) {
                        
                        if(pfAgrmnt.RecordType.DeveloperName == 'Area_Development_Agreement') {
                            PFAgreement__c oldPFA = oldPFAgrmnt.get(pfAgrmnt.Id);
                            for(Account acc : pfAgrmnt.Accounts__r) {
                                delAccShareAccIds.add(acc.Id);
                                revokeACRAccIds.add(acc.Id);
                            }
                            if(oldPFA != NULL) {
                                if(String.isNotBlank(oldPFA.Approved_Operator__c) && conIdAndUserMap.containsKey(oldPFA.Approved_Operator__c)) {
                                    delAccShareUsrIds.add(conIdAndUserMap.get(oldPFA.Approved_Operator__c).Id);
                                    revokeACRConIds.add(oldPFA.Approved_Operator__c);
                                }
                                if(String.isNotBlank(oldPFA.Responsible_Owner__c) && conIdAndUserMap.containsKey(oldPFA.Responsible_Owner__c)) {
                                    delAccShareUsrIds.add(conIdAndUserMap.get(oldPFA.Responsible_Owner__c).Id);
                                    revokeACRConIds.add(oldPFA.Responsible_Owner__c);
                                }
                                if(String.isNotBlank(oldPFA.Delegated_Administrator_1__c) && conIdAndUserMap.containsKey(oldPFA.Delegated_Administrator_1__c)) {
                                    delAccShareUsrIds.add(conIdAndUserMap.get(oldPFA.Delegated_Administrator_1__c).Id);
                                    revokeACRConIds.add(oldPFA.Delegated_Administrator_1__c);
                                }
                                if(String.isNotBlank(oldPFA.Delegated_Administrator_2__c) && conIdAndUserMap.containsKey(oldPFA.Delegated_Administrator_2__c)) {
                                    delAccShareUsrIds.add(conIdAndUserMap.get(oldPFA.Delegated_Administrator_2__c).Id);
                                    revokeACRConIds.add(oldPFA.Delegated_Administrator_2__c);
                                }
                            }     
                        } else if(pfAgrmnt.RecordType.DeveloperName == 'Franchise_Agreement') {
                            
                            if(String.isNotBlank(pfAgrmnt.Approved_Operator__c)) {
                                donotRemoveAccess.add(pfAgrmnt.Approved_Operator__c);
                            }
                            if(String.isNotBlank(pfAgrmnt.Responsible_Owner__c)) {
                                donotRemoveAccess.add(pfAgrmnt.Responsible_Owner__c);
                            }
                            if(String.isNotBlank(pfAgrmnt.Delegated_Administrator_1__c)) {
                                donotRemoveAccess.add(pfAgrmnt.Delegated_Administrator_1__c);
                            }
                            if(String.isNotBlank(pfAgrmnt.Delegated_Administrator_2__c)) {
                                donotRemoveAccess.add(pfAgrmnt.Delegated_Administrator_2__c);
                            }
                            
                            if(String.isNotBlank(pfAgrmnt.Club_Name__r.Group_Name__c)) {
                                if(!grpIdAndAccIdsForDelete.containsKey(pfAgrmnt.Club_Name__r.Group_Name__c)) 
                                    grpIdAndAccIdsForDelete.put(pfAgrmnt.Club_Name__r.Group_Name__c, new Set<Id>());
                                grpIdAndAccIdsForDelete.get(pfAgrmnt.Club_Name__r.Group_Name__c).add(pfAgrmnt.Club_Name__c);
                            }
                        }                   
                    }                
                }
                
                System.debug(':::grpIdAndAccIdsForDelete:::' + grpIdAndAccIdsForDelete + '\ngrpIdAndAccIdsForDelete size:::' + grpIdAndAccIdsForDelete.size());
                if(grpIdAndAccIdsForShare.size() > 0 || grpIdAndAccIdsForDelete.size() > 0) {
                    for(Group_Owner__c grpOwner : [SELECT Id,Name,Owner_Contact__c,Group_Num__c,Delegated__c FROM Group_Owner__c WHERE Group_Num__c IN :grpIdAndAccIdsForShare.keySet() OR Group_Num__c IN :grpIdAndAccIdsForDelete.keySet()]) {
                        if(grpIdAndAccIdsForShare.containsKey(grpOwner.Group_Num__c)) {
                            for(Id accId : grpIdAndAccIdsForShare.get(grpOwner.Group_Num__c)) {
                                if(conIdAndUserMap.get(grpOwner.Owner_Contact__c) != NULL) {
                                    AccountShare accShare = createAccountShare(accId, conIdAndUserMap.get(grpOwner.Owner_Contact__c).Id);
                                    if(accShare != null) creareShares.add(accShare);
                                }
                            }
                        }
                        if(grpIdAndAccIdsForDelete.containsKey(grpOwner.Group_Num__c)) {
                            
                            if(!donotRemoveAccess.contains(grpOwner.Owner_Contact__c) && conIdAndUserMap.get(grpOwner.Owner_Contact__c) != NULL) { 
                                delAccShareUsrIds.add(conIdAndUserMap.get(grpOwner.Owner_Contact__c).Id); 
                            }
                            delAccShareAccIds.addAll(grpIdAndAccIdsForDelete.get(grpOwner.Group_Num__c));
                        }
                    }
                }
                
                System.debug(':::conIdAndUserMap:::' + conIdAndUserMap);
                System.debug(':::delAccShareAccIds:::' + delAccShareAccIds + ':::delAccShareUsrIds:::' + delAccShareUsrIds);
                if(delAccShareAccIds.size() > 0 && delAccShareUsrIds.size() > 0) {
                    delAccountShares.addAll([SELECT Id,UserOrGroupId,AccountId FROM AccountShare WHERE AccountId IN :delAccShareAccIds AND UserOrGroupId IN :delAccShareUsrIds]);
                }
            }
            
            System.debug(':::creareShares:::' + creareShares);
            System.debug(':::createFinalGOList:::' + createFinalGOList + ':::size():::' + createFinalGOList.size());
            System.debug(':::deleteGOList:::' + deleteGOList + ':::size():::' + deleteGOList.size());
            
            if(deleteGOList.size() > 0) {
                delete deleteGOList;
            } 
            if(createFinalGOList.size() > 0) {
                insert createFinalGOList;
            }
        } 
                
        if(creareShares.size() > 0 || delAccountShares.size() > 0) {
            System.debug(':::accountSharesFutureJob fn method called:::');
            accountSharesFutureJob(JSON.Serialize(creareShares), JSON.Serialize(delAccountShares), RespOwnerAndAppOperIds, notRemoveClubAccessFA);
            
            if(creareShares.size() > 0) {
                Set<Id> userIds = new Set<Id>();
                
                for(AccountShare acShare : creareShares) {
                    userIds.add(acShare.UserOrGroupId);
                }
                
                if(userIds.size() > 0) updateUserInFuture(userIds);
            }
        } 
    } 
    
    public void deletePFAgreement(Map<Id,PFAgreement__c> oldPFAgrmnt) {
        
        if(oldPFAgrmnt != NULL && oldPFAgrmnt.size() > 0) {
            
            Set<Id> userContactIds = new Set<Id>();
            Set<Id> userIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            Set<Id> pfIds = new Set<Id>();
            Map<Id, List<Group_Owner__c>> groupIdAndGOMap = new Map<Id, List<Group_Owner__c>>();
            
            for(PFAgreement__c pfAgreement : [SELECT Id,Name,(SELECT Id,Name,Status__c,Group_Name__c FROM Accounts__r WHERE Group_Name__c != NULL),
                                                  Approved_Operator__c,Responsible_Owner__c,Delegated_Administrator_1__c,Delegated_Administrator_2__c
                                                  FROM PFAgreement__c WHERE Id IN :oldPFAgrmnt.keySet()
                                              ]) {
                if(String.IsNotBlank(pfAgreement.Approved_Operator__c)) {
                    userContactIds.add(pfAgreement.Approved_Operator__c);
                }
                if(String.IsNotBlank(pfAgreement.Responsible_Owner__c)) {
                    userContactIds.add(pfAgreement.Responsible_Owner__c);
                }
                if(String.IsNotBlank(pfAgreement.Delegated_Administrator_1__c)) {
                    userContactIds.add(pfAgreement.Delegated_Administrator_1__c);
                }
                if(String.IsNotBlank(pfAgreement.Delegated_Administrator_2__c)) {
                    userContactIds.add(pfAgreement.Delegated_Administrator_2__c);
                }
                
                for(Account acc : pfAgreement.Accounts__r) {
                    accountIds.add(acc.Id);
                }
                pfIds.add(pfAgreement.Id);
            }
            
            if(userContactIds.size() > 0) {
                for(User usr : [SELECT Id,ContactId FROM User WHERE ContactId IN :userContactIds]) {
                    userIds.add(usr.Id);
                }
                
                for(Group_Owner__c grpOwner : [SELECT Id,Name,Owner_Contact__c,Group_Num__c,Delegated__c FROM Group_Owner__c WHERE Owner_Contact__c IN :userContactIds]) {
                   
                    if(!groupIdAndGOMap.containsKey(grpOwner.Group_Num__c)) 
                        groupIdAndGOMap.put(grpOwner.Group_Num__c, new List<Group_Owner__c>());
                    groupIdAndGOMap.get(grpOwner.Group_Num__c).add(grpOwner);
                } 
                
                if(groupIdAndGOMap.size() > 0) {
                    delete confirmDeleteGOFunction(userContactIds, groupIdAndGOMap, pfIds);
                }
                
                if(accountIds.size() > 0) {
                    delAccountShares.addAll([SELECT Id,UserOrGroupId,AccountId FROM AccountShare WHERE UserOrGroupId IN :userIds AND AccountId IN :accountIds]);
                }
            }
        }
    }
    
    public AccountShare createAccountShare(Id accId, Id userId) {
        
        AccountShare accShare = NULL;
        
        if(String.IsNotBlank(userId) && String.IsNotBlank(accId)) {
            accShare = new AccountShare();
            accShare.UserOrGroupId = userId;
            accShare.AccountId = accId;
            accShare.AccountAccessLevel = 'Read';
            accShare.OpportunityAccessLevel = 'None';
            accShare.CaseAccessLevel = 'Read';
            accShare.ContactAccessLevel = 'Read';
        }        
        return accShare;
    }
    
    public List<Group_Owner__c> confirmDeleteGOFunction(Set<Id> conUsrIds, Map<Id, List<Group_Owner__c>> groupIdAndGOMap, Set<Id> delPFIds) {
        
        Set<Id> notDelGOIds = new set<Id>();
        List<Account> accList = new List<Account>();
        List<Group_Owner__c> deleteGOList = new List<Group_Owner__c>();
        
        if(conUsrIds != NULL && groupIdAndGOMap != NULL) {
            
            String qryStr = 'SELECT Id,Name,(SELECT Id,Name,Status__c,Group_Name__c FROM Accounts__r WHERE Group_Name__c != NULL) FROM PFAgreement__c ' +
                            'WHERE RecordType.DeveloperName = \'Area_Development_Agreement\' AND (Responsible_Owner__c IN :conUsrIds OR ' +
                            'Approved_Operator__c IN :conUsrIds OR Delegated_Administrator_1__c IN :conUsrIds OR ' +
                            'Delegated_Administrator_2__c IN :conUsrIds)';
            
            if(delPFIds != NULL) {
                qryStr += ' AND Id NOT IN :delPFIds';
            }
            
            System.debug(':::qryStr:::' + qryStr);
            
            for(PFAgreement__c pfAgrmnt : Database.query(qryStr)) {
                if(pfAgrmnt.Accounts__r.size() > 0) accList.addAll(pfAgrmnt.Accounts__r);
            }
            
            if(accList.size() > 0) {
                for(Account acc : accList) {
                    if(groupIdAndGOMap.containsKey(acc.Group_Name__c)) {
                        for(Group_Owner__c grpOwn : groupIdAndGOMap.get(acc.Group_Name__c)) {
                            if(grpOwn.Group_Num__c == acc.Group_Name__c) {
                                notDelGOIds.add(grpOwn.Id);
                                String key = String.valueOf(acc.Id) + String.valueOf(grpOwn.Owner_Contact__c);
                                notDelAccShares.add(key);
                            }
                        }
                    }
                }
            }
            
            if(groupIdAndGOMap.size() > 0) {
                for(Id grpId : groupIdAndGOMap.keySet()) {
                    for(Group_Owner__c groupOwn : groupIdAndGOMap.get(grpId)) {
                        if(!notDelGOIds.contains(groupOwn.Id)) {
                            deleteGOList.add(groupOwn);
                        }
                    }
                }
            }
        }
        System.debug(':::deleteGOList::' + deleteGOList + '\n:::deleteGOList size:::' + deleteGOList.size());
        return deleteGOList;
    }
    
    @future
    public static void accountSharesFutureJob(String createStr, String deleteStr, Set<Id> ROAndAOIds, Set<Id> notRemoveAccessClubIds) {
        
        System.debug(':::createStr:::' + createStr + '\n:::deleteStr:::' + deleteStr);
        Sharing_Wizard_Setting__c sws = Sharing_Wizard_Setting__c.getOrgDefaults();
        if(ROAndAOIds == NULL) ROAndAOIds = new Set<Id>();
        if(notRemoveAccessClubIds == NULL) notRemoveAccessClubIds = new Set<Id>();
        
        try {
        
            List<AccountShare> accShares = new List<AccountShare>();
            List<AccountShare> delAccShares = new List<AccountShare>();
            //List<AccountShare> finalDelAccShares = new List<AccountShare>();
            
            if(String.isNotBlank(createStr)) {
                accShares = (List<AccountShare>) JSON.deserialize(createStr, List<AccountShare>.class);
            }   
            
            if(String.isNotBlank(deleteStr)) {
                delAccShares = (List<AccountShare>) JSON.deserialize(deleteStr, List<AccountShare>.class);
            }
            
            Set<Id> accIds = new Set<Id>();
            Set<Id> conIds = new Set<Id>();
            Set<Id> userIds = new Set<Id>();
            Set<String> delAccShareKey = new Set<String>();
            Map<String, String> conIdAndUserIdmap = new Map<String, String>();
            Map<Id, AccountShare> delShareMap = new Map<Id, AccountShare>();
            
            for(AccountShare accShare : accShares) {
                userIds.add(accShare.UserOrGroupId);
                accIds.add(accShare.AccountId);
                String key = String.valueOf(accShare.AccountId) + String.valueOf(accShare.UserOrGroupId);
            }
            
            for(AccountShare accShare : delAccShares) {
                if(!notRemoveAccessClubIds.contains(accShare.AccountId)) {
                    userIds.add(accShare.UserOrGroupId);
                    accIds.add(accShare.AccountId);
                    String key = String.valueOf(accShare.AccountId) + String.valueOf(accShare.UserOrGroupId);
                    delAccShareKey.add(key);
                    //finalDelAccShares.add(accShare);
                    delShareMap.put(accShare.Id, accShare);
                }
            }
            
            for(User usr : [SELECT Id,ContactId,ProfileId FROM User WHERE Id IN :userIds]) {
                conIds.add(usr.ContactId);
                conIdAndUserIdmap.put(usr.ContactId, usr.Id);
            }
            
            if(accIds.size() > 0 && conIds.size() > 0) {
                List<AccountContactRelation> acrList = new List<AccountContactRelation>();
                for(AccountContactRelation acr : [SELECT Id,Roles,IsShared__c,AccountId,ContactId FROM AccountContactRelation WHERE AccountId IN :accIds AND ContactId IN :conIds]) {
                    if(conIdAndUserIdmap.containsKey(acr.ContactId)) {
                        String key = String.valueOf(acr.AccountId) + conIdAndUserIdmap.get(acr.ContactId);
                        if(delAccShareKey.contains(key)) {
                            acr.IsShared__c = FALSE;
                            acr.Roles = 'Former Contact';
                        }
                        if(ROAndAOIds.contains(acr.ContactId)) {
                            acr.IsShared__c = TRUE;
                            acr.Roles = 'Franchisee/Owner';
                        }
                        acrList.add(acr);
                    }
                }
                
                if(acrList.size() > 0) update acrList; 
            }
            
            String subject = 'Accountshare record insertion or deletion failed from PFAgreementTrigger';
            String body = '';
            
            //if(!finalDelAccShares.isEmpty()) {
            if(delShareMap.size() > 0) {  
                //Map<Id, AccountShare> delShareMap = new Map<Id, AccountShare>(finalDelAccShares);
                
                Database.DeleteResult[] drList = Database.delete(delShareMap.values(), false);
                
                for(Database.DeleteResult dr : drList) {
                    if (!dr.isSuccess()) {
                        for(Database.Error err : dr.getErrors()) {
                            //body += String.valueOf(err.getMessage()) + '<br/>';
                            body += String.valueOf(err) + '<br/>';
                        }
                    }
                }
            }  
            
            if(!accShares.isEmpty()) {
                
                Database.SaveResult[] srList = Database.insert(accShares, false);
                for(Database.SaveResult sr : srList) {
                    if(!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            //body += String.valueOf(err.getMessage()) + '<br/>';
                            body += String.valueOf(err) + '<br/>';
                        }
                    }
                }
            }  
            if(String.isNotBlank(subject) && String.isNotBlank(body)) sendEmailMethod(subject, body);
            
        } catch(Exception e) {
            
            System.debug('Exception occured::::' + e.getMessage());
            
            String subject = 'Accountshare record insertion or deletion failed from PFAgreementTrigger';
            //String body = 'The following exception occured when the Accountshare record insertion or deletion<br/><br/>' + String.valueOf(e.getMessage());
            String body = 'The following exception occured when the Accountshare record insertion or deletion<br/><br/>' + String.valueOf(e);
            sendEmailMethod(subject, body);
            
        }
    }
    
    @future
    public static void updateUserInFuture(Set<Id> userIds) {
        
        System.debug(':::userIds:::' + userIds);
        if(userIds.size() > 0) {
        
            Sharing_Wizard_Setting__c sws = Sharing_Wizard_Setting__c.getOrgDefaults();
            
            try {
                List<User> updateUsers = new List<User>();
                for(User usr : [SELECT Id,ProfileId FROM User WHERE Id IN :userIds]) {
                    if(String.isNotBlank(sws.Legal_Owner_Profile_Id__c) && sws.Legal_Owner_Profile_Id__c != usr.ProfileId) {
                        usr.ProfileId = sws.Legal_Owner_Profile_Id__c;
                        updateUsers.add(usr);
                    }
                }
                if(updateUsers.size() > 0) {
                    
                    
                    Database.SaveResult[] srList = Database.update(updateUsers, false);
                    Set<Id> usrIds = new Set<Id>();
                    
                    for(Database.SaveResult sr : srList) {
                        if(!sr.isSuccess()) {
                            usrIds.add(sr.getId());
                        }
                    }
                    if(usrIds.size() > 0) {
                        String usrNames = '';
                        Integer cnt = 1;
                        for(User usr : [SELECT Id,Name FROM User WHERE Id IN :usrIds]) {
                            usrNames += cnt + '. ' + usr.Name + '<br/>';
                            cnt++;
                        }
                        
                        String subject = 'User profile updation failed';
                        String body = '';
                        if(String.isNotBlank(usrNames)) body = 'The following user profile update is failed<br/><br/>' + usrNames;
                        if(String.isNotBlank(subject) && String.isNotBlank(body)) sendEmailMethod(subject, body);
                    }
                }
            } catch(Exception e) {
                
                System.debug('Exception occured::::' + e.getMessage());
                
                String subject = 'User profile updation failed from PFAgreementTrigger';
                //String body = 'The following exception occured when update the user profile<br/><br/>' + String.valueOf(e.getMessage());
                String body = 'The following exception occured when update the user profile<br/><br/>' + String.valueOf(e);
                sendEmailMethod(subject, body);
                
            }
        }
    }
    
    public static void sendEmailMethod(String subject, String htmlBody) {
        
        if(String.isNotBlank(subject) && String.isNotBlank(htmlBody)) {
            System.debug('**** DEBUG sendEmailMethod subject = ' +  subject);
            System.debug('**** DEBUG sendEmailMethod body = ' +  htmlBody);

            Sharing_Wizard_Setting__c sws = Sharing_Wizard_Setting__c.getOrgDefaults();
            
            Set<String> toAddress = new Set<String>();
            
            for (String email : sws.Error_Notification_Emails__c.split(';')) {
                toAddress.add(email.trim());
            }
            if(toAddress.size() > 0) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new List<String>(toAddress);
                message.subject = subject;
                message.htmlBody = htmlBody;
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { message });
            }
        }
    }
}