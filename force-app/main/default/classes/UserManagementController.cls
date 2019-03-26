// Keep this class without sharing as this will be run by community users and permissions should not be considered

global without sharing class UserManagementController {
    
    @RemoteAction
    global static resetPswInrCls resetPassword(String userId) {
                
        resetPswInrCls inr = new resetPswInrCls();
        
        if(String.isNotBlank(userId)) {
            try {
                System.resetPassword(userId, true);
                inr.retStr = 'SUCCESS';
                inr.user = [SELECT Id,Email FROM user WHERE Id = :userId];
            } catch(Exception exp) {
                inr.retStr = String.valueOf(exp.getMessage());
            }
        }
        return inr;
    }
    
    @RemoteAction
    global static String updateUser(String usrStr) {
        
        String retStr = 'Update Failed';
        
        if(String.isNotBlank(usrStr)) {
            try {
                        
                User usr = (User)JSON.deserialize(usrStr, User.class);
                User_Management_Setting__c ums = User_Management_Setting__c.getOrgDefaults();
                
                User usrFromSF = [SELECT Id,Email,UserName FROM User WHERE Id = :usr.Id];
                
                if(usrFromSF.Email != usr.Email) {
                    usr.UserName = usr.Email;
                }
                
                List<Contact> conList = [SELECT Id,Email,Name,LastName,RecordTypeId FROM Contact WHERE Email = :usr.Email AND 
                                         RecordTypeId = :ums.Contact_Club_Staff_Record_Type_Id__c];
                System.debug(':::conList:::' + conList);
                  
                if(conList.size() > 0) {
                    retStr = 'This username is already in use by a Club Manager account and cannot be updated.';
                } else {
                    update usr;
                    retStr = 'SUCCESS';
                }
            } Catch(Exception exp) {
            
                retStr = exp.getMessage();
                
                if(retStr.contains('Duplicate Username')) {
                    retStr = 'This update cannot be made because this username is already in use';
                }
            }
        }
        return retStr;    
    }
    
    @RemoteAction
    global static List<User> getData() {
        
        String conId;
                
        if(String.isNotBlank(UserInfo.getUserId())) {
            
            User usr = [SELECT Id,Name,ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            if(String.IsNotBlank(usr.ContactId)) {
                conId = usr.ContactId;
            }
        }
        
        Set<String> withoutADAStatus = new Set<String> { 'Expired', 'Terminated' };
        Set<Id> conIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        List<User> users;
        
        if(String.isNotBlank(conId)) {
            
            for(PFAgreement__c pf :[SELECT Id,Name,RecordType.DeveloperName,Club_Name__c,Club_Name__r.Area_Development_Agreement__r.ADA_Status__c,
                                           Approved_Operator__c,Responsible_Owner__c,Delegated_Administrator_1__c,Delegated_Administrator_2__c,
                                           Club_Name__r.Group_Name__c,
                                           (SELECT Id,Name,Status__c,Group_Name__c FROM Accounts__r) 
                                    FROM PFAgreement__c
                                    WHERE ((Club_Name__r.Area_Development_Agreement__r.RecordType.DeveloperName = 'Area_Development_Agreement'
                                           AND RecordType.DeveloperName = 'Franchise_Agreement' AND (Club_Name__r.Area_Development_Agreement__r.ADA_Status__c = NULL 
                                           OR Club_Name__r.Area_Development_Agreement__r.ADA_Status__c IN :withoutADAStatus))
                                           OR (ADA_Status__c NOT IN :withoutADAStatus AND RecordType.DeveloperName = 'Area_Development_Agreement')) 
                                           AND (Responsible_Owner__c = :conId OR Approved_Operator__c = :conId OR Delegated_Administrator_1__c = :conId 
                                           OR Delegated_Administrator_2__c = :conId)
                                       ]) {
                
                if(String.isNotBlank(pf.Approved_Operator__c))                    
                    conIds.add(pf.Approved_Operator__c);
                
                if(String.isNotBlank(pf.Responsible_Owner__c))                  
                    conIds.add(pf.Responsible_Owner__c);
                
                if(String.isNotBlank(pf.Delegated_Administrator_1__c))                  
                    conIds.add(pf.Delegated_Administrator_1__c);
                
                if(String.isNotBlank(pf.Delegated_Administrator_2__c))                   
                    conIds.add(pf.Delegated_Administrator_2__c);
                
                if(String.isNotBlank(pf.Club_Name__r.Group_Name__c))                   
                    groupIds.add(pf.Club_Name__r.Group_Name__c);
                    
                for(Account acc : pf.Accounts__r) {
                    groupIds.add(acc.Group_Name__c);
                }
            }
            
            if(groupIds.size() > 0) {
                for(Group_Owner__c go : [SELECT Id,Name,Owner_Contact__c,Owner_Contact__r.Name 
                                        FROM Group_Owner__c WHERE Owner_Contact__c != NULL AND Group_Num__c IN :groupIds]) {
                    conIds.add(go.Owner_Contact__c);
                }
            }
            conIds.remove(conId);
            
            if(conIds.size() > 0) {
                // exclude brokers from list -- MLK
                users = [
                    SELECT Id, FirstName, LastName, Name, Email, Username, Phone, Title, ContactId, 
                        LastLoginDate, SSO_Access__c, LastPasswordChangeDate 
                    FROM User 
                    WHERE ContactId IN :conIds 
                    AND isActive = TRUE    
                    AND (NOT profile.name  LIKE '%Broker%')                 
                    ORDER BY FirstName ASC
                ];
            }
        }
        
        return users;
    }
    
    @RemoteAction
    global static innerCls getGroups(String existConId, String checkGroup) {
        
        String conId;
        Set<Id> gIds = new Set<Id>();
        Set<Id> existConGrpIds = new Set<Id>();
        List<Group__c> groups = new List<Group__c>();
        innerCls inr = new innerCls();
        System.debug('checkGroup: ' + checkGroup);
        
        if(String.isNotBlank(checkGroup) && checkGroup.equalsIgnoreCase('con create')) {
            checkGroup = 'no react';
        }
        
        User usr = [SELECT Id,Name,ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if(String.IsNotBlank(usr.ContactId)) {
            conId = usr.ContactId;
        }
                
        if(String.isNotBlank(conId)) {
            
            for(Group_Owner__c go : [SELECT Id,Owner_Contact__c,Group_Num__c FROM Group_Owner__c WHERE Owner_Contact__c = :conId]) {
                gIds.add(go.Group_Num__c);
            }
        }
        
        if(String.isNotBlank(existConId) && String.isNotBlank(checkGroup) && !checkGroup.equalsIgnoreCase('no react')) {
            
            for(Group_Owner__c go : [SELECT Id,Owner_Contact__c,Group_Num__c FROM Group_Owner__c WHERE Owner_Contact__c = :existConId]) {
                existConGrpIds.add(go.Group_Num__c);
            }
            inr.exGroupIds = existConGrpIds;
        }
        
        
        if(gIds.size() > 0) {
            groups = [SELECT Id,Name FROM Group__c WHERE Id IN :gIds AND Group_Status__c='Active'];
            inr.groups = groups;
        }
        return inr;
    }
    
    @RemoteAction
    global static existConInrCls checkExistingContact(String emailAddress) {
        
        System.debug(':::emailAddress:::' + emailAddress);
        existConInrCls inr;
        User_Management_Setting__c ums = User_Management_Setting__c.getOrgDefaults();
        
        if(String.isNotBlank(emailAddress)) {
            
            emailAddress = emailAddress.trim();
            List<User> activeUsers = [SELECT Id,Name,ContactId,isActive FROM User WHERE Email = :emailAddress AND 
                                      isActive = TRUE AND Contact.RecordTypeId = :ums.Contact_Record_Type__c];
            
            if(activeUsers.size() > 0) {
                inr = new existConInrCls();
                inr.retStr = 'EXIST';
                inr.con = new Contact(Id = activeUsers[0].ContactId);
                inr.user = activeUsers[0];
            } else {
            
                List<User> inActiveUsers = [SELECT Id,Name,ContactId,isActive FROM User WHERE Email = :emailAddress AND 
                                            Contact.RecordTypeId = :ums.Contact_Record_Type__c AND isActive = FALSE];
                
                if(inActiveUsers.size() > 0) {
                
                    inr = new existConInrCls();
                    inr.retStr = 'EXIST-INACTIVE';
                    inr.con = new Contact(Id = inActiveUsers[0].ContactId);
                    inr.user = inActiveUsers[0];
                } else {
                
                    List<Contact> conList = [SELECT Id,Email,Name,LastName,RecordTypeId FROM Contact WHERE Email = :emailAddress AND 
                                             (RecordTypeId = :ums.Contact_Club_Staff_Record_Type_Id__c OR RecordTypeId = :ums.Contact_Record_Type__c)];
                    System.debug(':::conList:::' + conList);
                      
                    if(conList.size() > 0) {
                        
                        inr = new existConInrCls();
                        
                        if(ums.Contact_Club_Staff_Record_Type_Id__c == conList[0].RecordTypeId) {
                            inr.retStr = 'This Club Manager already exists and cannot be created. Please reach out to Franchise Management support at: fm@planetfitness.com.';
                        } else {
                            inr.con = conList[0];
                        }
                    }
                }
            }
            
            if(inr != NULL && inr.con != NULL) {
                
                String conId = '';
                Set<Id> gIds = new Set<Id>();
                
                User usr = [SELECT Id,Name,ContactId FROM User WHERE Id = :UserInfo.getUserId()];
                if(String.IsNotBlank(usr.ContactId)) {
                    conId = usr.ContactId;
                }
                        
                if(String.isNotBlank(conId)) {
                    
                    for(Group_Owner__c go : [SELECT Id,Owner_Contact__c,Group_Num__c FROM Group_Owner__c WHERE Owner_Contact__c = :conId]) {
                        gIds.add(go.Group_Num__c);
                    }
                }
                
                for(Group_Owner__c go : [SELECT Id,Group_Num__c FROM Group_Owner__c WHERE Owner_Contact__c = :inr.con.Id]) {
                    if(gIds.contains(go.Group_Num__c)) {
                        inr.groupExist = TRUE;
                        break;
                    }
                }
            }
        }
        System.debug('inner class::::: ' + inr);
        return inr;
    }
    
    @RemoteAction
    global static String createUser(String usrStr, String conStr, List<String> groupIds, String type, List<String> ssoAccess, String createOrReact) {
        
        System.debug(':::usrStr:::' + usrStr + ':::conStr:::' + conStr + ':::groupIds:::' + groupIds + ':::type:::' + type + ':::createOrReact:::' + createOrReact);
        System.debug('ssoAccess: ' + ssoAccess);
        
        String retStr;
        Savepoint sp = Database.setSavepoint();
        
        if(String.isNotBlank(usrStr)) {
            try {
                
                User_Management_Setting__c ums = User_Management_Setting__c.getOrgDefaults();
                Set<String> grpIds = new Set<String>();
                User usr = (User)JSON.deserialize(usrStr, User.class);
                Contact con = new Contact();
                
                String profileId = String.isNotBlank(ums.Default_User_Profile_Id__c) ? ums.Default_User_Profile_Id__c : NULL;
                String userSSOAccess = '';
                String newUserName = '';
                
                if(ssoAccess != NULL && ssoAccess.size() > 0) {
                    userSSOAccess = String.join(ssoAccess, ';');
                }
                
                if(String.isNotBlank(conStr)) {
                    con = (Contact)JSON.deserialize(conStr, Contact.class);
                    System.debug('contact: ' + con);
                } else {
                    con = new Contact(FirstName=usr.FirstName, LastName=usr.LastName, Email=usr.Email, Phone=usr.Phone);
                    if(String.isNotBlank(ums.Owner_Holding_Account_Id__c)) con.AccountId = ums.Owner_Holding_Account_Id__c; 
                    if(String.isNotBlank(ums.Contact_Record_Type__c)) con.RecordTypeId = ums.Contact_Record_Type__c; 
                    
                    insert con;
                }
                Contact cont = [SELECT Id,Name,LastName,FirstName,Email,Phone FROM Contact WHERE Id = :con.Id];
                System.debug('Queried Cont: ' + cont);
                
                if(createOrReact.equalsIgnoreCase('react') || createOrReact.equalsIgnoreCase('no create')) {
                
                    User reactUser = new User();
                    reactUser.Id = usr.Id;
                    reactUser.ProfileId = profileId;
                    reactUser.SSO_Access__c = userSSOAccess;
                    reactUser.isActive = TRUE;
                    reactUser.FirstName = usr.FirstName;
                    reactUser.LastName = usr.LastName;
                    reactUser.Phone = usr.Phone;
                    reactUser.Title = usr.Title;
                    
                    System.debug('reactUser: ' + reactUser);
                    update reactUser;
                    retStr = createOrReact.equalsIgnoreCase('react') ? 'UPDATE' : '';
                } else if(createOrReact.equalsIgnoreCase('create') || createOrReact.equalsIgnoreCase('no react')) {
                    
                    User createUser = new User();
                    
                    if(createOrReact.equalsIgnoreCase('no react')) {
                        List<User> inactiveUsers = [
                            SELECT Id, Email, ContactId 
                            FROM User 
                            WHERE Email = :usr.Email AND Contact.AccountId = :ums.Owner_Holding_Account_Id__c AND IsActive = FALSE
                        ];
                        
                        List<String> userNames = usr.Email.split('@');
                        createUser.UserName = userNames[0] + String.valueOf(inactiveUsers.size()) + '@' + userNames[1]; 
                    } else {
                        createUser.Username = cont.Email;  
                    }
                   
                    createUser.FirstName = cont.FirstName;
                    createUser.LastName = cont.LastName;
                    createUser.Email = cont.Email;
                    createUser.Phone = usr.Phone;
                    createUser.Title = usr.Title;
                    createUser.ContactId = cont.Id;
                    createUser.Alias = (cont.LastName.length() > 8 ? cont.LastName.substring(0,8) : cont.LastName);
                    
                    String usrQry = 'SELECT Id FROM User WHERE LastName LIKE \'' + cont.LastName.trim() + '%\'';
                    System.debug(':::usrQry:::' + usrQry);
                    List<User> nickNameUsers = Database.query(usrQry);
                    
                    String comNickName = nickNameUsers.size() > 0 ? (cont.LastName + String.valueOf(nickNameUsers.size())) : cont.LastName;
                    createUser.CommunityNickname = (comNickName.length() > 40 ? comNickName.substring(0,40) : comNickName);
                    createUser.TimeZoneSidKey = 'America/New_York';
                    createUser.LocaleSidKey = 'en_US';
                    createUser.LanguageLocaleKey = 'en_US';
                    createUser.EmailEncodingKey = 'UTF-8';
                    createUser.ProfileId = profileId;
                    createUser.SSO_Access__c = userSSOAccess;
                    System.debug(':::createUser:::' + createUser);
                    insert createUser;
                    retStr = 'SUCCESS';
                }
                    
                String userConId = cont.Id;
                                
                System.debug(':::groupIds:::' + groupIds);
                
                if(userConId != NULL) {
                    if(groupIds != NULL && groupIds.size() > 0) {
                    
                        Set<String> conAndGrpIds = new Set<String>();
                        List<Group_Owner__c> newGOs = new List<Group_Owner__c>();
                        grpIds = new Set<String>(groupIds.clone());
                    
                        for(Group_Owner__c go : [SELECT Id,Owner_Contact__c,Group_Num__c FROM Group_Owner__c 
                                                 WHERE Owner_Contact__c = :userConId AND Group_Num__c IN :groupIds]) {
                            conAndGrpIds.add(String.valueOf(go.Owner_Contact__c) + String.valueOf(go.Group_Num__c));
                        }
                        
                        for(String groupId : groupIds) {
                            String conAndGrpId = String.valueof(userConId) + groupId;
                            if(!conAndGrpIds.contains(conAndGrpId)) {
                                newGOs.add(new Group_Owner__c(Owner_Contact__c=userConId,Group_Num__c=groupId));
                            }
                        }
                        System.debug(':::newGOs:::' + newGOs);
                        
                        if(newGOs.size() > 0) {
                        
                            creatingGroup(JSON.serialize(newGOs));
                            if(String.isBlank(retStr)) {
                                retStr = 'GOONLY';
                            }
                        }
                    }
                    
                    Set<String> runningUserGrpIds = new Set<String>();
                    Set<String> currentUserGrpIds = new Set<String>();                    
                    String runningUserConId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
                    
                    for(Group_Owner__c go : [SELECT Id,Owner_Contact__c,Group_Num__c FROM Group_Owner__c WHERE 
                                             Owner_Contact__c = :userConId OR Owner_Contact__c = :runningUserConId]) {
                        
                        if(runningUserConId == go.Owner_Contact__c) 
                            runningUserGrpIds.add(go.Group_Num__c);
                        
                        if(userConId == go.Owner_Contact__c)                   
                            currentUserGrpIds.add(go.Group_Num__c);
                    }
                    
                    for(String gId : currentUserGrpIds) {
                        if(runningUserGrpIds.contains(gId))
                            grpIds.add(gId);
                    }
                }
                
                System.debug(':::grpIds:::' + grpIds);
                
                if(String.isBlank(retStr)) {
                    retStr = 'GOONLYNOTADDED';
                }
                
                String grpNameStr = '';
                
                for(Group__c grp : [SELECT Id,Name FROM Group__c WHERE Id IN :grpIds ORDER BY Name ASC]) {
                    
                    grpNameStr += String.isNotBlank(grpNameStr) ? (', ' + grp.Name) : grp.Name;
                }
                
                System.debug(':::grpNameStr:::' + grpNameStr);
                retStr += '@' + grpNameStr;
                
            } catch(Exception exp) {
                Database.rollback(sp);
                retStr = String.valueOf(exp.getMessage());
                System.debug(':::retStr:::' + retStr);
            }
        }
        System.debug(':::retStr:::' + retStr);
        return retStr;
    }
    
    @future
    global static void creatingGroup(String grpOwners) {
            
        List<Group_Owner__c> groupOwners = (List<Group_Owner__c>)JSON.deserialize(grpOwners, List<Group_Owner__c>.class);
        if(groupOwners != NULL && groupOwners.size() > 0) insert groupOwners;
    }
    
    @RemoteAction
    global static String deactivateUser(String usrId) {
            
        String retStr;
        User_Management_Setting__c ums = User_Management_Setting__c.getOrgDefaults();
        
        if(String.isNotBlank(usrId)) {
            try {
                User usr = [
                    SELECT Id,Name,isActive,ProfileId,Title 
                    FROM User 
                    WHERE Id = :usrId
                ];
                usr.isActive = false;
                usr.ProfileId = ums.Deactivated_User_Profile_ID__c;
                usr.Title = String.isNotBlank(usr.Title) ? ('Prior ' + usr.Title) : NULL;
                update usr;
                retStr = 'SUCCESS';
            } catch(Exception exp) {
                retStr = String.valueOf(exp.getMessage());
            }
        }
        return retStr;
    }
    
    @RemoteAction
    global static List<String> returnUserSSOAccess() {
    
        List<String> ssoAccess = new List<String>();
        for(Schema.PicklistEntry pick : User.SSO_Access__c.getDescribe().getPicklistValues()) {
        
            ssoAccess.add(pick.getValue());
        }
        return ssoAccess;
    }
    
    global class innerCls {
        global List<Group__c> groups;
        global Set<Id> exGroupIds;
    }
    
    global class resetPswInrCls {
        global String retStr;
        global User user;
    }
    
    global class existConInrCls {
        Contact con;
        String retStr;
        Boolean groupExist;
        User user;
    }
}