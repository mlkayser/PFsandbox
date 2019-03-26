public without sharing class PFLinksFooterSectionController {
    
    public Boolean isAMVisibility { get; set; }
    public Boolean isSharingAccess { get; set; }
    public String ssoAccess { get; set; }
    public Boolean isCognosUser {get; set;}
    public Boolean isEmailMarketingUser {get; set;}
    public Boolean isMarketingSpendUser {get; set;}

    
    public PFLinksFooterSectionController() {
        
        isSharingAccess = FALSE;
        isCognosUser = false;
        isEmailMarketingUser = false;
        isMarketingSpendUser = false;

        Id profId = UserInfo.getProfileId();
        List<SetupEntityAccess> sea = [SELECT Id FROM SetupEntityAccess WHERE SetupEntityId IN (SELECT Id FROM ApexPage WHERE Name = 'SharingWizard') AND Parent.Profile.Id = :profId];
        
        List<User> usr = [SELECT SSO_Access__c FROM User where id = :UserInfo.getUserId() AND SSO_Access__c INCLUDES('COGNOS', 'Marketing Cloud', 'Marketing Spend')];
        
        if ( usr.isEmpty() == false ){
            List<String> ssoAccesses = usr[0].SSO_Access__c.split(';');
            for(String ssoAccess : ssoAccesses){
                if(ssoAccess.trim().equalsIgnoreCase('cognos')) isCognosUser = true;
                if(ssoAccess.trim().equalsIgnoreCase('marketing cloud')) isEmailMarketingUser = true;
                if(ssoAccess.trim().equalsIgnoreCase('marketing spend')) isMarketingSpendUser = true;
            }
        }
        
        //isCognosUser = (!usr.isEmpty() && usr[0].SSO_access__c.indexOfIgnoreCase('COGNOS') != -1);
        //ssoAccess = String.isNotBlank(usr[0].SSO_Access__c) ? usr[0].SSO_Access__c : '';
        
        System.debug(':::sea:::' + sea);
        
        if(!sea.isEmpty()) {
            isSharingAccess = TRUE;
        }  
                
        isAMVisibility = [SELECT Name FROM Profile WHERE Id = :profId].Name == 'Customer Community User - Legal Owner';
    }
}