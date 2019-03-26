({
	getSites : function(component,event,helper) { 
        var action = component.get("c.getSites");

            action.setCallback(this,function(response){
            var state= response.getState();
            $A.log(response);
            if (state == "SUCCESS"){
                console.log('SITES');
                console.log(response.getReturnValue());
                var res = response.getReturnValue();
                component.set("v.sites", res);               
            }
        });
        $A.enqueueAction(action);
	}
})