({
    loadClubs : function(component,event,helper) {
		helper.getDevRecords(component);
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
    	var clubIdAndStatus = event.getSource().get("v.title");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/club-detail?" + clubIdAndStatus
        });
    	urlEvent.fire();        
    },
    
})