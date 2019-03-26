({
	getYear : function(component, event, helper) {
        var currentTime = new Date();
        var year = currentTime.getFullYear();
        component.set("v.year", year);		
	},    
})