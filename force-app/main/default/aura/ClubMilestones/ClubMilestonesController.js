({
	loadData : function(component, event, helper) {
        helper.getAllMilestones(component);
    },
    
    viewWorkLetter : function(component,event,helper) {
        console.log($A.get('$Resource.WorkLetter'));
        var hostname = window.location.hostname;
        console.log(pageURL);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "https://" + hostname + $A.get('$Resource.WorkLetter')
        });
    	urlEvent.fire();        
    },  

    viewArticle : function(component,event,helper) {
        var hostname = window.location.hostname;
        var urlEvent = $A.get("e.force:navigateToURL");
        var idx = event.target.id;
        urlEvent.setParams({
            "url": "/article/" + idx
        });
    	urlEvent.fire();        
    }, 
    
    submitSite : function(componet,event,helper) {
        console.log("Submit a site");
        var projectId = event.getSource().get("v.title");
        var userId = $A.get('$SObjectType.CurrentUser.Id');
        var urlEvent2 = $A.get("e.force:navigateToURL");
        urlEvent2.setParams({
            "url": "/submit-site?projectid=" + projectId + "&userid=" + userId
        });
    	urlEvent2.fire();         
    }, 
    
    submitPrelim : function(componet,event,helper) {
        console.log("Submit prelim");
        var projectId = event.getSource().get("v.title");
        var clubId = helper.getClubId();
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/submit-prelim?projectid=" + projectId + "&accountid=" + clubId
        });
    	urlEvent.fire();         
    },   
    
    submitDocument : function(componet,event,helper) {
        console.log("Submit a document");
        var projectId = event.getSource().get("v.title");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/submit-document?projectid=" + projectId
        });
    	urlEvent.fire();         
    },    
    
    submitDate : function(componet,event,helper) {
        console.log("Submit dates");
        var projectId = event.getSource().get("v.title");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/submit-dates?projectid=" + projectId
        });
    	urlEvent.fire();         
    },  

    gotoPage : function(componet,event,helper) {
        console.log('button clicked');
        var pageUrl = event.getSource().get("v.title");
        console.log(pageUrl);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/" + pageUrl
        });
    	urlEvent.fire();         
    },     
})