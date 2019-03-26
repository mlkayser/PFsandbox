({
	getTasks : function(component,event,helper) { 
        var action = component.get("c.getTasks");

            action.setCallback(this,function(response){
            var state= response.getState();
            $A.log(response);
            if (state == "SUCCESS"){
                console.log('TASKS');
                console.log(response.getReturnValue());
                var res = response.getReturnValue();
                component.set("v.tasks", res);               
            }
        });
        $A.enqueueAction(action);
	}
})