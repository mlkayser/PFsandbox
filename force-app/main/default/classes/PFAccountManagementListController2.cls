public with sharing class PFAccountManagementListController2 
{

    public List<Account_Management__c> getAccounts() {
        List<Account_Management__c> theList =
            [SELECT First_Name__c, Last_Name__c, Email__c, RecordType.Name, Status__c From Account_Management__c WHERE OwnerId=:UserInfo.getUserID()];
        return(theList);
    }


}