/**
 * Created by rdiaznasser on 4/3/18.
 * Goal: scheduled to check all of the Accounts' Related Contacts and check if they belong to the current active group.
 * (Group_Name__c's value must be within the Related Contact's (Group_Owners__r))
 */

global class GroupOwnerBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        // Collect all records to execute against
        String query = 'SELECT Id, Name, Group_Name__c FROM Account' ; // add query modifiers here!
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope){

        /** 1. buildAccountMap
         * input: List<Account> scope
         * return: Map<Id, Account>
         */
        Map<Id, Account> accountMap = new Map<Id, Account>(scope);

        /** 2. AccountTriggerHandler.buildAccountIdList
         * input: Map<Id, Account> accounts
         * return: List<Id>
         */
        List<Id> accountIds = AccountTriggerHandler.buildAccountIdList(accountMap);

        /** 3. AccountTriggerHandler.buildContactMap
         * input: List<Id> accountsToWorkOnIds, Map<Id, Account> newAccounts)
         * return: Map<Id, Contact>
         */
        Map<Id, Contact> contactMap = AccountTriggerHandler.buildContactMap(accountIds, accountMap);

        /** 4. AccountTriggerHandler.updateAccountContactRelationRecords
         * input: Map<Id, Contact> contactMap, Map<Id, Account> accountsToWorkOn
         * return: void
         */
        AccountTriggerHandler.updateAccountContactRelationRecords(contactMap, accountMap);

        /** 5. AccountTriggerHandler.deleteAccountShares
         * input: Map<Id, Contact> contactMap, Map<Id, Account> accountsToWorkOn
         * return: void
         */
        AccountTriggerHandler.deleteAccountShares(contactMap, accountMap);
    }

    global void finish(Database.BatchableContext BC){
        // Execute any post-processing operations
    }
}