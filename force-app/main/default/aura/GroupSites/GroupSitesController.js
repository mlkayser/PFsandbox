({
	loadData : function(component, event, helper) {
        helper.getSites(component);
    },
    
    gotoDetail : function(component,event,helper) {
    	var siteId = event.getSource().get("v.title");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/detail/" + siteId
        });
    	urlEvent.fire();        
    },    
})