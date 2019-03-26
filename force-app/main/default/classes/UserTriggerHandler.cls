/*
    @uthor: azhar.aziz@magnet360.com
    Created Date: 07 / 06 / 2015
    Description: This class is handle by UserTrigger
*/
public class UserTriggerHandler {

/******************************************************************************
 * manager_profiles
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 9/23/2015
 * @jira: PFCC-3026
 * @description: Set with Corp Club Manager & Club Manager Profiles ID
 ******************************************************************************/   
    
    public static Boolean isUpdateUserFlag = TRUE;
     
    public static Set<ID> manager_profiles {
        get{
            if (manager_profiles==null) {
                manager_profiles = new Set< ID >();

                Map<ID, Profile> l_profile_map = new Map<ID, Profile>([ 
                    SELECT Id 
                    FROM Profile 
                    WHERE Name=: 'Customer Community User - Corp Club Manager' 
                    OR Name=: 'Customer Community User - Club Manager' 
                ]);

                if (l_profile_map.size() > 0) {
                    manager_profiles = l_profile_map.keySet();
                }
            }
            return manager_profiles;
        } set;
    }

/******************************************************************************/   

    // This method contains logic executable methods on after insert
    public static void afterInsert(list<User> newUsers){

        syncUserDataWithContact(newUsers, null);

        Set<id> setNewsletterConId = new Set<Id>();
        if (newUsers != NULL && newUsers.size() > 0) {            
            for (User usr : newUsers) {                
                if (usr.isActive 
                    && (String.isNotBlank(usr.SSO_Access__c) && usr.SSO_Access__c.contains('Franchise Newsletter'))
                ) {
                    setNewsletterConId.add(usr.ContactId);
                }
            } 
        }    

        // update Contact field
        if (setNewsletterConId.size() > 0) updateContactRecNewsletter(setNewsletterConId, TRUE);    
    }
    
    // This method contains logic executable methods on before update
    public static void beforeUpdate(List<User> newUsers, Map<Id, User> oldMap) {
    
        updateProfileInactiveCommUser(newUsers, oldMap); 

        if (newUsers != NULL && newUsers.size() > 0) {            
            for (User usr : newUsers) {
                
                User oldUser = oldMap.get(usr.Id);                

                if (oldUser.isActive != usr.isActive && oldUser.isActive && String.isNotBlank(usr.ContactId)) {                    
                    usr.Club_Access__c = '';
                } 
            }
        }
    }
    
    // This method contains logic executable methods on after update
    public static void afterUpdate(list<User> newUsers, map<ID, User> oldMap) {
        
        syncUserDataWithContact(newUsers, oldMap);

        Map<Id, Boolean> conIdAndIsActiveFlag = new Map<Id, Boolean>();
        
        if (newUsers != NULL && newUsers.size() > 0) {
        
            Set<Id> contactIds = new Set<Id>(); 
            Set<id> setNewsletterConId = new Set<Id>();
            Set<id> unsetNewsletterConId = new Set<Id>();

            for (User usr : newUsers) {           
                User oldUser = oldMap.get(usr.Id);
                
                if (oldUser.isActive != usr.isActive && String.isNotBlank(usr.ContactId)) {                    
                    conIdAndIsActiveFlag.put(usr.ContactId, usr.isActive);
                }

                if (usr.isActive && String.isNotBlank(usr.SSO_Access__c)) {
                    if (usr.SSO_Access__C.contains('Franchise Newsletter')) {
                        setNewsletterConId.add(usr.ContactId);
                    }                    
                    else if (!usr.SSO_Access__C.contains('Franchise Newsletter') && 
                        (String.isNotBlank(oldUser.SSO_Access__c) && oldUser.SSO_Access__C.contains('Franchise Newsletter'))
                        ) {
                        unsetNewsletterConId.add(usr.ContactId);
                    }
                }   
            }
            
            System.debug(':::conIdAndIsActiveFlag:::' + conIdAndIsActiveFlag);            
            if (conIdAndIsActiveFlag.size() > 0) updateACRRecords(conIdAndIsActiveFlag);

            // update Contact field
            if (setNewsletterConId.size() > 0) updateContactRecNewsletter(setNewsletterConId, TRUE);
            if (unsetNewsletterConId.size() > 0) updateContactRecNewsletter(unsetNewsletterConId, FALSE);
        }
    }
    
