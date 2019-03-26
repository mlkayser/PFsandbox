({
    gotoPage : function(component,event,helper) {
    	var pageUrl = event.getSource().get("v.title");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": pageUrl
        });
    	urlEvent.fire();        
    }, 
})