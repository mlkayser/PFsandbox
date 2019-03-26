public class AccountTriggerHandler {

    // 03/07/2018 - AVS:RD -> if Account's Group_Name__c changes, query through the Account's Related Contacts and
    // remove all relationships where Contacts' found Groups are not related to the new value.
    public void afterUpdate(Map<Id,Account> oldAccounts, Map<Id,Account> newAccounts){
        System.debug('!!!!! running afterUpdate() !!!!!');

        // Build account list where Group_Name__c has been modified
        Map<Id, Account> accountsToWorkOn = buildAccountList(oldAccounts, newAccounts);
        System.debug('accountsToWorkOn: ' + accountsToWorkOn);

        // Break if nothing to work on
        if(accountsToWorkOn.isEmpty()){
            System.debug('accountsToWorkOn is emtpy! breaking!!!!!');
            return;
        }
        // Build id list
        List<Id> accountsToWorkOnIds = buildAccountIdList(accountsToWorkOn);
        System.debug('accountsToWorkOnIds: ' + accountsToWorkOnIds);

        // Build contact map where the new account's Group_Owner__c is not amongst the contact's related Group_Owner__c records
        Map<Id, Contact> contactMap = buildContactMap(accountsToWorkOnIds, accountsToWorkOn);
        System.debug('contactMap: ' + contactMap);

        // Update Related Contact's EndDate and mark as inactive
        updateAccountContactRelationRecords(contactMap, accountsToWorkOn);

        // Delete Account Share records
        deleteAccountShares(contactMap, accountsToWorkOn);
    }

/*------------------------------------------------Utility Methods-------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------*/

    // Find any users that are tied to the contacts where we have to remove access to the account
    public static void deleteAccountShares(Map<Id, Contact> contactMap, Map<Id, Account> accountsToWorkOn){
        System.debug('!!!!! running deleteAccountShares() !!!!!');
        List<AccountShare> accountsharesToDelete = new List<AccountShare>();
        // Find community users' records
        List<User> contactUsers = [SELECT Id FROM User WHERE ContactId IN: contactMap.keySet()];
        System.debug('contactUsers: ' + contactUsers);
        // Find the corresponding Account Share records
        for(AccountShare accountShare : [SELECT Id, UserOrGroupId FROM AccountShare WHERE UserOrGroupId IN: contactUsers AND AccountId IN: accountsToWorkOn.keySet()]){
            System.debug('! found an AccountShare!!!!! accountShare: ' + accountShare);
            accountsharesToDelete.add(accountShare);
        }
        try{
            delete accountsharesToDelete;
        }catch(DmlException e){
            System.debug('##### An error has occurred while attempting to delete Account Share records: ' + e.getMessage() + ' #####');
        }

    }

    // Find the AccountContactRelation record that belong to the account and contact in contactMap and update them
    public static void updateAccountContactRelationRecords(Map<Id, Contact> contactMap, Map<Id, Account> accountsToWorkOn){
        System.debug('!!!!! running updateAccountContactRelationRecords() !!!!!');
        System.debug('&&&&& contactMap: ' + contactMap);
        List<AccountContactRelation> acrToUpdate = new List<AccountContactRelation>();

        // Loop through Related Contact records where the Account and Contact that were found match up
        for(AccountContactRelation acr : [SELECT Id, AccountId, ContactId, EndDate, IsActive FROM AccountContactRelation WHERE ContactId IN: contactMap.keySet() AND AccountId IN: accountsToWorkOn.keySet()]){
            System.debug('! found an AccountContactRelation!!!!! acr: ' + acr);
            acr.IsActive = false;
            acr.EndDate = System.today();
            acr.Roles = 'Former Contact';
            acr.IsShared__c = false;

            acrToUpdate.add(acr);
        }
        try{
            update acrToUpdate;
        }catch(DmlException e){
            System.debug('##### An error has occurred while attempting to update AccountContactRelation records: ' + e.getMessage() + ' #####');
        }
    }

    // Return contactMap
    public static Map<Id, Contact> buildContactMap(List<Id> accountsToWorkOnIds, Map<Id, Account> newAccounts){
        System.debug('!!!!! running buildContactMap() !!!!!');
        Map<Id, Contact> contactMapToReturn = new Map<Id, Contact>();

        for(AccountContactRelation acr : [SELECT Id, AccountId, ContactId, IsActive FROM AccountContactRelation WHERE IsActive = TRUE AND AccountId IN: newAccounts.keySet()]){
            // Loop through associated contacts
            for(Contact c : [SELECT Id, AccountId, Name, (SELECT Id, Name FROM Group_Owners__r) FROM Contact WHERE Id =: acr.ContactId]){
                System.debug('! found a Contact!!!!! c: ' + c);
                for(Group_Owner__c g : c.Group_Owners__r){
                    System.debug('! g: ' + g);
                    System.debug('! newAccounts.get(c.AccountId).Group_Name__c: ' + newAccounts.get(acr.AccountId).Group_Name__c);
                    if(g.Id != newAccounts.get(acr.AccountId).Group_Name__c){
                        System.debug('? inside if statement!!!!!');
                        contactMapToReturn.put(c.Id, c);
                    }
                }
            }
        }
        System.debug('&&&&& returning!: ' + contactMapToReturn);

        return contactMapToReturn;
    }

    // Only work on those whose Group_Name__c has been modified
    public static Map<Id, Account> buildAccountList(Map<Id,Account> oldAccounts, Map<Id,Account> newAccounts){
        System.debug('!!!!! running buildAccountList !!!!!');
        Map<Id, Account> accountsToReturn = new Map<Id, Account>();
        for(Account a : newAccounts.values()){
            System.debug('! a: ' + a);
            if(a.Group_Name__c != oldAccounts.get(a.Id).Group_Name__c){
                System.debug('? inside if statement!!!!!');
                accountsToReturn.put(a.Id, a);
            }
        }
        return accountsToReturn;
    }

    // Return those accounts' ids
    public static List<Id> buildAccountIdList(Map<Id, Account> accounts){
        System.debug('!!!!! running buildAccountIdList !!!!!');
        List<Id> accountIdsToReturn = new List<Id>();
        for(Account a : accounts.values()){
            System.debug('! a: ' + a);
            accountIdsToReturn.add(a.Id);
        }
        return accountIdsToReturn;
    }
/*--------------------------------------------end afterUpdate()---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------*/

    public void afterInsert(List<Account> accounts) {
        
        System.debug(':::accounts:::' + accounts);
        
        if(accounts != NULL && accounts.size() > 0) {
            
            List<Account> accList = new List<Account>();
            List<AccountContactRelation> acrList = new List<AccountContactRelation>();
            List<AccountShare> accShares = new List<AccountShare>();
            Set<Id> pfIds = new Set<Id>();
            Set<Id> conIds = new Set<Id>();
            Map<Id, Set<Id>> pfIdConIds = new Map<Id, Set<Id>>();
            Map<Id, Id> conIdAndUserIdMap = new Map<Id, Id>();
            
            for(Account acc : accounts) {
                
                if(String.isNotBlank(acc.Area_Development_Agreement__c)) {
                    
                    pfIds.add(acc.Area_Development_Agreement__c);
                    accList.add(acc);
                }
            }
            
            System.debug(':::pfIds:::' + pfIds);
            
            if(pfIds.size() > 0) {
                
                for(PFAgreement__c pfa : [SELECT Id,Responsible_Owner__c,Approved_Operator__c,Delegated_Administrator_1__c,
                                             Delegated_Administrator_2__c
                                         FROM PFAgreement__c WHERE Id IN :pfIds]) {
                                         
                    Set<Id> contactIds = new Set<Id>();
                                        
                    if(String.isNotBlank(pfa.Responsible_Owner__c)) {
                        conIds.add(pfa.Responsible_Owner__c);
                        contactIds.add(pfa.Responsible_Owner__c);
                    }
                    if(String.isNotBlank(pfa.Approved_Operator__c)) {
                        conIds.add(pfa.Approved_Operator__c);
                        contactIds.add(pfa.Approved_Operator__c);
                    }
                    if(String.isNotBlank(pfa.Delegated_Administrator_1__c)) {
                        conIds.add(pfa.Delegated_Administrator_1__c);
                        contactIds.add(pfa.Delegated_Administrator_1__c);
                    }
                    if(String.isNotBlank(pfa.Delegated_Administrator_2__c)) {
                        conIds.add(pfa.Delegated_Administrator_2__c);
                        contactIds.add(pfa.Delegated_Administrator_2__c);
                    }
                    pfIdConIds.put(pfa.Id, contactIds);
                }
                
                System.debug(':::conIds:::' + conIds);
                
                if(conIds.size() > 0) {
                                        
                    for(User usr : [SELECT Id,ContactId FROM User WHERE ContactId IN :conIds]) {
                        conIdAndUserIdMap.put(usr.ContactId, usr.Id);
                    }
                }
            }
            
            System.debug(':::accList:::' + accList);
            
            for(Account acc : accList) {
                
                if(pfIdConIds.containsKey(acc.Area_Development_Agreement__c)) {
                    
                    for(Id conId : pfIdConIds.get(acc.Area_Development_Agreement__c)) {
                        
                        AccountContactRelation acr = new AccountContactRelation(IsShared__c=TRUE, ContactId=conId,
                            AccountId=acc.Id, Roles='Franchisee/Owner'
                        ); 
                        acrList.add(acr);
                        
                        if(conIdAndUserIdMap.containsKey(conId)) {
                            
                            AccountShare accShare = new AccountShare(AccountId=acc.Id, UserOrGroupId=conIdAndUserIdMap.get(conId),
                                AccountAccessLevel='Read',OpportunityAccessLevel='None',CaseAccessLevel='Read',ContactAccessLevel='Read'
                            );
                            accShares.add(accShare);
                        }
                    }
                }
            }
            
            System.debug(':::acrList:::' + acrList);
            System.debug(':::accShares:::' + accShares);
            
            if(acrList.size() > 0) insert acrList;
            
        }
    }
}