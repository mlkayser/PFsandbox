({
    loadClubs : function(component,event,helper) {
        helper.getOpenClubs(component);
        helper.getPageUrl(component);
    },  

    gotoMyClubs : function(component,event,helper) {
    	var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/my-clubs"
        });
    	urlEvent.fire();        
    },
    
    gotoDetail : function(component,event,helper) {
    	var clubId = event.getSource().get("v.title");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/club-detail?id=" + clubId + "&status=Open"
        });
    	urlEvent.fire();        
    },
       
})