global with sharing class PFVoteController {
    @RemoteAction
    global static Poll__c getPoll(String pollId) {
        List<Poll__c> polls = [SELECT Id,Name,Question__c,Poll_Type__c FROM Poll__c where Id=:pollId];
        return polls.size() > 0 ? polls.get(0) : null;
    }

    @RemoteAction
    global static List<Poll__c> getActivePolls() {
        ID userId = UserInfo.getUserId();
        List<User> users = [SELECT User.ContactId FROM User WHERE Id=:userId];
        ID contactId;
        contactId = users[0].ContactId;
        List<PollResult__c> submittedResults = [SELECT Id,Name,Poll__c,Club__c FROM PollResult__c where CreatedById=:userId];
        Date today = Date.today();
        List<Poll__c> polls = [SELECT Id,Name,Question__c,Poll_Type__c FROM Poll__c where Active__c=true and (Start_Date__c <= :today and End_Date__c >= :today)];

        Id rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Franchise_Agreement' LIMIT 1].Id; // @TODO Put in custom settings
        List<Id> agreementIds = PFAgreement.getAgreementsForResponsibleOwner(contactId, rt);

        List<Account> clubsImROFor = [SELECT Id,Name from Account where Id IN :agreementIds];
        List<Poll__c> results = new List<Poll__c>();
        for(Poll__c p : polls) {
            Boolean requiresVote = false;
            List<PollResult__c> thisPollsResults = getResultsForPoll(submittedResults, p);
            List<Account> clubsThatVotedForThisPoll = getClubsThatVotedForPoll(clubsImROFor, thisPollsResults);
            if(clubsThatVotedForThisPoll.size() == 0) {
                results.add(p);
            }
//            for(PollResult__c r : thisPollsResults) {
//                for(Account c : clubsImROFor) {
////                    if(p.Id == r.Poll__c && c.Id != r.Club__c) {
//                    if(c.Id == r.Club__c) {
//                        requiresVote = true;
//                        break;
//                    }
//                }
//            }
//            if(clubsImROFor.size()) {
//                results.add(p);
//            }
        }
        return results;
    }

    @RemoteAction
    global static List<PollOption__c> getPollOptions(String pollId) {
        List<PollOption__c> pollOptions = [SELECT Name,Poll__c FROM PollOption__c where Poll__c = :pollId order by Order__c];
        return pollOptions;
    }

    @RemoteAction
    global static List<Account> getClubs() {
        ID userId = UserInfo.getUserId();
        List<User> users = [SELECT User.ContactId FROM User WHERE Id=:userId];
        ID contactId;
        contactId = users[0].ContactId;
        Id rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Franchise_Agreement' LIMIT 1].Id; // @TODO Put in custom settings
        List<Id> agreementIds = PFAgreement.getAgreementsForResponsibleOwner(contactId, rt);
        List<Account> clubs = [SELECT PF_Club_ID__c,Group_Name__c,Group_Number__c,Id,Name,Date_Opened__c,Presale_Date__c FROM Account
        WHERE Status__c in ('Open') and Id IN :agreementIds order by Name];
        return clubs;
    }

    private static List<PollResult__c> getResultsForPoll(List<PollResult__c> pollResults, Poll__c poll) {
        List<PollResult__c> results = new List<PollResult__c>();
        for(PollResult__c r : pollResults) {
            if(r.Poll__c == poll.Id) {
                results.add(r);
            }
        }
        return results;
    }

    private static List<Account> getClubsThatVotedForPoll(List<Account> clubs, List<PollResult__c> pollResults) {
        List<Account> results = new List<Account>();
        for(PollResult__c r : pollResults) {
            for(Account c : clubs) {
                if(c.Id == r.Club__c) {
                    results.add(c);
                }
            }
        }
        return results;
    }
}