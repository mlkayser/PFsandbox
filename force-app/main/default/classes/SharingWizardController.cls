// Keep this class without sharing as this will be run by community users and permissions should not be considered

global without sharing class SharingWizardController {
    
    public String rolesString { get; set; }
    public Boolean isInternalUser { get; set; }
    public String userId { get; set; }
    public String userName { get; set; }
    public String userContactId { get; set; }
    public String helpURL { get; set; }
    
    global SharingWizardController() {
    
        List<String> options = new List<String>();
        Set<String> excludedRoles = new Set<String>();
        rolesString = '';
        userId = '';
        isInternalUser = FALSE;
                
        if(String.isNotBlank(UserInfo.getUserId())) {
            
            User usr = [SELECT Id,Name,ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            if(String.IsBlank(usr.ContactId)) {
                isInternalUser = TRUE;
            } else {
                userId = UserInfo.getUserId();
                userName = usr.Name;
                userContactId = usr.ContactId;
            }
        }
        
        Sharing_Wizard_Setting__c sws = Sharing_Wizard_Setting__c.getOrgDefaults();
        if(String.isNotBlank(sws.Knowledge_Article_Id__c)) {
            
            String kaId = sws.Knowledge_Article_Id__c.trim();
            List<KnowledgeArticleVersion> kav = [SELECT IsVisibleInApp,IsVisibleInCsp,IsVisibleInPkb,IsVisibleInPrm,UrlName 
                                                   FROM KnowledgeArticleVersion 
                                                   WHERE KnowledgeArticleId = :kaId
                                                   AND Language = 'en_US' AND PublishStatus = 'Online'];
            if(kav.size() > 0){
                helpURL = '/' + kaId;
            }
        }
        
        for(Excluded_Roles__c exRole : Excluded_Roles__c.getall().values()) {
            if(String.isNotBlank(exRole.Name)) {
                excludedRoles.add(exRole.Name.trim());
            }
        }
        
        Schema.sObjectType objType = AccountContactRelation.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();      
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> values = fieldMap.get('Roles').getDescribe().getPickListValues();
        
        for(Schema.PicklistEntry a : values) {
            if(String.isNotBlank(a.getValue()) && !excludedRoles.contains(a.getValue().trim())) {
                options.add(String.valueOf(a.getValue()));
            }
        }
        rolesString = JSON.Serialize(options);
    }
    
    @RemoteAction
    global static List<User> getUser() {
        
        List<User> users = NULL;
        Set<Id> profileIds = new Set<Id>();
        
        for(SetupEntityAccess sea : [SELECT Id,Parent.ProfileId,Parent.Profile.Name FROM SetupEntityAccess 
                                    WHERE SetupEntityId IN (SELECT Id FROM ApexPage WHERE Name = 'SharingWizard')]) {
            if(String.isNotBlank(sea.Parent.Profile.Name) && !((sea.Parent.Profile.Name).equalsIgnoreCase('System Administrator'))) {
                profileIds.add(sea.Parent.ProfileId);
            }
        }
        if(profileIds.size() > 0) {
            users = [SELECT Id,Name FROM User WHERE isActive = true AND ProfileId IN :profileIds];
        }
        
        return users;
    }
        
    @RemoteAction
    global static innerCls getData(String userId) {
                
        innerCls inr = new innerCls();
        List<Group__c> groups = new List<Group__c>();
        List<PFAgreement__c> pfAgreements = new List<PFAgreement__c>();
        List<PFAgreement__c> finalPFAgreements = new List<PFAgreement__c>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Id> accIdAndGroupId = new Map<Id,Id>();
        Map<String,List<Contact>> pfIdAndContacts = new Map<String,List<Contact>>();
        Map<Id,Account> pfIdAndAccount = new Map<Id,Account>();
        Map<Id,Set<Id>> pfAggrIdAndAccIdsMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> accIdAndConIdsMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> pfAggrIdAndConIdsMap = new Map<Id,Set<Id>>();
        Map<String, ACRInrCls> accConIdACRMap = new Map<String, ACRInrCls>();
        List<Account> clubList = new List<Account>();
        Set<Id> pfIds = new Set<Id>();
        Map<Id, List<Account>> grpIdAndAccountsMap = new Map<Id, List<Account>>();
        Set<String> withoutADAStatus = new Set<String> { 'Expired', 'Terminated' };
        Set<Id> accIds = new Set<Id>();
        Set<String> restrictACRAccAndConId = new Set<String>();
        
        Sharing_Wizard_Setting__c sws = Sharing_Wizard_Setting__c.getOrgDefaults();
        
        if(String.isNotBlank(userId)) {
            
            User usr = [SELECT Id,Name,ContactId FROM User WHERE Id = :userId];
            String conId = usr != NULL ? usr.ContactId : NULL;
            Set<Id> clubIds = new Set<Id>();
                        
            if(String.IsNotBlank(conId)) {
                
                for(PFAgreement__c pf :[SELECT Id,Name,RecordType.DeveloperName,Club_Name__c,Club_Name__r.Area_Development_Agreement__r.ADA_Status__c,
                                           Approved_Operator__c,Responsible_Owner__c,Delegated_Administrator_1__c,Delegated_Administrator_2__c,
                                           (SELECT Id,Name,Status__c,Group_Name__c FROM Accounts__r ORDER BY Name ASC) 
                                        FROM PFAgreement__c
                                        WHERE ((Club_Name__r.Area_Development_Agreement__r.RecordType.DeveloperName = 'Area_Development_Agreement'
                                           AND RecordType.DeveloperName = 'Franchise_Agreement' AND (Club_Name__r.Area_Development_Agreement__r.ADA_Status__c = NULL OR Club_Name__r.Area_Development_Agreement__r.ADA_Status__c IN :withoutADAStatus))
                                           OR (ADA_Status__c NOT IN :withoutADAStatus AND RecordType.DeveloperName = 'Area_Development_Agreement')) 
                                           AND (Responsible_Owner__c = :conId OR Approved_Operator__c = :conId OR Delegated_Administrator_1__c = :conId 
                                           OR Delegated_Administrator_2__c = :conId)
                                       ]){
                    if(pf.RecordType.DeveloperName == 'Franchise_Agreement') {
                        pfIds.add(pf.Id);
                    }
                    
                    if(pf.Club_Name__r.Area_Development_Agreement__r.ADA_Status__c != 'Active') {
                        clubIds.add(pf.Club_Name__c);
                    }         
                    
                    if(pf.RecordType.DeveloperName == 'Area_Development_Agreement') {
                        pfAgreements.add(pf);
                    } 
                    
                    if(String.isNotBlank(pf.Club_Name__c)) {
                        accIds.add(pf.Club_Name__c);
                    }          
                } 
                                                
                if((pfIds.size() > 0 && String.IsNotBlank(sws.One_Off_No_ADA_Name__c)) || clubIds.size() > 0) {
                    
                    for(PFAgreement__c pfAgr : [SELECT Id,Name,Club_Name__c,Club_Name__r.Name,Club_Name__r.Status__c,Club_Name__r.Group_Name__r.Name,Club_Name__r.Group_Name__c,Approved_Operator__c,Responsible_Owner__c,
                                                   Delegated_Administrator_1__c,Delegated_Administrator_2__c 
                                                FROM PFAgreement__c 
                                                WHERE ((Club_Name__c IN :clubIds OR (Id IN :pfIds AND Club_Name__r.Area_Development_Agreement__r.Name = :sws.One_Off_No_ADA_Name__c))) AND Club_Name__c != NULL AND Active_Agreement__c = TRUE]) {
                        Account acc = new Account();
                        acc.Id = pfAgr.Club_Name__c;
                        acc.Name = pfAgr.Club_Name__r.Name;
                        acc.Status__c = pfAgr.Club_Name__r.Status__c;
                        acc.Group_Name__c = pfAgr.Club_Name__r.Group_Name__c;
                        pfIdAndAccount.put(pfAgr.Id, acc);
                        
                        if(String.isNotBlank(pfAgr.Club_Name__r.Group_Name__c)) {
                            if(!grpIdAndAccountsMap.containsKey(pfAgr.Club_Name__r.Group_Name__c))
                                grpIdAndAccountsMap.put(pfAgr.Club_Name__r.Group_Name__c, new List<Account>());
                            grpIdAndAccountsMap.get(pfAgr.Club_Name__r.Group_Name__c).add(acc);
                        }
                        accIdAndGroupId.put(acc.Id, acc.Group_Name__c);
                        clubList.add(acc);
                        if(!pfAggrIdAndAccIdsMap.containsKey(pfAgr.Id)) 
                            pfAggrIdAndAccIdsMap.put(pfAgr.Id, new Set<Id>());
                        pfAggrIdAndAccIdsMap.get(pfAgr.Id).add(acc.Id);
                        
                        if(String.isNotBlank(pfAgr.Club_Name__c)) {
                            accIds.add(pfAgr.Club_Name__c);
                        } 
                    }
                }
                inr.pfIdAndAccount = pfIdAndAccount;  
                inr.grpIdAndAccountsMap = grpIdAndAccountsMap;   
            }
            
            Set<String> adaNames = new Set<String>();
            
            if(pfAgreements.size() > 0) {
                            
                for(PFAgreement__c pf : pfAgreements) {
                    for(Account acc : pf.Accounts__r) {
                        accIdAndGroupId.put(acc.Id, acc.Group_Name__c);
                        if(!pfAggrIdAndAccIdsMap.containsKey(pf.Id)) 
                            pfAggrIdAndAccIdsMap.put(pf.Id, new Set<Id>());
                        pfAggrIdAndAccIdsMap.get(pf.Id).add(acc.Id);
                        clubList.add(acc);
                        accIds.add(acc.Id);
                    }
                }  
            } 
            
            inr.clubList = clubList; 
            
            if(accIdAndGroupId.size() > 0) {
                
                Map<Id,Group__c> groupMap = new Map<Id,Group__c> ([SELECT Id,Name,(SELECT Id,Name,Owner_Contact__c,Owner_Contact__r.Name 
                                                                       FROM Group_Owners__r WHERE Owner_Contact__c != NULL) 
                                                                   FROM Group__c WHERE Id IN :accIdAndGroupId.values()]);
                
                for(Id accId : accIdAndGroupId.keySet()) {
                
                    Id groupId = accIdAndGroupId.get(accId);
                    
                    if(groupMap.containsKey(groupId)) {
                    
                        Group__c grp = groupMap.get(groupId);
                        
                        if(grp.Group_Owners__r != null && grp.Group_Owners__r.size() > 0) {
                        
                            for(Group_Owner__c grpOwner : grp.Group_Owners__r) {
                                
                                if(String.IsNotBlank(grpOwner.Owner_Contact__c)) {
                                    
                                    if(!accIdAndConIdsMap.containsKey(accId)) 
                                        accIdAndConIdsMap.put(accId, new Set<Id>());
                                    accIdAndConIdsMap.get(accId).add(grpOwner.Owner_Contact__c);
                                    
                                    contactIds.add(grpOwner.Owner_Contact__c);
                                }
                            }
                        }
                    }
                }  
                
                if(accIdAndConIdsMap.size() > 0 && contactIds.size() > 0) {
                    
                    Set<Id> contIdsForUserQry = new Set<Id>();
                    Set<Id> userContactIds = new Set<Id>();
                    
                    for(Id pfId : pfAggrIdAndAccIdsMap.keySet()) {
                    
                        for(Id accId : pfAggrIdAndAccIdsMap.get(pfId)) {
                            
                            if(accIdAndConIdsMap.containsKey(accId)) {
                                
                                if(!pfAggrIdAndConIdsMap.containsKey(pfId)) 
                                    pfAggrIdAndConIdsMap.put(pfId, new Set<Id>());
                                pfAggrIdAndConIdsMap.get(pfId).addAll(accIdAndConIdsMap.get(accId));
                                
                                contIdsForUserQry.addAll(accIdAndConIdsMap.get(accId));
                            }
                        }
                    } 
                                        
                    if(contIdsForUserQry.size() > 0) {
                        // only select active users -- MLK
                        for(User u : [SELECT Id,ContactId FROM User WHERE (ContactId IN :contIdsForUserQry OR ContactId IN :contactIds) AND isActive = true]) {
                            userContactIds.add(u.ContactId);
                        }
                    }
                    
                    if(pfAggrIdAndConIdsMap.size() > 0) {
                            
                        Map<Id,Contact> conMap = new Map<Id,Contact> ([SELECT Id, Name FROM Contact WHERE Id IN :contactIds ORDER BY Name ASC]);
                        
                        for(Id pfId : pfAggrIdAndConIdsMap.keySet()) {
                        
                            for(Id contId : pfAggrIdAndConIdsMap.get(pfId)) {
                                if(userContactIds.contains(contId)) {
                                    if(conMap.containsKey(contId)) {
                                    
                                        if(!pfIdAndContacts.containsKey(pfId))
                                            pfIdAndContacts.put(pfId, new List<Contact>());
                                        pfIdAndContacts.get(pfId).add(conMap.get(contId));
                                    }
                                }
                            }
                        }
                        
                        for(Group__c grp : groupMap.values()) {
                            for(Group_Owner__c grpOwner : grp.Group_Owners__r) {
                                if(userContactIds.contains(grpOwner.Owner_Contact__c)) {
                                    if(!pfIdAndContacts.containsKey(grp.Id))
                                        pfIdAndContacts.put(grp.Id, new List<Contact>());
                                    pfIdAndContacts.get(grp.Id).add(conMap.get(grpOwner.Owner_Contact__c));
                                }
                            }
                        }                   
                    }
                    
                    List<AccountContactRelation> acrList = [
                        SELECT AccountId, ContactId, Id, IsShared__c, Roles 
                        FROM AccountContactRelation 
                        WHERE AccountId IN :accIdAndGroupId.keySet() AND ContactId IN :contactIds
                    ];
                    inr.accConIdACRMap = getAccConIdACRMap(acrList);
                    inr.pfIdAndContacts = pfIdAndContacts;
                }
            }
            for(PFAgreement__c pf : pfAgreements) {
                if((pf.Accounts__r != null && pf.Accounts__r.size() > 0) || pfIdAndAccount.keySet().contains(pf.Id)) {
                    finalPFAgreements.add(pf);
                    adaNames.add(pf.Name);
                }
            }
            inr.pfAgreements = finalPFAgreements;
            inr.adaNames = adaNames;
            
            if(accIds.size() > 0) {
                                
                for(PFAgreement__c pfAgr : [SELECT Id,Name,Club_Name__c,Approved_Operator__c,Responsible_Owner__c,Delegated_Administrator_1__c,Delegated_Administrator_2__c FROM PFAgreement__c 
                                           WHERE Club_Name__c IN :accIds AND Active_Agreement__c = TRUE AND RecordType.DeveloperName = 'Franchise_Agreement']) {
                                        
                    if(String.isNotBlank(pfAgr.Approved_Operator__c)) {
                        restrictACRAccAndConId.add(String.valueOf(pfAgr.Club_Name__c) + String.valueOf(pfAgr.Approved_Operator__c));
                    }
                    
                    if(String.isNotBlank(pfAgr.Responsible_Owner__c)) {
                        restrictACRAccAndConId.add(String.valueOf(pfAgr.Club_Name__c) + String.valueOf(pfAgr.Responsible_Owner__c));
                    }
                    
                    if(String.isNotBlank(pfAgr.Delegated_Administrator_1__c)) {
                        restrictACRAccAndConId.add(String.valueOf(pfAgr.Club_Name__c) + String.valueOf(pfAgr.Delegated_Administrator_1__c));
                    }
                    
                    if(String.isNotBlank(pfAgr.Delegated_Administrator_2__c)) {
                        restrictACRAccAndConId.add(String.valueOf(pfAgr.Club_Name__c) + String.valueOf(pfAgr.Delegated_Administrator_2__c));
                    }
                }
                inr.restrictACRAccAndConId = restrictACRAccAndConId;
            }
        }
        return inr;
    }
    
    @RemoteAction
    global static String saveChanges(String acrString) {
                
        String retStr = '';
        
        if(String.isNotBlank(acrString)) {
            try {
                List<AccountContactRelation> acrList = (List<AccountContactRelation>)JSON.deserialize(acrString, List<AccountContactRelation>.class);
                Map<Id,AccountContactRelation> newACRMap = new Map<Id,AccountContactRelation>();
                Set<Id> acrIds = new Set<Id>();
                List<AccountShare> createAccountShares = new List<AccountShare>();
                Map<Id, Set<Id>> conIdAndAccountIds = new Map<Id, Set<Id>>();
                Set<Id> accIds = new Set<Id>();
                Set<Id> conIds = new Set<Id>();
                Map<Id, User> conIdAndUserIdMap = new Map<Id, User>();
                Set<Id> delAccShareUsrIds = new Set<Id>();
                Set<Id> delAccShareAccIds = new Set<Id>();
                List<AccountContactRelation> newACRs = new List<AccountContactRelation>();
                Map<Id, Account> accountsMap = new Map<Id, Account>();
                
                if(acrList != null && acrList.size() > 0) {
                    
                    for(AccountContactRelation acr : acrList) {
                        if(String.isNotBlank(acr.Id)) {
                            acrIds.add(acr.Id);
                            newACRMap.put(acr.Id, acr);
                        } 
                        
                        if(acr.IsShared__c) {
                            newACRs.add(acr);
                        }
                        if(String.IsNotBlank(acr.AccountId)) accIds.add(acr.AccountId);
                        if(String.IsNotBlank(acr.ContactId)) conIds.add(acr.ContactId);
                    }
                    
                    accountsMap = new Map<Id, Account>([SELECT Id,Name,PF_Club_ID__c FROM Account WHERE Id IN :accIds]);
                    
                    if(conIds.size() > 0) {
                        for(User usr : [SELECT Id,ContactId,Club_Access__c FROM User WHERE ContactId IN :conIds]) {
                            conIdAndUserIdMap.put(usr.ContactId, usr);
                        }
                    }
                    
                    Set<Id> delConIds = new Set<Id>();
                    
                    if(acrIds.size() > 0) {
                        for(AccountContactRelation oldACR : [SELECT Id,AccountId,ContactId,IsShared__c,Roles FROM AccountContactRelation WHERE Id IN :acrIds]) {
                            
                            AccountContactRelation newACR = newACRMap.get(oldACR.Id);
                            if(newACR.IsShared__c != oldACR.IsShared__c && oldACR.IsShared__c) {
                            
                                delAccShareAccIds.add(oldACR.AccountId);
                                delConIds.add(oldACR.ContactId);
                                if(conIdAndUserIdMap.get(oldACR.ContactId) != NULL) 
                                    delAccShareUsrIds.add(conIdAndUserIdMap.get(oldACR.ContactId).Id);
                            }
                        }                                   
                    }
                    
                    if(newACRs.size() > 0) {
                        for(AccountContactRelation newACR : newACRs) {
                            if(newACR.IsShared__c) {
                                if(String.isNotBlank(newACR.ContactId) && conIdAndUserIdMap.get(newACR.ContactId) != NULL) {
                                    AccountShare accShare = createAccountShare(newACR.AccountId, conIdAndUserIdMap.get(newACR.ContactId).Id);
                                    if(accShare != NULL) createAccountShares.add(accShare);
                                }
                            } 
                        }
                    }
                    
                    upsert acrList;
                    
                    for(AccountContactRelation acr : acrList) {
                        if(accountsMap.containsKey(acr.AccountId) && conIdAndUserIdMap.containsKey(acr.ContactId)) {
                            
                            Account acc = accountsMap.get(acr.AccountId);
                            User usr = conIdAndUserIdMap.get(acr.ContactId);
                            
                            if(String.isNotBlank(acc.PF_Club_ID__c)) {

                                if(String.isBlank(usr.Club_Access__c)) {
                                    usr.Club_Access__c = acc.PF_Club_ID__c;
                                } else {
                                    String mergeStr = '';
                                    Set<String> clubAccess = new Set<String>(usr.Club_Access__c.split(';'));
                                    
                                    if(delAccShareAccIds.contains(acr.AccountId) && delConIds.contains(acr.ContactId)) {
                                        clubAccess.remove(acc.PF_Club_ID__c);
                                    } else {
                                        clubAccess.add(acc.PF_Club_ID__c);
                                    }
                                    
                                    for(String str : clubAccess) {
                                        if(mergeStr == '') {
                                            mergeStr = str;
                                        } else {
                                            mergeStr += ';' + str;
                                        }
                                    }
                                    usr.Club_Access__c = mergeStr;
                                }
                            }
                        }
                    }
                    
                    accSharesFutureJobs(delAccShareAccIds, delAccShareUsrIds, JSON.serialize(createAccountShares));
                    
                    retStr = JSON.serialize(getAccConIdACRMap(acrList));
                }
            } catch(DmlException de) {
                retStr = 'Error : ' + de.getDmlMessage(0);
            } catch (Exception e) {
                retStr = 'Error : ' + e.getMessage();
            }
        }
        return retStr;
    }
    
    @future
    static void accSharesFutureJobs(Set<Id> accIds, Set<Id> userIds, String accShareStr) {
        
        try {
            String subject = 'Account share record insertion or deletion failed';
            String body = '';
            
            if(accIds.size() > 0 && userIds.size() > 0) {
                List<AccountShare> delAccountShare = [SELECT Id,AccountId,UserOrGroupId FROM AccountShare 
                                                     WHERE UserOrGroupId IN :userIds AND AccountId IN :accIds AND RowCause != 'Owner'];
                
                Set<Id> delSiteAccIds = new Set<Id>();
                Set<Id> delSiteUsrIds = new Set<Id>();
                Set<Id> siteShareIds = new Set<Id>();
                
                for(AccountShare accShare : delAccountShare) {
                    delSiteAccIds.add(accShare.AccountId);
                    delSiteUsrIds.add(accShare.UserOrGroupId);
                }
                            
                Map<Id, AccountShare> delShareMap = new Map<Id, AccountShare>(delAccountShare);
                
                List<AccountShare> delAccShares = delShareMap.values();
                
                Database.DeleteResult[] drList = Database.delete(delAccShares, false);
                
                for(Integer i=0; i<drList.size(); i++) {
                    Database.DeleteResult dr = drList[i];
                    if (!dr.isSuccess()) {
                        
                        body += 'Error on Account share delete record : ' + delAccShares[i] + '<br/>';
                        
                        for(Database.Error err : dr.getErrors()) {
                            body += String.valueOf(err) + '<br/><br/>';
                        }
                    }
                }
                
                if(delSiteAccIds.size() > 0 && delSiteUsrIds.size() > 0 ) {
                    
                    List<Sites__c> siteList = [SELECT Id FROM Sites__c WHERE Project__r.Club_Location__c IN :delSiteAccIds];
                    if(siteList.size() > 0) {
                        
                        List<Sites__Share> delSiteShares = [SELECT Id FROM Sites__Share WHERE ParentId IN :siteList AND UserOrGroupId IN :delSiteUsrIds AND RowCause != 'Owner'];
                        
                        Database.DeleteResult[] drList2 = Database.delete(delSiteShares, false);
                        for(Integer i=0; i<drList2.size(); i++) {
                            Database.DeleteResult dr = drList2[i];
                            if (!dr.isSuccess()) {
                                body += 'Error on Site share delete record : ' + delSiteShares[i] + '<br/>';
                                for(Database.Error err : dr.getErrors()) {
                                    body += 'Error Message : ' + String.valueOf(err.getMessage()) + '<br/><br/>';
                                }
                            }
                        }
                    }
                }
            }
            
            if(String.isNotBlank(accShareStr)) {
                List<AccountShare> accShares = (List<AccountShare>)JSON.deserialize(accShareStr, List<AccountShare>.class);

                if(!accShares.isEmpty()) {
                
                    Database.SaveResult[] srList = Database.insert(accShares, false);
                    for(Integer i=0; i<srList.size(); i++) {
                    
                        Database.SaveResult sr = srList[i];
                        
                        if(!sr.isSuccess()) {
                        
                            body += 'Error on Account share create record : ' + accShares[i] + '<br/>';
                        
                            for(Database.Error err : sr.getErrors()) {
                                body += String.valueOf(err.getMessage()) + '<br/><br/>';
                            }
                        }
                    }
                }  
                                
                Set<Id> accountIds = new Set<Id>();
                Set<Id> usrIds = new Set<Id>();
                Set<Id> brokerProfileIds = new Set<Id>();
                Set<String> siteKeys = new Set<String>();
                Set<Id> sitePrntIds = new Set<Id>();
                Set<Id> siteUserIds = new Set<Id>();
                List<Sites__Share> siteShares = new List<Sites__Share>();
                
                for(AccountShare accShare : accShares) {
                    accountIds.add(accShare.AccountId);
                    usrIds.add(accShare.UserOrGroupId);
                }
                                
                Map<Id, User> userMap = new Map<Id, User>([SELECT Id,ProfileId FROM User WHERE Id IN :usrIds]);
                Map<Id, List<Sites__c>> accIdAndSitesMap = new Map<Id, List<Sites__c>>();
                
                Sharing_Wizard_Setting__c sws = Sharing_Wizard_Setting__c.getOrgDefaults();
                if(sws != NULL && String.isNotBlank(sws.Broker_Profile_Id__c)) {
                    for(String profId : sws.Broker_Profile_Id__c.split(',')) {
                        
                        if(String.isNotBlank(profId)) brokerProfileIds.add(profId.trim());
                    }
                }
                                
                for(Sites__c site : [SELECT Id,Project__c,Project__r.Club_Location__c,Submitter__c,Submitter__r.ProfileId FROM Sites__c WHERE Project__r.Club_Location__c IN :accountIds]) {
                    if(!accIdAndSitesMap.containsKey(site.Project__r.Club_Location__c))
                        accIdAndSitesMap.put(site.Project__r.Club_Location__c, new List<Sites__c>());
                    accIdAndSitesMap.get(site.Project__r.Club_Location__c).add(site);
                    
                    Sites__Share siteShare = NULL;
                    
                    if(brokerProfileIds.contains(site.Submitter__r.ProfileId)) {
                        siteShare = generateSiteShare(site.Submitter__c, site.Id);
                        siteUserIds.add(site.Submitter__c);
                        sitePrntIds.add(site.Id);
                    }
                    if(siteShare != NULL) siteShares.add(siteShare);
                }
                                
                if(accIdAndSitesMap.size() > 0) {
                
                    for(AccountShare accShare : accShares) {
                        if(accIdAndSitesMap.containsKey(accShare.AccountId) && userMap.containsKey(accShare.UserOrGroupId)) {
                            for(Sites__c site : accIdAndSitesMap.get(accShare.AccountId)) {
                                
                                Sites__Share siteShare = NULL;
                                
                                if(!brokerProfileIds.contains(userMap.get(accShare.UserOrGroupId).ProfileId)) {
                                    siteShare = generateSiteShare(accShare.UserOrGroupId, site.Id);
                                    siteUserIds.add(accShare.UserOrGroupId);
                                    sitePrntIds.add(site.Id);
                                } 
                                if(siteShare != NULL) siteShares.add(siteShare);
                            }
                        }
                    }
                }
                
                if(siteShares.size() > 0) {
                    
                    List<Sites__Share> finalSiteShares = new List<Sites__Share>();
                    
                    for(Sites__Share siteShare : [SELECT Id,ParentId,UserOrGroupId FROM Sites__Share WHERE ParentId IN :sitePrntIds AND UserOrGroupId IN :siteUserIds]) {
                        siteKeys.add(String.valueOf(siteShare.ParentId) + String.valueOf(siteShare.UserOrGroupId));
                    }
                    
                    for(Sites__Share siteShare : siteShares) {
                        if(!siteKeys.contains(String.valueOf(siteShare.ParentId) + String.valueOf(siteShare.UserOrGroupId))) {
                            finalSiteShares.add(siteShare);
                        }
                    }
                                        
                    Database.SaveResult[] srList = Database.insert(finalSiteShares, false);
                    for(Integer i=0; i<srList.size(); i++) {
                    
                        Database.SaveResult sr = srList[i];
                        
                        if(!sr.isSuccess()) {
                        
                            body += 'Error on Site share create record : ' + finalSiteShares[i] + '<br/>';
                        
                            for(Database.Error err : sr.getErrors()) {
                                body += String.valueOf(err.getMessage()) + '<br/><br/>';
                            }
                        }
                    }
                }
            }
            if(String.isNotBlank(subject) && String.isNotBlank(body)) PFAgreementTriggerHandler.sendEmailMethod(subject, body);
            
        } catch(Exception e) {
            
            String subject = 'Account share record insertion or deletion failed';
            String body = String.valueOf(e);
            PFAgreementTriggerHandler.sendEmailMethod(subject, body);
        }
    }
    
    global static Map<String, ACRInrCls> getAccConIdACRMap(List<AccountContactRelation> acrList) {
        
        Map<String, ACRInrCls> accConIdACRMap = new Map<String, ACRInrCls>();
        
        if(acrList != null && acrList.size() > 0) {
            
            for(AccountContactRelation acr : acrList) {
            
                String mapKey = String.ValueOf(acr.AccountId) + String.ValueOf(acr.ContactId);
                ACRInrCls acrInr = new ACRInrCls();
                List<String> roles = new List<String>();
                String roleStr = '';
                
                if(String.isNotBlank(acr.Roles)) {
                    for(String str : ((acr.Roles).split(';'))) {
                        roles.add(str);
                    }
                    roles.sort();
                    for(String str : roles) {
                        roleStr += str + ';';
                    }
                    acr.Roles = roleStr.substring(0, roleStr.length() - 1);
                }
                acrInr.roles = roles;
                acrInr.acr = acr;
                accConIdACRMap.put(mapKey, acrInr);
            }
        }
        return accConIdACRMap;
    }
    
    global static Sites__Share generateSiteShare(Id userId, Id parentId) {
        
        Sites__Share siteShare = NULL;
        
        if(String.IsNotBlank(userId) && String.IsNotBlank(parentId)) {
            siteShare = new Sites__Share();
            siteShare.UserOrGroupId = userId;
            siteShare.ParentId = parentId;
            siteShare.AccessLevel = 'Edit';
        }        
        return siteShare;
    }
    
    global static AccountShare createAccountShare(Id accId, Id userId) {
        
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
    
    global class innerCls {
        global Map<Id, List<Account>> grpIdAndAccountsMap;
        global Map<String,List<Contact>> pfIdAndContacts;
        global Map<Id,Account> pfIdAndAccount;
        global List<PFAgreement__c> pfAgreements;
        global Map<String, ACRInrCls> accConIdACRMap;
        global List<Account> clubList;
        global Set<String> adaNames;
        global Set<String> restrictACRAccAndConId;
    }
    
    global class ACRInrCls {
        global AccountContactRelation acr;
        global List<String> roles;
    }
}