    private static void syncUserDataWithContact(list<User> newUsers, map<ID, User> oldMap) {
        
        // Define if it is in insert context
        Boolean isInsert = oldMap == null;
        
        // Get the user and contact fields that needs to mapping from custom settings
        map<String, User_And_Contact_Field_Mapping__c> mappingFieldSettings = User_And_Contact_Field_Mapping__c.getAll();
        
        // list of updatable users
        list<User> updatableUsers = new list<User>();
        
        // if It is on update call then iterate over users, and find if user info has changed or not?
        if (!isInsert) {
            for (User newUser : newUsers) {
                for (User_And_Contact_Field_Mapping__c mappingFields : mappingFieldSettings.values()) {
                    String userField = mappingFields.Name;
                    
                    if (newUser.get( userField ) != ( oldMap.get( newUser.Id )).get( userField)) {
                        updatableUsers.add( newUser );
                        break;
                    }
                }
            }
        }
        // If it is in Insert context
        else {
            updatableUsers.addAll( newUsers );
        }
        
        // If need to update the contact info related users
        if (!updatableUsers.isEmpty()){
            list<Contact> updatableContacts = new list<Contact>();

            for (User updatableUser : updatableUsers) {
                if (updatableUser.contactId != null) {
                    Contact cont = new Contact(Id = updatableUser.contactId);
                    for (User_And_Contact_Field_Mapping__c mappingFields : mappingFieldSettings.values()) {
                        String userField = mappingFields.Name;
                        String contactField = mappingFields.Contact_Field_Name__c;
                        
                        cont.put( contactField , updatableUser.get(userField) );
                        system.debug('contactField : ' + contactField + ' User ' + updatableUser.get(userField));
                    }
                    updatableContacts.add( cont );
                }
            }

            // if updatable contact is not empty
            if( !updatableContacts.isEmpty() ){
                String JSON_updatableContacts = JSON.serialize( updatableContacts );
                updateContactsInFuture( JSON_updatableContacts );
            }
        }// @ends : updatableUsers.isEmpty() IF
    }
    
    public static void setClubAccess(List< User > l_new_user) {
        List<Id> l_contact_id = new List<ID>();

        for (User u : l_new_user) {
            if (u.ContactID != null && manager_profiles.contains( u.ProfileId)) {
                l_contact_id.add( u.ContactID );
            }
        }

        if (l_contact_id.size() > 0) {
            Map<Id , Contact> l_contact_map = new Map< Id , Contact > ([ 
                SELECT Id, Account.PF_Club_ID__c
                FROM Contact
                WHERE Id IN :l_contact_id 
            ]);

            for (User u : l_new_user) {
                if (l_contact_map.containsKey( u.ContactID)) {
                    u.Club_Access__c = l_contact_map.get( u.ContactID ).Account.PF_Club_ID__c;
                }
            }
        }
    }

    public static void updateProfileInactiveCommUser(List<User> newUsers, Map<ID, User> oldMap) {

        Id ProfileId = [SELECT Id FROM Profile WHERE Name = :'Inactive Community User'].Id;
        System.debug('*** Profile ID = ' + ProfileId);
        Boolean getNewsletter = FALSE;

        if (newUsers != NULL && newUsers.size() > 0) {
        
            Set<Id> contactIds = new Set<Id>();
                    
            for (User usr : newUsers) {           
                User oldUser = oldMap.get(usr.Id);
                String profileName = [SELECT Name FROM Profile WHERE Id = :usr.ProfileId].Name;             
 
                // check if community user was deactivated 
                if ( !usr.isActive 
                    && oldUser.isActive != usr.isActive
                    && profileName.contains('Community') 
                    && usr.ProfileId != ProfileId
                ) {                    
                    // update profile to Inactive
                    usr.ProfileId = ProfileId;

                    // remove all SSO_Access options
                    if (String.isNotBlank(usr.SSO_Access__c)) {
                        usr.SSO_Access__c = '';
                        /*usr.SSO_Access__c = usr.SSO_Access__c
                            .replaceAll('Franchise Newsletter','')
                            .replaceAll(';;',';');*/
                    }

                    contactIds.add(usr.ContactId);
                }
            } 

            // update Contact field
            if (contactIds.size() > 0) updateContactRecNewsletter(contactIds, getNewsletter);          
        }   
    }

