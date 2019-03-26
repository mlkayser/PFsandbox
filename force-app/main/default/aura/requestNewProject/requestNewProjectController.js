({
	getQuery : function(component, event, helper) {
    	var userId = $A.get('$SObjectType.CurrentUser.Id');	
        var query = "?userid=" + userId;
		component.set("v.query", query);
	}    
})