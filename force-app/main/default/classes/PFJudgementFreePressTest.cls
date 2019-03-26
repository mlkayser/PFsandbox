@isTest
private class PFJudgementFreePressTest{
    
    @isTest
    static void testJudgementFreePress(){
        
        User current_user = PFTestUtility.getCurrentUser();
        PFTestUtility.setKnowledgeUser(current_user);

        Id monthly_newsletter_RT = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Monthly Newsletter').getRecordTypeId();
        Id weekly_updates_RT = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Weekly Updates').getRecordTypeId();
        Id special_announcements_RT = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Special Announcements').getRecordTypeId();
                    
        System.runAs(current_user) {         
            // monthly newsletter
            Knowledge__kav newsletter = new Knowledge__kav();
            newsletter.Title = 'Test Newsletter';
            newsletter.UrlName = 'Test-Newsletter';
            newsletter.RecordTypeId = monthly_newsletter_RT;
            insert newsletter;
            
            newsletter = [
                SELECT KnowledgeArticleId 
                FROM Knowledge__kav 
                WHERE Id = :newsletter.Id
            ];
            KbManagement.PublishingService.publishArticle(newsletter.KnowledgeArticleId, true);

            // weekly updates
            Knowledge__kav updates = new Knowledge__kav();
            updates.Title = 'Test Updates';
            updates.UrlName = 'Test-Updates';
            updates.RecordTypeId = weekly_updates_RT;
            insert updates;
            
            updates = [
                SELECT KnowledgeArticleId 
                FROM Knowledge__kav 
                WHERE Id = :updates.Id
            ];
            KbManagement.PublishingService.publishArticle(updates.KnowledgeArticleId, true);

            // special announcements
            Knowledge__kav announcements = new Knowledge__kav();
            announcements.Title = 'Test Announcements';
            announcements.UrlName = 'Test-Announcements';
            announcements.RecordTypeId = special_announcements_RT;
            insert announcements;
            
            announcements = [
                SELECT KnowledgeArticleId 
                FROM Knowledge__kav 
                WHERE Id = :announcements.Id
            ];
            KbManagement.PublishingService.publishArticle(announcements.KnowledgeArticleId, true);

            Test.startTest();
                PFJudgementFreePressController controller = new PFJudgementFreePressController();
                controller.monthly_newsletter_option = 'articleID';
                controller.goToNewsletter();
                controller.weekly_updates_option = 'articleID';
                controller.goToWeeklyUpdates();
                controller.special_announcements_option = 'articleID';
                controller.goToSpecialAnnouncements();
            Test.stopTest();

            system.assertEquals(controller.monthly_newsletter.size(), 1);
            system.assertEquals(controller.weekly_updates.size(), 1);
            system.assertEquals(controller.special_announcements.size(), 1);
        }
    }
}