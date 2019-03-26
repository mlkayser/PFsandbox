public class DevelopmentObligationClubController {
    
    public DevelopmentObligationClubController() {
        System.debug(' ');
        System.debug('*** DevelopmentObligationClubController');

        Integer ii = 0;
        Integer jj = 0;
        ADA_Schedule__c schedule = new ADA_Schedule__c();
        List<ADA_Schedule__c> DevObligation_ShortList = new List<ADA_Schedule__c>();
        List<ADA_Schedule__c> DevObligation_ToUpdate = new List<ADA_Schedule__c>();
        List<Account> Clubs_ToUpdate = new List<Account>();

        // Get all ADA records with Status = Active
        List<PFAgreement__c> ADA_List = [
            SELECT id, Name, ADA_Status__c
            FROM PFAgreement__c
            WHERE RecordType.Name = 'Area Development Agreement'
            AND ADA_Status__c = 'Active'
            ORDER BY Id
        ];
 
        if (Test.isRunningTest()) {
            ADA_List = [
                SELECT id, Name, ADA_Status__c
                FROM PFAgreement__c
                WHERE Name LIKE 'TestADA%'
                ORDER BY Id
            ];
        }
       System.debug('*** Total ADAs = ' + ADA_List.size());

        // Get all Development Obligations records with Status = Unmet
        List<ADA_Schedule__c> DevObligation_List = [
            SELECT id, Club__c, Name, Development_Obligation_Status__c, Area_Development_Agreement__c
            FROM ADA_Schedule__c
            WHERE Development_Obligation_Status__c = 'Unmet'
            ORDER BY Area_Development_Agreement__c, Name
        ];
        System.debug('*** Total Obligation Schedules = ' + DevObligation_List.size());

        List<Account> Club_List = [
            SELECT id, Name, Status__c, Project_Open_Date__c, Project_Status__c, Area_Development_Agreement__c
            FROM Account
            WHERE Project_Open_Date__c != NULL
            AND (Status__c = 'Active Development' OR Status__c = 'Presale' OR Status__c = 'Site Planning')
            AND (Project_Status__c != 'Dead' OR Project_Status__c = 'On Hold')
            ORDER BY Area_Development_Agreement__c, Project_Open_Date__c
        ];
        System.debug('*** Total clubs = ' + Club_List.size());
        
        // Process all ADA records with Status = Active
        for (PFAgreement__c ADA : ADA_List) {
            // Clear shortlist
            DevObligation_ShortList.clear();
            ii = 0;
            System.debug('');
            System.debug('*** ADA Iteration = ' + jj);
            System.debug('*** ADA ID = ' + ADA.id + ' ' + ADA.name);

            // Build shortlists
            for (ADA_Schedule__c obligation : DevObligation_List) {
                if (obligation.Area_Development_Agreement__c == ADA.id) {                
                    //System.debug('*** ADA ID = ' + obligation.Area_Development_Agreement__c + ', obligation ID = ' + obligation.id);
                    DevObligation_ShortList.add(obligation);
                }
                else continue;
            }
            System.debug('*** Total developemnt obligations for this ADA = ' + DevObligation_ShortList.size());

            // process all clubs
            for (Account club: Club_List) {
                if (club.Area_Development_Agreement__c == ADA.id) {
                    schedule = DevObligation_ShortList[ii];
                    schedule.club__c = club.id;
                    DevObligation_ToUpdate.add(schedule);
                    club.Development_Obligation__c = schedule.id;
                    Clubs_ToUpdate.add(club);                    
                    System.debug('*** Iteration = ' + ii + ' obligation ID = ' + schedule.id + ' Club ID = ' + club.id);
                    ii++;
                }
                else continue;
            }             
            
            jj++;
            
        }

        System.debug('*** Total Development Obligations to update = ' + DevObligation_ToUpdate.size());
        update DevObligation_ToUpdate;
        update Clubs_ToUpdate;

    }
}