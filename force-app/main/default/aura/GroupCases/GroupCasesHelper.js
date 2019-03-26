({
	getCases : function(component,event,helper) { 
        var action = component.get("c.getCases");

            action.setCallback(this,function(response){
            var state= response.getState();
            $A.log(response);
            if (state == "SUCCESS"){
                console.log('CASES');
                var res = response.getReturnValue();
                console.log(res.length);
                console.log(response.getReturnValue());
                component.set("v.cases", res);               
            }
        });
        $A.enqueueAction(action);
	}
})