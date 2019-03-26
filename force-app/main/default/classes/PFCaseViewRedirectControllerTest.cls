@isTest
public class PFCaseViewRedirectControllerTest {

    static testMethod void controllerTest()
    {
        Case c = new Case();
        User community_user ;
        User current_user = PFTestUtility.getCurrentUser();
        PFTestUtility.setKnowledgeUser( current_user );

        System.runAs( current_user ) 
        {
            PFTestUtility.checkUserRole( current_user );

            community_user = PFTestUtility.communityUser( 'TestName' , 'LastNAmeTEst' , 'test@pf.com', 'test@pf.com' );
            insert community_user;
        }

        system.runAs( community_user )
        {
            apexpages.StandardController sc = new apexpages.StandardController( c );
            PFCaseViewRedirectController controller = new PFCaseViewRedirectController( sc );
            controller.redirect();
        }
        
        apexpages.StandardController sc = new apexpages.StandardController( c );
        PFCaseViewRedirectController controller = new PFCaseViewRedirectController( sc );
        controller.redirect();
    }
    /*
    private static User createCommunityUser(){
        Account accInd = new account(name='individual');
        insert accInd ;
        
        Contact contact = new Contact(LastName = 'hello',FirstName = 'World',Email = 'a@dolby.com',AccountId =  accInd.Id);
        insert contact;
        
        Profile p = [select id from profile where name = 'Customer Community User - Franchisee'];
        
        User u = new User(  alias = 'standt',
                            email='a@dolby.com',
                            emailencodingkey='UTF-8',
                            FirstName = 'hello',
                            lastname='Testing',
                            languagelocalekey='en_US',
                            localesidkey='en_US',
                            //IsPortalSelfRegistered = true,
                            profileid = p.Id,
                            ContactId = contact.id,
                            timezonesidkey='America/Los_Angeles',
                            CommunityNickname = 'Tom',
                            isActive = true,
                            username='a@dolby.com');
        
                insert u;
        return u;
    }*/
}