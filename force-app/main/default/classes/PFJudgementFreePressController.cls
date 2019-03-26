public with sharing class PFJudgementFreePressController {


    public List<SelectOption> monthly_newsletter {get; set;}
    public List<SelectOption> weekly_updates {get; set;}
    public List<SelectOption> special_announcements {get; set;}

    public String monthly_newsletter_option {get; set;}
    public String weekly_updates_option {get; set;}
    public String special_announcements_option {get; set;}

    private static String MONTHLY_NEWSL = 'Monthly_Newsletter';
    private static String WEEKLY_UP = 'Weekly_Updates';
    private static String SPECIAL_AN = 'Special_Announcements'; 
    	
    public PFJudgementFreePressController() {
        Id monthly_newsletter_RT = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Monthly Newsletter').getRecordTypeId();
        Id weekly_updates_RT = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Weekly Updates').getRecordTypeId();
        Id special_announcements_RT = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Special Announcements').getRecordTypeId();
        
        List<Id> RecTypeID_list = new List<Id>();
        RecTypeID_list.add(monthly_newsletter_RT);
        RecTypeID_list.add(weekly_updates_RT);
        RecTypeID_list.add(special_announcements_RT);

        monthly_newsletter = new List<SelectOption>();
        weekly_updates = new List<SelectOption>();
        special_announcements = new List<SelectOption>();

        Map<Id, Knowledge__kav> allArticles = 
            new Map<Id, Knowledge__kav> ([
                SELECT Id, 
                     Title,
                     LastPublishedDate, 
                     KnowledgearticleId,
                     RecordTypeId  
                FROM Knowledge__kav
                WHERE PublishStatus = 'Online'
                AND Language = 'en_US'
                AND RecordTypeId IN :RecTypeID_list
                ORDER BY LastPublishedDate DESC
        ]);

        if (allArticles != null && allArticles.size() > 0) {
            for (Knowledge__kav article : allArticles.values()) {
                if (article.RecordTypeId == monthly_newsletter_RT) {
                    if (monthly_newsletter.size() < 5) {
                        monthly_newsletter.add(new SelectOption (
                            article.KnowledgearticleId , 
                            article.Title + ' (' + article.LastPublishedDate.Date().format() +')' 
                        ));
                    }
                }
                else if (article.RecordTypeId == weekly_updates_RT) {
                    if (weekly_updates.size() < 5) {
                        weekly_updates.add(new SelectOption (
                            article.KnowledgearticleId , 
                            article.Title + ' (' + article.LastPublishedDate.Date().format() +')' 
                        ));
                    }
                }
                else if (article.RecordTypeId == special_announcements_RT) {
                    if (special_announcements.size() < 5) {
                        special_announcements.add(new SelectOption ( 
                            article.KnowledgearticleId , 
                            article.Title + ' (' + article.LastPublishedDate.Date().format() +')' 
                        ));
                    }
                }
            }
        }
	}

 /******************************************************************************
 * goToNewsletter
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 8/28/2015 
 * @jira: PFCC-2665
 * @description: Takes the user to the News Letter Knowledge Article
 * @param: None.
 * @return: PageReference
 ******************************************************************************/
    public PageReference goToNewsletter() {
        if (monthly_newsletter_option !=null) {
            return new PageReference('/' + monthly_newsletter_option);
        }
        return null;
    }

 /******************************************************************************
 * goToWeeklyUpdates
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 8/28/2015 
 * @jira: PFCC-2665
 * @description: Takes the user to the Weekly Updates Knowledge Article
 * @param: None.
 * @return: PageReference
 ******************************************************************************/
    public PageReference goToWeeklyUpdates() {
        if (weekly_updates_option != null) {
            return new PageReference('/' + weekly_updates_option);
        }
        return null;
    }

 /******************************************************************************
 * goToSpecialAnnouncements
 * @author: Andres Di Geronimo-Stenberg (Magnet360)
 * @date: 8/28/2015 
 * @jira: PFCC-2665
 * @description: Takes the user to the Special Announcements Knowledge Article
 * @param: None.
 * @return: PageReference
 ******************************************************************************/
    public PageReference goToSpecialAnnouncements() {
        if (special_announcements_option != null) {
            return new PageReference('/' + special_announcements_option);
        }
        return null;
    }

}