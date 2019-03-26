/**
* Class that utility test methods
* 
* @Date: 9/3/2015
* @Author: Andres Di Geronimo-Stenberg (Magnet360)
*/

@isTest
public with sharing class PFTestUtility {

    private static Profile Community_profile {
        get {
            if (Community_profile==null){
                Community_profile = [
                    Select id 
                    from Profile 
                    //Where Name=: 'Customer Community User - Broker' 
                    Where Name=: 'Customer Community User - Legal Owner'
                    limit 1
                ];
            }
            return Community_profile;
        } set;
    }

    public static Profile manager_profile {
        get {
            if (manager_profile==null){
                manager_profile = [
                    Select id 
                    from Profile 
                    Where Name=: 'Customer Community User - Corp Club Manager' 
                    limit 1
                ];
            }
            return manager_profile;
        } set;
    }    

    private static UserRole user_role {
        get {
            if (user_role==null){
                user_role = [
                    Select id 
                    from UserRole 
                    Where Name = :'Systems Engineer' 
                    limit 1
                ];
            }
            return user_role;
        } set;
    }    

    private static RecordType contact_owner_rt {
        get {
            if (contact_owner_rt == null ){
                contact_owner_rt = [
                    Select id 
                    from RecordType 
                    Where Name=: 'Owner Contact' 
                    And SobjectType = 'Contact' 
                    limit 1
                ];
            }
            return contact_owner_rt;
        } set;
    }
    
    public static RecordType contact_club_staff_rt {
        get{
            if (contact_club_staff_rt == null ){
                contact_club_staff_rt = [
                    Select id 
                    from RecordType 
                    Where Name=: 'Club Staff' 
                    And SobjectType = 'Contact' 
                    limit 1
                ];
            }
            return contact_club_staff_rt;
        } set;
    }
    
    public static RecordType owner_holding_account_rt {
        get{
            if (owner_holding_account_rt == null ){
                owner_holding_account_rt = [
                    Select id 
                    from RecordType 
                    Where Name=: 'Owner Holding Account' 
                    And SobjectType = 'Account' 
                    limit 1
                    ];
            }
            return owner_holding_account_rt;
        } set;
    }

    public static RecordType vendor_account_rt {
        get {
            if (vendor_account_rt == null ){
                vendor_account_rt = [
                    Select id 
                    from RecordType 
                    Where Name=: 'Vendor' 
                    And SobjectType = 'Account' 
                    limit 1
                ];
            }
            return vendor_account_rt;
        } set;
    }

    public static RecordType club_location_account_rt {
        get {
            if (club_location_account_rt == null ){
                club_location_account_rt = [
                    Select id 
                    from RecordType 
                    Where Name=: 'Club Location' 
                    And SobjectType = 'Account' 
                    limit 1
                ];
            }
            return club_location_account_rt;
        } set;
    }    

    public static RecordType getLocationRT() {
        RecordType l_club_location  = [ 
            Select Id 
            From RecordType 
            Where Name = 'Club Location' 
            And SobjectType = 'Account' 
        ];
        return l_club_location;
    }

    public static void initCustomSetting() {
        Community_Settings__c l_comm_settings =  new Community_Settings__c();
        l_comm_settings.CorporateContactRoles_OpenClub__c = 'Brand Excellence Specialist,Corporate Operations Director';
        l_comm_settings.CorporateContactRoles_InDevelopment__c = 'Marketing Area Manager';
        l_comm_settings.CorporateContactRoles_InDevelopment_2__c = 'Operations Area Manager';
        l_comm_settings.Club_Image_Name__c = 'club-image.jpg';
        insert l_comm_settings;        
    }

    public static User getCurrentUser() {
        return [ 
            select Id, UserRoleID, UserPermissionsKnowledgeUser 
            from User 
            where Id = :UserInfo.getUserId() 
        ];
    }

    public static void checkUserRole(User u) {
        if ( u.UserRoleID == null ) {
            u.UserRoleID = user_role.id;
            update u;
        }               
    }

    public static void setKnowledgeUser(User u) {
        u.UserPermissionsKnowledgeUser = true;
        update u;                
    }    

    public static User createTestUser(String firstName, String lastName, String email, String userName, Id profileId, Contact c) {
        System.debug('**** DEBUG createTestUser');
        System.debug('**** DEBUG createTestUser == First Name = ' + firstName);

        User user = new User();
        if ( profileId != null ) {
            user.ProfileID = profileId;
        }
        else {
            user.ProfileID = [ Select Id from Profile Where Name = :'System Administrator' limit 1 ].id;
        }
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = firstName;
        user.LastName = lastName;
        user.Username = userName;   
        user.Alias = lastName.substring(0,5);
        user.Email = email;
        user.IsActive = true;
        if ( c !=null ) {
            user.ContactId = c.Id;
            user.CommunityNickname = userName;
        }

        System.debug('**** DEBUG createTestUser ==> User first Name = ' + user.FirstName);

        return user;
    }

    public static Retail_Product__c createProduct(String a_category) {
        Retail_Product__c rp_1 = new Retail_Product__c();
        rp_1.Name = 'Product Name';
        rp_1.Barcode__c = String.valueOf(Math.random());
        rp_1.Category__c = a_category;
        return rp_1;
    }

    public static User communityUser(String firstName, String lastName, String email, String userName) {
        Account acc = new Account(Name='Owner Holding Account', RecordTypeID = owner_holding_account_rt.id);
        insert acc;

        Contact con = new Contact(LastName = 'Contact Last Name', AccountId = acc.id, RecordTypeID = contact_owner_rt.id);
        insert con;

        User l_community_user = createTestUser(firstName, lastName, email, userName, Community_profile.Id, con);
        return l_community_user;
    }

    public static User customCommunityUser(String firstName, String lastName, String email, String userName, String profileName) {
        Account acc = new Account(Name='Owner Holding Account', RecordTypeID = owner_holding_account_rt.id);
        insert acc;

        Contact con = new Contact(LastName = 'Contact Last Name', AccountId = acc.id, RecordTypeID = contact_owner_rt.id);
        insert con;

        Profile profile = [
                    Select id 
                    from Profile 
                    Where Name =: profileName
                    limit 1
                ];
        System.debug('**** DEBUG profileID ==> ' + profile.Id);
        
        User l_community_user = createTestUser(firstName, lastName, email, userName, profile.Id, con);
        return l_community_user;
    } 
    
    public static Contact createOwnerContact(String firstName, String lastName, String email, String userName) {
        Account acc = new Account(
            Name='Owner Holding Account', 
            RecordTypeID = owner_holding_account_rt.id
        );
        insert acc;

        Contact con; 

        IF (firstName != NULL && firstName != NULL && email != NULL) {
            con = new Contact(
                FirstName = FirstName,
                LastName = LastName, 
                Email = Email,
                AccountId = acc.id, 
                RecordTypeID = contact_owner_rt.id
            );
        }
        else { 
            con = new Contact(
                LastName = 'Contact Last Name', 
                AccountId = acc.id, 
                RecordTypeID = contact_owner_rt.id
            );
        }
        //insert con;

        return con;
    }
   
}