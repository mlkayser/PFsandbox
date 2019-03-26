({
    gotoPage : function(componet,event,helper) {
        console.log('button clicked');
        var pageUrl = event.getSource().get("v.title");
        console.log(pageUrl);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": pageUrl
        });
    	urlEvent.fire();         
    }, 
})