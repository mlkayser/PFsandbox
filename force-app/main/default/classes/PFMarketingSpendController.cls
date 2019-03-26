global with sharing class PFMarketingSpendController {
    public String selectedGroup { get; set; }
    
    public Boolean showMonth {
        /*get {
            List<Group__c> theGroups = getAssignedGroups();
            Set<String> mySet = new Set<String>(); 
            For (Group__c gg :theGroups){ 
                mySet.add(gg.Name);
            }
            showMonth = mySet.contains('G0239-UNITED PF PARTNERS');
            return showMonth;
        }
        set {
            showMonth = TRUE;
        }*/
        get {
            return TRUE;   
        }
    }

    @RemoteAction
    global static List<Account> getClubs(String g) {
        List<Account> clubs = [
            SELECT PF_Club_ID__c, Group_Name__c, Group_Number__c, Id, Name, Date_Opened__c, Presale_Date__c 
            FROM Account
            WHERE Group_Name__c IN (SELECT Id from Group__c where Name = :g) 
            //AND Status__c in ('Open', 'Online Presale', 'In Presale')
            AND Status__c in ('Open', 'Presale')
            ORDER BY PF_Club_ID__c ASC 
        ];
        return clubs;
    }

    // Returns JSON representation of List<ComplianceStatus> for the logged in community user
    @RemoteAction
    global static List<ComplianceStatus> getComplianceStatus(String groupName, Integer year, Integer monthOptional) {
        List<ComplianceStatus> result = new List<ComplianceStatus>();
        
        // Get Assigned Groups
        List<Group__c> assignedGroups = getAssignedGroups();
        System.debug('assignedGroups = ' + assignedGroups);

        for (Group__c g : assignedGroups) {
            if (!g.Name.equals(groupName)) {
                continue; // Only looking for the compliance status for the provided group
            }
            ComplianceStatus cs = new ComplianceStatus();
            cs.groupName = g.Name;
            cs.complianceStatusItems = new List<ComplianceStatusItem>();

            // Get List of Clubs for this Group
            List<Account> clubs = getClubs(g.Name);
            
            // Get List of all Compliances for this group            
            List<Compliance__c> compliances = getCompliances(g.Name, year);
            
            // Return ComplianceStatusItem records for a single month
            if (monthOptional != NULL) {
                Integer month = monthOptional;
                List<String> totals = getAllCompInfo(clubs, compliances, month, year);
                cs.complianceStatusItems.add(
                    new ComplianceStatusItem(
                        month,
                        year,
                        integer.valueof(totals[0]), //totComp
                        integer.valueof(totals[1]), //totClub
                        decimal.valueof(totals[2]) //totSpend
                   )
                );               
            }

            // Return ComplianceStatusItem records for each month
            else {
                for (Integer i=1; i<=12; i++) {
                    //for (Integer i=1; i<=2; i++) {    
                    Integer month = i;

                    /*cs.complianceStatusItems.add(
                        new ComplianceStatusItem(
                            month,
                            year,
                            getCompliantClubsCount(clubs, compliances, month, year),
                            getTotalClubsCount(clubs, month, year),
                            getTotalGroupSpend(clubs, compliances, month, year)
                        )
                    );*/

                    List<String> totals = getAllCompInfo(clubs, compliances, month, year);
                    cs.complianceStatusItems.add(
                            new ComplianceStatusItem(
                                month,
                                year,
                                integer.valueof(totals[0]), //totComp
                                integer.valueof(totals[1]), //totClub
                                decimal.valueof(totals[2]) //totSpend
                           )
                    );               
                }
            }   

            result.add(cs);
        }

        return result;
    }

    public List<SelectOption> getGroupNames() {
        List<Group__c> assignedGroups = getAssignedGroups();
        List<SelectOption> results = new List<SelectOption>();
        for (Group__c g : assignedGroups) {
            results.add(new SelectOption(g.Name, g.Name));
        }
        return results;
    }

    private static List<Group__c> getAssignedGroups() {
        ID userId = UserInfo.getUserId();
        List<User> users = [SELECT User.ContactId FROM User WHERE Id=:userId];
        ID contactId;
        contactId = users[0].ContactId;
        List<Group__c> assignedGroups = [
            SELECT Name 
            FROM Group__c 
            WHERE Group_Status__c='Active' 
            AND Id IN (SELECT Group_Num__c FROM Group_Owner__c WHERE Owner_Contact__c=:contactId) 
            ORDER BY Name ASC
        ];
        return assignedGroups;
    }

    private static List<Compliance__c> getCompliances(String g, Integer year) {
        if (Test.isRunningTest()){
            Id rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Club_Marketing_Compliance'][0].id;
            List<Compliance__c> results = [
                SELECT Id, Name, mspend_Spend_Month__c, Club__r.Group_Name__r.Name, Total_Marketing_Spend__c  
                FROM Compliance__c 
                WHERE Club__r.Group_Name__r.Name = :g 
                AND RecordTypeId = :rt
            ];
            return results;
        }
    
        Community_Settings__c cs = [SELECT Marketing_Spend_Record_Type_ID__c from Community_Settings__c LIMIT 1];
        /*List<Compliance__c> results = [
            SELECT Id, Name, mspend_Spend_Month__c, Year__c, Club__r.Group_Name__r.Name, Total_Marketing_Spend__c, Club__r.Name  
            FROM Compliance__c 
            WHERE Club__r.Group_Name__r.Name = :g 
            AND RecordTypeId = :cs.Marketing_Spend_Record_Type_ID__c
            AND Year__c = :String.valueOf(year)
        ];*/
        List<Compliance__c> results = [
            SELECT Id, mspend_Spend_Month__c, Total_Marketing_Spend__c, Club__r.Name  
            FROM Compliance__c 
            WHERE Club__r.Group_Name__r.Name = :g 
            AND RecordTypeId = :cs.Marketing_Spend_Record_Type_ID__c
            AND Year__c = :String.valueOf(year)
        ];
    
        return results;
    }

    // Return # of clubs, # of compliant clubs, and total spend for clubs that have been active after the provided month and year
    private static List<String> getAllCompInfo(List<Account> clubs, List<Compliance__c> compliances, Integer month, Integer year) {
        Integer totalComp = 0;
        Integer totalClub = 0;
        Decimal totalSpend = 0;
        List<String> totals = new List<String>();
        //Datetime dt = DateTime.newInstance(year, month, 1, 23, 59, 59);
        Datetime dt = DateTime.newInstance(year, month, 1, 23, 59, 59).addMonths(1).addDays(-1); // include all clubs opened in specified month
        System.debug('***DEBUG month = ' + month);

        for (Account club : clubs) {
                        
            // Open before this month/year or Presale date before this month/year
            if ((club.Date_Opened__c != null && club.Date_Opened__c <= dt) || (club.Presale_Date__c != null && club.Presale_Date__c <= dt)) { 
                // total # of clubs
                totalClub++;

                System.debug('***DEBUG club = ' + club.Name);

                // total # of compliances
                for (Compliance__c comp : compliances) {
                    if (comp != null && comp.mspend_Spend_Month__c != null) { // Exclude non Marketing Spend records
                        Datetime cdt = Datetime.newInstance(comp.mspend_Spend_Month__c.year(), comp.mspend_Spend_Month__c.month(), 1);
                        if (comp.Club__c == club.Id && cdt.month() == dt.month() && cdt.year() == dt.year()) {
                            totalComp++;
                        }
                    }
                }

                for (Compliance__c comp : compliances) {
                    Datetime cdt = Datetime.newInstance(comp.mspend_Spend_Month__c.year(), comp.mspend_Spend_Month__c.month(), 1);
                    if (comp.Club__c == club.Id && cdt.month() == dt.month() && cdt.year() == dt.year()) {
                        totalSpend += comp.Total_Marketing_Spend__c;
                    }
                }
            }        
        }
 
        totals.add(String.valueOf(totalComp));
        totals.add(String.valueOf(totalClub));
        totals.add(String.valueOf(totalSpend));
    
        return totals;
    }

    // Return the number of compliant clubs that have been active after the provided month and year
    /*private static Integer getCompliantClubsCount(List<Account> clubs, List<Compliance__c> compliances, Integer month, Integer year) {
        Integer compliantCount = 0;
        Datetime dt = DateTime.newInstance(year, month, 1);
 
        for (Account club : clubs) {
            //Datetime dt = DateTime.newInstance(year, month, 1);
            if ((club.Date_Opened__c != null && club.Date_Opened__c <= dt) || (club.Presale_Date__c != null && club.Presale_Date__c <= dt)) { // Open before this month/year
                // if( c.Date_Opened__c <= dt) { // Open before this month/year
                for (Compliance__c comp : compliances) {
                    if (comp != null && comp.mspend_Spend_Month__c != null) { // Exclude non Marketing Spend records
                        Datetime cdt = Datetime.newInstance(comp.mspend_Spend_Month__c.year(), comp.mspend_Spend_Month__c.month(), 1);
                        if (comp.Club__c == club.Id && cdt.month() == dt.month() && cdt.year() == dt.year()) {
                            compliantCount++;
                        }
                    }
                }
            }
        }

        return compliantCount;
    }*/

    // Return the total number of clubs that have been active after the provided month and year
    /*private static Integer getTotalClubsCount(List<Account> clubs, Integer month, Integer year) {
        Integer totalCount = 0;
        Datetime dt = DateTime.newInstance(year, month, 1);
 
        for (Account club : clubs) {
            //Datetime dt = DateTime.newInstance(year, month, 1);
            if ((club.Date_Opened__c != null && club.Date_Opened__c <= dt) 
            || (club.Presale_Date__c != null && club.Presale_Date__c <= dt)) { // Open before this month/year or Presale date before this month/year
        // if(c.Date_Opened__c != null && c.Date_Opened__c <= dt) { // Open before this month/year or Presale date before this month/year
                totalCount++;
            }
        }

        return totalCount;
    }*/

    // Return the total spend for all clubs for this month and year
    /*private static Decimal getTotalGroupSpend(List<Account> clubs, List<Compliance__c> compliances, Integer month, Integer year) {
        Decimal totalSpend = 0;
        Datetime dt = DateTime.newInstance(year, month, 1);

        for (Account club : clubs) {
            //Datetime dt = DateTime.newInstance(year, month, 1);
            if (club.Date_Opened__c <= dt) { // Open before this month/year
                for (Compliance__c comp : compliances) {
                    Datetime cdt = Datetime.newInstance(comp.mspend_Spend_Month__c.year(), comp.mspend_Spend_Month__c.month(), 1);
                    if (comp.Club__c == club.Id && cdt.month() == dt.month() && cdt.year() == dt.year()) {
                        totalSpend += comp.Total_Marketing_Spend__c;
                    }
                }
            }
        }

        return totalSpend;
    }*/

    global class ComplianceStatus {
        public String groupName;
        public List<ComplianceStatusItem> complianceStatusItems;
    }

    global class ComplianceStatusItem {
        public Integer month;
        public Integer year;
        public Integer compliantClubs;
        public Integer totalClubs;
        public Decimal totalSpend;

        public ComplianceStatusItem(Integer month, Integer year, Integer compliantClubs, Integer totalClubs, Decimal totalSpend) {
            this.month = month;
            this.year = year;
            this.compliantClubs = compliantClubs;
            this.totalClubs = totalClubs;
            this.totalSpend = totalSpend;
        }
    }

}