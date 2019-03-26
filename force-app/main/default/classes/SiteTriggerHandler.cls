public class SiteTriggerHandler {
    
    public void CreateSitesSharing(List<Sites__c> sites, Map<Id, Sites__c> oldMap) {
                
        Map<Id, List<Sites__c>> accIdAndSitesMap = new Map<Id, List<Sites__c>>();
        List<Sites__Share> createSiteShares = new List<Sites__Share>();
        Set<Id> rmvShareSiteIds = new Set<Id>();
        Set<Id> rmvShareUserIds = new Set<Id>();
        Set<Id> brokerProfileIds = new Set<Id>();
        
        if(sites != NULL && sites.size() > 0) {
            
            Boolean isUpdate = (oldMap == NULL ? FALSE : TRUE);
            
            Sharing_Wizard_Setting__c sws = Sharing_Wizard_Setting__c.getOrgDefaults();
            if(sws != NULL && String.isNotBlank(sws.Broker_Profile_Id__c)) {
                for(String profId : sws.Broker_Profile_Id__c.split(',')) {
                    
                    if(String.isNotBlank(profId)) brokerProfileIds.add(profId.trim());
                }
            }
                                    
            for(Sites__c site : [SELECT Id,Project__r.Club_Location__c,Submitter__c,Submitter__r.ProfileId FROM Sites__c WHERE Id IN :sites]) {
                
                Sites__Share submitterSiteShare = NULL;
                                
                if(isUpdate) {
                    Sites__c oldSite = oldMap.get(site.Id);
                    if(oldSite != NULL && oldSite.Submitter__c != site.Submitter__c) {
                        rmvShareSiteIds.add(site.Id);
                        rmvShareUserIds.add(oldSite.Submitter__c);
                    }
                } else {
                    if(String.isNotBlank(site.Project__r.Club_Location__c)) {
                   
                        if(!accIdAndSitesMap.containsKey(site.Project__r.Club_Location__c))
                            accIdAndSitesMap.put(site.Project__r.Club_Location__c, new List<Sites__c>());
                        accIdAndSitesMap.get(site.Project__r.Club_Location__c).add(site);
                    } 
                }
                
                if(brokerProfileIds.contains(site.Submitter__r.ProfileId)) {
                    submitterSiteShare = SharingWizardController.generateSiteShare(site.Submitter__c, site.Id);
                } 
                if(submitterSiteShare != NULL) createSiteShares.add(submitterSiteShare);
            }
            
            if(!accIdAndSitesMap.isEmpty()) {
                for(AccountShare accShare : [SELECT Id,AccountId,UserOrGroupId,UserOrGroup.ProfileId FROM AccountShare WHERE AccountId IN :accIdAndSitesMap.keySet()]) {
                    for(Sites__c site : accIdAndSitesMap.get(accShare.AccountId)) {
                        
                        Sites__Share siteShare = NULL;
                        if(!brokerProfileIds.contains(accShare.UserOrGroup.ProfileId) || site.Submitter__c == accShare.UserOrGroupId) {
                            siteShare = SharingWizardController.generateSiteShare(accShare.UserOrGroupId, site.Id);
                        }
                        if(siteShare != NULL) createSiteShares.add(siteShare); 
                    }
                }
            }
            
            if(rmvShareSiteIds.size() > 0 && rmvShareUserIds.size() > 0) {
                
                Set<Id> finalDelUserIds = new Set<Id>();
                
                for(User u : [SELECT ID,ProfileId FROM User WHERE Id IN :rmvShareUserIds]) {
                    if(brokerProfileIds.contains(u.ProfileId)) {
                        finalDelUserIds.add(u.Id);
                    }
                }
                
                delete [SELECT Id FROM Sites__Share WHERE ParentId IN :rmvShareSiteIds AND UserOrGroupId IN :finalDelUserIds];
            }
                        
            if(createSiteShares.size() > 0) {
                
                Set<String> keys = new Set<String>();
                Set<Id> prntIds = new Set<Id>();
                Set<Id> userIds = new Set<Id>();
                List<Sites__Share> finalShareList = new List<Sites__Share>();
                
                for(Sites__Share siteShare : createSiteShares) {
                    prntIds.add(siteShare.ParentId);
                    userIds.add(siteShare.UserOrGroupId);
                }

                for(Sites__Share siteShare : [SELECT Id,ParentId,UserOrGroupId FROM Sites__Share WHERE ParentId IN :prntIds AND UserOrGroupId IN :userIds]) {
                    keys.add(String.valueOf(siteShare.ParentId) + String.valueOf(siteShare.UserOrGroupId));
                }

                Set<Id> communityUserIds = new Set<Id>();

                for(Sites__Share siteShare : createSiteShares) {
                    if(!keys.contains(String.valueOf(siteShare.ParentId) + String.valueOf(siteShare.UserOrGroupId))) {
                        if ( (String.valueOf(siteShare.UserOrGroupId).startsWith('005'))){
                            communityUserIds.add(siteShare.UserOrGroupId);
                        }
                    }
                }
                
                Map<Id, User> communityUsers = new Map<Id, User>(
                    [SELECT Id FROM User WHERE Id IN :communityUserIds AND IsActive = TRUE AND ContactId <> NULL]
                );
                
                for(Sites__Share siteShare : createSiteShares) {
                    if(!keys.contains(String.valueOf(siteShare.ParentId) + String.valueOf(siteShare.UserOrGroupId))) {
                        if ( communityUsers.containsKey(siteShare.UserOrGroupId) ){
                            finalShareList.add(siteShare);
                        }
                    }
                }                

                if(finalShareList.size() > 0) insert finalShareList;
            }
        }
    }    
}