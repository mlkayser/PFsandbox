public class CaseHelper {
    public static void populateAccountLookup(list<Case> cases) {
        for (Case c : cases) {
            if (c.Web_Account_Id__c != null && c.Web_Account_Id__c  != '') {
                c.AccountId = c.Web_Account_Id__c;
            }
        }
    }
    

    public static void shareCase( List< Case > a_case ) {
        Set< ID > l_acc_id = new Set< ID >();

        for ( Case c : a_case ) {
            l_acc_id.add( c.AccountID );
        }

        Map<ID , List<User>> accIdToUserMap = new Map<ID , List<User>>();

        for( User u : [ Select ContactId, 
                               Contact.Account.Group_Name__c, 
                               Contact.AccountId , 
                               Contact.Account.PF_Club_ID__c,
                               Club_Access__c,
                               AccountId
                        From User 
                        Where Contact.AccountId IN :l_acc_id and 
                             ( Profile.Name = 'Customer Community User - Corp Club Manager' or 
                               Profile.Name = 'Customer Community User - Club Manager')] )
        {
            List<User> l_aux = new List<User>();

            if( accIdToUserMap.containsKey( u.Contact.AccountId ) )
            {
                l_aux = accIdToUserMap.get( u.Contact.AccountId );
            }
            l_aux.add( u );

            accIdToUserMap.put( u.Contact.AccountId , l_aux );

        }

        List<CaseShare> newCaseShares = new List<CaseShare>();

        for ( Case c : a_case ) {
            List< User > l_users = accIdToUserMap.get( c.AccountID );
            if( l_users != null && l_users.size() > 0) {
                for( User u : l_users )
                {
                    CaseShare cs = new CaseShare();
                    cs.CaseID = c.id;
                    cs.UserOrGroupId = u.id;
                    cs.RowCause = 'Manual';
                    cs.CaseAccessLevel = 'Read';

                    newCaseShares.add( cs );
                }

            }
        }

        if ( newCaseShares.size() > 0 ) {
            Database.insert( newCaseShares , false );
        }        

    }

    public static void removeShareCase( List< Case > a_case , Map< Id , Case > a_old_case_map ) {
        
        Set< ID > l_acc_id = new Set< ID >();

        for( Case c : a_case ) {
            if ( c.AccountID != a_old_case_map.get( c.id ).AccountID ) {
                l_acc_id.add( a_old_case_map.get( c.id ).AccountID );
            }
        }

         Map< ID, User > l_user = new Map<ID, User>([ Select ContactId, 
                                                               Contact.Account.Group_Name__c, 
                                                               Contact.AccountId , 
                                                               Contact.Account.PF_Club_ID__c,
                                                               Club_Access__c,
                                                               AccountId
                                                        From User 
                                                        Where Contact.AccountId IN :l_acc_id and 
                                                             ( Profile.Name = 'Customer Community User - Corp Club Manager' or 
                                                               Profile.Name = 'Customer Community User - Club Manager')]);

        if ( l_user.size() > 0 ) {
            List<CaseShare> cShares = [select Id  from CaseShare where CaseId in :a_old_case_map.keySet() AND UserOrGroupID IN: l_user.keySet() and RowCause = 'Manual'];

            if ( !cShares.isEmpty() ) {
                Delete cShares;
            }
        }

    }
    
}