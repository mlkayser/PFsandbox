({
    getClubId : function() {
        // get club Id from URL
        var pageURL = decodeURIComponent(window.location.search.substring(1));         
        var pieces = pageURL.split("=");
        var clubId = pieces[pieces.length-1];
        return clubId;        
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
                component.set("v.contacts", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);    
    },
})