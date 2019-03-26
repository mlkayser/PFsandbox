/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class PFCommunityForgotPasswordController {
    public String username {get; set;}   
       
    public PFCommunityForgotPasswordController() {}
    
    public PageReference forgotPassword() {
        
        List<User> activeUsers = [SELECT id FROM User WHERE isActive =: true AND email =: username ];
            
        if(activeUsers.size() > 0){
            boolean success = Site.forgotPassword(username);
            PageReference pr = Page.PFCommunityForgotPasswordConfirm;
            pr.setRedirect(true);
        
            if (success) {              
                return pr;
                }         
        }
        else {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'No user with that email could not be found.  Please verify you entered the correct email.')); 
}
       
        return null;
    }
}