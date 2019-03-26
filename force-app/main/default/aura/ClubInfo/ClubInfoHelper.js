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
        var clubId = this.getQueryVariable('id');
        return clubId;        
    },
    
    getClubInfo : function(component, event, helper) {
        var clubId = this.getClubId();
        console.log('record ID = ' + clubId);
        
        // call Apex method
        var action = component.get("c.getClubInfo");
        action.setParams({  
            recordId : clubId
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            $A.log(response);
            if(state == "SUCCESS"){
                var club = response.getReturnValue();
                console.log(response.getReturnValue());
                component.set("v.club", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);       
    },
    
})