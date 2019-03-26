public class PFProjectSiteRequest {
    public String userName {get; set;}
    public String userEmail {get; set;}
    public String userID {get; set;}
    public String franchiseeName {get; set;}
    public String ownershipGroup {get; set;}
    public String agreementType {get; set;}
    public String agreementNumber {get; set;}
    public String siteAddress {get; set;}
    public Boolean submitted {get; set;}                        

    public PFProjectSiteRequest() {
        userName = UserInfo.getName();
        userEmail = UserInfo.getUserEmail();
        //userId hardcoded to Brittany Guilmet - Used as targetobjectId
        userID = '005j000000BwjMx';
        submitted = false;  
    }

    public List<SelectOption> getAgreementTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select-'));
        options.add(new SelectOption('ada','ADA'));
        options.add(new SelectOption('fa','FA'));
        return options;
    }

    private void sendEmail() {
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Id = '00Xj0000000Zz9L'];
            
            String htmlBody = emailTemplate.HtmlValue;
             htmlBody = htmlBody.replace('{!Request.userName}', userName);
            htmlBody = htmlBody.replace('{!Request.userEmail}', userEmail);
            htmlBody = htmlBody.replace('{!Request.franchiseeName}', franchiseeName);
            htmlBody = htmlBody.replace('{!Request.ownershipGroup}', ownershipGroup);
            if(!string.isBlank(agreementType)){ 
                htmlBody = htmlBody.replace('{!Request.agreementType}', agreementType);
            }else{
                agreementType = 'NA';
                htmlBody = htmlBody.replace('{!Request.agreementType}', agreementType);
            }
            htmlBody = htmlBody.replace('{!Request.agreementNumber}', agreementNumber);
            htmlBody = htmlBody.replace('{!Request.siteAddress}', siteAddress);
            email.setHtmlBody(htmlbody);
            
            String plainBody = emailTemplate.Body;
            plainBody = plainBody.replace('{!Request.userName}', userName);
            plainBody = plainBody.replace('{!Request.userEmail}', userEmail);
            plainBody = plainBody.replace('{!Request.franchiseeName}', franchiseeName);
            plainBody = plainBody.replace('{!Request.ownershipGroup}', ownershipGroup);
            if(!string.isBlank(agreementType)){
                plainBody = plainBody.replace('{!Request.agreementType}', agreementType);
            }else{
                agreementType = 'NA';
                plainBody = plainBody.replace('{!Request.agreementType}', agreementType);
            }
            plainBody = plainBody.replace('{!Request.agreementNumber}', agreementNumber);
            plainBody = plainBody.replace('{!Request.siteAddress}', siteAddress);
            email.setPlainTextBody(plainbody);

            // Business Recipients
            String[] toAddresses = new List<String>{'mark.andrews@pfhq.com', 'kass.mcinnis@pfhq.com'};
            email.setToAddresses(toAddresses);

            // Admin Recipients
            String[] bccAddresses = new List<String>{'lindsay.ryan@pfhq.com'};
            email.setBccAddresses(bccAddresses);

            // User Recipient (Brittany Guilmet)
            email.setTargetObjectId(userID);
            
            email.setSubject('ALERT: New Project Site Request');
            email.setSaveAsActivity(false);

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            emails.add(email);

            if (!Test.isRunningTest()) {
                Messaging.sendEmail(emails);
            }
            } catch(Exception ex){
                System.debug('The following exception has occurred: ' + ex.getMessage());
            }
    }

    public void submit() {
        submitted = true;
        sendEmail();    
    }
}