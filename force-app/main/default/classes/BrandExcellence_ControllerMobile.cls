/**
* Created by JLinn on 5/20/18.
*/

public with sharing class BrandExcellence_ControllerMobile {

//    public HTTPResponse res {get; set;}
//    public String resBody {get; set;}
    public String endpoint {get; set;}
    public String localTime {get{
        Datetime localTime =  Datetime.now();
        return localTime.format('h:mm a');
    }}
//    public String formName {get; set;}
//    public Boolean isRedirect {get; set;}
    public String accountId {get; set;}
    private String todayDate = Date.today().format();
    public String pageName {get{
       return ApexPages.currentPage().getUrl().substringAfter('apex/');
    } set;}
    
    //private Account account;
    
    
    public BrandExcellence_ControllerMobile(ApexPages.StandardSetController controller) {
        // Grab the query string from the url
       // String queryString = getQueryString();
        PageReference pageRef = ApexPages.currentPage();
        
        
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        
//        this.formName = pageRef.getParameters().get('formName');
        this.accountId = pageRef.getParameters().get('id');
        
        Account account = [
                SELECT Id, Date_Opened__c, Square_Footage__c, Club_EFT__c, BC__c, Operations_District__c
                FROM Account
                WHERE Id = : THIS.accountId
                LIMIT 1
        ];
    
    
        String expirationDate = '';
        try{
            PFAgreement__c pfAgreement = [
                    SELECT Expiration_Date__c
                    FROM PFAgreement__c
                    WHERE Club_Name__c = : THIS.accountId
                    LIMIT 1
            ];
    
            if(pfAgreement.Expiration_Date__c != null){
                expirationDate = pfAgreement.Expiration_Date__c.format();
            }else{
                expirationDate = '';
            }
        }catch(Exception e){
            expirationDate = '';
        }
        
        
        String dateOpenString = '';
        
        if(account.Date_Opened__c != null){
            dateOpenString = account.Date_Opened__c.format('MM/dd/yyyy');
        }
        
        String squareFootageString = '';
        System.debug(squareFootageString);
        if(account.Square_Footage__c != null){
            squareFootageString = String.valueOf(account.Square_Footage__c);
            System.debug(squareFootageString);
        }
        
        String clubEFTString = '';
        if(account.Club_EFT__c != null){
            clubEFTString = String.valueOf(account.Club_EFT__c);
        }
        
        String bcString = '';
        if(account.BC__c != null){
            bcString = String.valueOf(account.BC__c);
        }
        
//        if(pageRef.getParameters().get('tfa_next') ==null){
//            // Replace 'FORM_ID' with your form's ID number
//
//            //Adjust the endpoint based on what the button is set to
//            if(formName == 'Call'){
//                endpoint = 'https://app.formassembly.com/rest/forms/view/4673478?' + queryString + 'tfa_871=' + localTime;
//            }else if(formName == 'Tour'){
        
        ///apex/BrandExcellence?tfa_873={!LPAD(TEXT(MONTH(TODAY())), 2, "0") & "/" & LPAD(TEXT(DAY(TODAY())), 2, "0") &"/" & TEXT(YEAR(TODAY())) }&tfa_875={!Account.Id}&tfa_876={!$User.Id}&formName=Tour"
        
//                String urlString = 'tfa_871=' + EncodingUtil.urlEncode(localTime, 'UTF-8') +
//                        'tfa_873=' +  EncodingUtil.urlEncode(todayDate, 'UTF-8');
        if(pageName.contains('Tour')){
            
            String urlString = 'tfa_871=' + EncodingUtil.urlEncode(localTime, 'UTF-8') +
                    '&tfa_873=' + EncodingUtil.urlEncode(todayDate, 'UTF-8') +
                    '&tfa_875=' + EncodingUtil.urlEncode(this.accountId, 'UTF-8') +
                    '&tfa_876=' + EncodingUtil.urlEncode(UserInfo.getUserId(), 'UTF-8') +
                    '&tfa_878=' + EncodingUtil.urlEncode(account.Operations_District__c + '', 'UTF-8');
            this.endpoint = 'https://app.formassembly.com/4673479?' + urlString;
            
        } else if(pageName.contains('Call')){
    
            String urlString = 'tfa_871=' + EncodingUtil.urlEncode(localTime, 'UTF-8') +
                    '&tfa_869=' + EncodingUtil.urlEncode(todayDate, 'UTF-8') +
                    '&tfa_945=' + EncodingUtil.urlEncode(this.accountId, 'UTF-8') +
                    '&tfa_944=' + EncodingUtil.urlEncode(UserInfo.getUserId(), 'UTF-8') +
                    '&tfa_947=' + EncodingUtil.urlEncode(account.Operations_District__c + '', 'UTF-8');
            
            this.endpoint = 'https://app.formassembly.com/4673478?' + urlString;
        
        } else if(pageName.contains('Operations')){
            
    
            String urlString = 'tfa_871=' + EncodingUtil.urlEncode(localTime, 'UTF-8') +
                    '&tfa_870=' + EncodingUtil.urlEncode(todayDate, 'UTF-8') +
                    '&tfa_890=' + EncodingUtil.urlEncode(this.accountId, 'UTF-8') +
                    '&tfa_891=' + EncodingUtil.urlEncode(UserInfo.getUserId(), 'UTF-8') +
                    '&tfa_1379=' + EncodingUtil.urlEncode(account.Operations_District__c + '', 'UTF-8') +
                    '&tfa_877=' + EncodingUtil.urlEncode(dateOpenString, 'UTF-8') +
                    '&tfa_878=' + EncodingUtil.urlEncode(expirationDate, 'UTF-8') +
                    '&tfa_881=' + EncodingUtil.urlEncode(squareFootageString, 'UTF-8') +
                    '&tfa_883=' + EncodingUtil.urlEncode(clubEFTString, 'UTF-8') +
                    '&tfa_884=' + EncodingUtil.urlEncode(bcString, 'UTF-8');
            
            this.endpoint = 'https://app.formassembly.com/4673481?' + urlString;
            
        } else if(pageName.contains('Member')){
            
    
            String urlString = 'tfa_871=' + EncodingUtil.urlEncode(localTime, 'UTF-8') +
                    '&tfa_870=' + EncodingUtil.urlEncode(todayDate, 'UTF-8') +
                    '&tfa_890=' + EncodingUtil.urlEncode(this.accountId, 'UTF-8') +
                    '&tfa_891=' + EncodingUtil.urlEncode(UserInfo.getUserId(), 'UTF-8') +
                    '&tfa_1379=' + EncodingUtil.urlEncode(account.Operations_District__c + '', 'UTF-8');
                    
            
            this.endpoint = 'https://app.formassembly.com/4688000?' + urlString;
        
        }
        
//                        + queryString +

//            }else if(formName == 'Operations'){
//                endpoint = 'https://app.formassembly.com/rest/forms/view/4673481?' + queryString + 'tfa_871=' + localTime;
//            }
//
//        } else {
//            endpoint = 'https://app.formassembly.net/rest' + pageRef.getParameters().get('tfa_next');
//        }
        
//        req.setEndpoint(endpoint);
//        Http http = new Http();
//
//        try {
//            // Execute web service call here
//            res = http.send(req);
//            resBody = res.getBody();
//        } catch(System.CalloutException e) {
//            // Exception handling goes here....
//            System.debug(e);
//        }
    }
    
    /**
     * Grabs the query string from the url of the current page
     * @returns String queryString
     */
//    private String getQueryString() {
//        String queryString = '';
//
//        Map<String, String> parameters = ApexPages.currentPage().getParameters();
//        Set<String> keys = parameters.keySet();
//
//        for (String k: keys) {
//            queryString += k + '=';
//            queryString += parameters.get(k) + '&';
//        }
//
//        return queryString;
//    }
}