({
	getQuery : function(component, event, helper) {
		var query = window.location.search;
		component.set("v.query", query);
	}
})