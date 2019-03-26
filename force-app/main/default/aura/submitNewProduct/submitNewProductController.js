({
	getQuery : function(component, event, helper) {
		var query = $A.get("$SObjectType.CurrentUser.Id");
		component.set("v.query", '?userid=' + query);
	},
})