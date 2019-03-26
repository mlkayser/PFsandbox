({
    getQueryVariable : function(variable) {
        var query = window.location.search.substring(1);
        var vars = query.split('&');
        for (var i = 0; i < vars.length; i++) {
            var pair = vars[i].split('=');
            if (decodeURIComponent(pair[0]) == variable) {
                return decodeURIComponent(pair[1]);
            }
        }
        console.log('Query variable %s not found', variable);
    },

    getClubId : function() {
        // get club Id from URL
        var pageURL = decodeURIComponent(window.location.search.substring(1));         
        if (pageURL.indexOf("id=") != -1) {
        	var clubId = this.getQueryVariable('id');            
        }
        else {
        	pageURL = window.location.pathname;
            var pieces = pageURL.split("/");
        	var clubId = pieces[pieces.length-2];
            console.log('this pageURL = ' + pageURL);
            console.log('this club id = ' + clubId);
        }
        return clubId;        
    },

    getMarketingSpend : function(component, event, helper) {
        var clubId = this.getClubId();
        console.log('====> milestone clubId ID = ' + clubId);
        
        // call Apex method
        var action = component.get("c.getMarketingSpend");
        action.setParams({  
            accId : clubId
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            $A.log(response);
            if(state == "SUCCESS"){
                console.log("Marketing Spend");
                console.log(response.getReturnValue());
                component.set("v.markSpend", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);       
    },
    
})