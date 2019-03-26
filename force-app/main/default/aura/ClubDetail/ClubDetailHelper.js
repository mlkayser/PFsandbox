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
        
    getSettings : function() {
        var action = component.get("c.getCommSettings");
    
        action.setCallback(this, function(response){
            var state = response.getState();
            $A.log(response);
            if(state == "SUCCESS"){
                component.set("v.settings", response.getReturnValue());
                console.debug(response.getReturnValue().Google_Plus_URL__c );
            }
        });    
        $A.enqueueAction(action);		
	},
    
   	getCorpContacts : function(component, event, helper) {
        var clubId = this.getClubId();
        console.log('club ID = ' + clubId);
        
        // call Apex method
        var action = component.get("c.getCorpContacts");
        action.setParams({  
            accId : clubId
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            $A.log(response);
            if (state == "SUCCESS"){
                //component.set("v.contacts", response.getReturnValue());
                console.log('Got contacts');
                console.log(response.getReturnValue());
            }
            else {
                console.log('did not work');
            }
        });
        $A.enqueueAction(action);   
    },
})