({
    getOpenClubs : function(component,event,helper) {        
       var action = component.get("c.getClubs");        
	   action.setParams({  
            clubStatus : "Open"
        });

        action.setCallback(this,function(response){
            var state= response.getState();
            $A.log(response);
            if(state == "SUCCESS"){
                component.set("v.openClubs",response.getReturnValue());
                var result = response.getReturnValue();
                //var clubs = result.clubObj;
                console.log('Open');
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },  
    
    getPageUrl : function(component) {        
        var pageURL = window.location.pathname;
        var pieces = pageURL.split("/");
        if (pieces[pieces.length-1].length == 0) {
            component.set("v.isHomePage", "true");
        }                
    }
})