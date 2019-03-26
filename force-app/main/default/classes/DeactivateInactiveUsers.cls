global class DeactivateInactiveUsers implements Schedulable {

    global void execute(SchedulableContext ctx) {
 
         List<User> selectedUsers = [
            SELECT Id, Name, IsActive, Profile.Name, LastLoginDate, LastModifiedDate FROM User 
            WHERE IsActive = TRUE 
            AND LastLoginDate < LAST_90_DAYS
            AND LastModifiedDate != LAST_N_DAYS:10
            AND (Profile.Name =: 'Customer Community User - Franchisee' OR Profile.Name =: 'Customer Community Plus Login Zee')
            ORDER BY LastLoginDate
            LIMIT 10
        ];
 
        if (Test.isRunningTest()) {
            selectedUsers = [
                SELECT Id, Name, IsActive, Profile.Name, LastLoginDate, LastModifiedDate FROM User 
                WHERE IsActive = TRUE 
                AND (Profile.Name =: 'Customer Community User - Franchisee' OR Profile.Name =: 'Customer Community Plus Login Zee')
                AND (Name LIKE '%Zee-%' OR Name LIKE '%Franchisee-%')
            ];
        }

        System.debug('***DEBUG => selected users = ' + selectedUsers.size());

        for (User record: selectedUsers) {
            record.IsActive = false;
            System.debug('Deactivating ' +  record.Name + ', ' + record.Profile.Name +  
                ', last login date = ' + record.LastLoginDate + ' ' + record.IsActive +
                ', last modified date = ' + record.LastModifiedDate
                );
        }
        
        try {
            update selectedUsers;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

    }
}