    @future
    public static void updateACRRecords(Map<Id, Boolean> conIdAndIsActiveMap) {
        
        System.debug(':::conIdAndIsActiveMap:::' + conIdAndIsActiveMap);
        
        if (conIdAndIsActiveMap != NULL && conIdAndIsActiveMap.size() > 0) {
            
            Set<Id> activeConIds = new Set<Id>();
            Set<Id> inActiveConIds = new Set<Id>();
            List<AccountContactRelation> updateACRs = new List<AccountContactRelation>();
            
            for (Id conId : conIdAndIsActiveMap.keySet()) {
                if(conIdAndIsActiveMap.get(conId)) {
                    activeConIds.add(conId);
                } else {
                    inActiveConIds.add(conId);
                }
            }
            
            System.debug(':::activeConIds:::' + activeConIds);
            System.debug(':::inActiveConIds:::' + inActiveConIds);
            
            if (activeConIds.size() > 0) {
            
                Sharing_Wizard_Setting__c sws = Sharing_Wizard_Setting__c.getOrgDefaults();
                Set<Id> accountIds = new Set<Id>();
                
                for (PFAgreement__c pfa : [
                    SELECT Id, Responsible_Owner__c, RecordType.DeveloperName, 
                            Approved_Operator__c, Club_Name__c, 
                            (SELECT Id,Name From Accounts__r)    
                    FROM PFAgreement__c
                    WHERE (Responsible_Owner__c IN :activeConIds OR Approved_Operator__c IN :activeConIds) 
                    OR (
                        (Responsible_Owner__c IN :activeConIds OR Approved_Operator__c IN :activeConIds) 
                        AND RecordType.DeveloperName = 'Franchise_Agreement' 
                        AND Active_Agreement__c = TRUE 
                        AND Club_Name__r.Area_Development_Agreement__r.Name = :sws.One_Off_No_ADA_Name__c
                    )
                ]){                   
                    if (pfa.RecordType.DeveloperName == 'Franchise_Agreement') {
                        accountIds.add(pfa.Club_Name__c);    
                    } else if (pfa.RecordType.DeveloperName == 'Area_Development_Agreement') {
                        for (Account acts : pfa.Accounts__r) {                            
                            accountIds.add(acts.Id);    
                        }    
                    }   
                }
                
                for (AccountContactRelation acr : [
                    SELECT Id,IsShared__c,Roles 
                    FROM AccountContactRelation 
                    WHERE ContactId IN :activeConIds 
                    AND AccountId IN :accountIds
                ]) {
                    acr.IsShared__c = TRUE;
                    acr.Roles = 'Franchisee/Owner';
                    updateACRs.add(acr);
                }
            }
            
            if (inActiveConIds.size() > 0) {                
                for(AccountContactRelation acr : [
                    SELECT Id,IsShared__c,Roles 
                    FROM AccountContactRelation 
                    WHERE ContactId IN :inActiveConIds
                ]) {
                    acr.IsShared__c = FALSE;
                    acr.Roles = 'Former Contact';
                    updateACRs.add(acr);
                }
            }
            
            System.debug(':::updateACRs:::' + updateACRs);
            
            if(updateACRs.size() > 0)  {
                UserTriggerHandler.isUpdateUserFlag = FALSE;
                update updateACRs; 
            }
        }
    }

    @future
    private static void updateContactsInFuture(String JSON_updatableContacts) {
        list<Contact> contacts = (list<Contact>)JSON.deserialize( JSON_updatableContacts, list<Contact>.class );
        update contacts;
    }

    @future
    private static void updateContactRecNewsletter(Set<Id> conIds, Boolean receiveNewsletter) {
                
        List<Contact> contactsToUpdate = new List<Contact>();

        for (Contact con : [
            SELECT Id, Receive_Franchsiee_Newsletter__c 
            FROM Contact
            WHERE Id IN :conIds
        ]) {

            con.Receive_Franchsiee_Newsletter__c = receiveNewsletter;
            contactsToUpdate.add(con);
        } 

        update contactsToUpdate;  
    }
}