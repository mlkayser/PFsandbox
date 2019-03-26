public with sharing class PFCaseViewRedirectController {
    String recordId;
       
    public PFCaseViewRedirectController(ApexPages.StandardController 
           controller) {recordId = controller.getId();}
    
    public boolean inCommunity() {
        return Test.isRunningTest() ? UserInfo.getUserType() == 'CspLitePortal' : Network.getNetworkId() != null;
    }
    
    public PageReference redirect() 
    {
        PageReference l_page;
        
        if (inCommunity()) 
        {
            l_page = Page.PFCaseView;
            l_page.setRedirect(true);
            l_page.getParameters().put('id', recordId);
        } 
        else 
        {
            l_page = new PageReference('/' + recordId);
            l_page.setRedirect(true);
            l_page.getParameters().put('nooverride', '1');
        }
        return l_page;
    }
}