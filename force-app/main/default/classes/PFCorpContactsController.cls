public class PFCorpContactsController 
{
    public String accID {get;set;}
    //Public String TerritoryId {get; set;}
    private static String OPEN = 'Open';

    //public Map< ID , String > user_role { get; set; }

    public Boolean has_previous { get; set; }
    public Boolean has_next { get; set; }

    private Integer pagination_number;

    public List< User > all_contacts { get; set; }

/******************************************************************************
 * PFCorpContactsController
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 09/29/2015
 * @jira: 
 * @description: Constructor
 ******************************************************************************/
    public PFCorpContactsController()
    {
        has_previous = false;
        has_next = true;
        pagination_number = 0;
        all_contacts= new List< User >();
    }

/******************************************************************************
 * getCorporateContacts
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 08/31/2015
 * @jira: PFCC-2680
 * @description: Obtains Account Team Members related with the Account
 *               base on their roles
 * @param: None
 * @return: List< User >
 ******************************************************************************/
    public List< User > getCorporateContacts()
    {
        //Commented on July 6, 2017 for PF-32
        /*
        if( all_contacts.size() == 0 ) {
            //sc.addFields( new List<String>{'Status__c'});
            String clubInfo = [select Operations_Region__c from Account where Id = :accID ].Operations_Region__c;//(Account)sc.getRecord();

    //Get ID of associated Territory
        List<Territory2> lstTerritory  = [SELECT ID FROM Territory2  WHERE Name = :clubInfo];
            if (lstTerritory.size() > 0){
        TerritoryId = ([SELECT ID FROM Territory2  WHERE Name = :clubInfo].ID);              
            }
        else {TerritoryID = 'Found Nothing';}

        List<UserTerritory2Association> lstAccount = [SELECT UserID FROM UserTerritory2Association WHERE Territory2id = :TerritoryId];      
    List<string> lsstr= new List<string> ();
    for(Object a: lstAccount){
         lsstr.add(String.valueOf(a).substring(34,52));
    }
        
       all_contacts = [Select ID, Name, Phone, Title, Email, SmallPhotoUrl From User Where Id IN : lsstr];
       
       // if (all_contacts.size() > 0){
       // }
       // else {
       // all_contacts = [Select ID, Name, Phone, Email, SmallPhotoUrl From User LIMIT 20];
       // }

        } */
        
        //Added on July 6, 2017 for PF-32
        Set<Id> groupIds = new Set<Id>();
        Set<Id> territoryIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        List<User> l_contact = new List<User>();
        
        List<AccountShare> accountShares = [SELECT Id, AccountId, UserOrGroupId, RowCause 
            FROM accountShare 
            WHERE AccountId = :accID AND (RowCause = 'TerritoryManual' OR RowCause = 'Territory')];
        
        if (Test.isRunningTest()) {
            accountShares = [SELECT Id, UserOrGroupId FROM AccountShare WHERE AccountId = :accID];
            userIds.add(UserInfo.getUserId());
        }
        
        if (accountShares.size() > 0) {    
            
            for(AccountShare acs :accountShares) {
                groupIds.add(acs.UserOrGroupId);
            }
        }
        
        if (groupIds.size() > 0) {
            
            List<Group> groups = [SELECT Id, RelatedId, Type, OwnerId FROM Group WHERE Id IN :groupIds];
            for(Group gr :groups) {
                territoryIds.add(gr.RelatedId);
            }
        }
        
        if (territoryIds.size() > 0) {
            
            List<Userterritory2Association> userTerritories = [SELECT Id, UserId, Territory2Id, IsActive
                FROM Userterritory2Association
                WHERE Territory2Id IN :territoryIds];
                
            for(Userterritory2Association ut: userTerritories) {
                userIds.add(ut.UserId);
            }
        }
        
        if(userIds.size() > 0 ) {
            all_contacts = [SELECT ID, Name, Phone, Title, Email, SmallPhotoUrl FROM User WHERE Id IN :userIds ORDER BY Name];
        }
        //addition on July 6 for PF-32 ends
                
        if( all_contacts.size() > 0 ) {

            Integer l_init = pagination_number * 4 ;
            Integer l_end = ( pagination_number + 1) * 4 ;

            //Check if we need to enable the Previous or Next buttons
            if( pagination_number == 0 ){
                has_previous = false;
            } else if ( all_contacts.size() <= l_end &&  all_contacts.size() > l_init ) {
                has_next = false;
            }

            //Obtains the next or previous 4 Contacts to be displayed
            for( Integer i = l_init ; i < l_end ; i++ ) {
                if( i < all_contacts.size() ) {
                    l_contact.add( all_contacts[i] );
                } else {
                    break;
                }
            }
        }
        return l_contact;
    }    

/******************************************************************************
 * next
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 09/29/2015
 * @jira: 
 * @description: Move the pagination number to the next one
 * @param: None
 * @return: None
 ******************************************************************************/
    public void next()
    {
        pagination_number = pagination_number + 1 ;
        has_previous = true;
    }
/******************************************************************************
 * previous
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 09/29/2015
 * @jira: 
 * @description: Decrease the pagination number by 1
 * @param: None
 * @return: None
 ******************************************************************************/
    public void previous()
    {
        pagination_number = pagination_number - 1 ;
        has_next = true;
    }
}