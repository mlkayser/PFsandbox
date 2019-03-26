({
    getProducts : function(component,event,helper) {        
       var action = component.get("c.getProducts");        

        action.setCallback(this,function(response){
            var state= response.getState();
            $A.log(response);
            if (state == "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.products", result);
            }
        });
        $A.enqueueAction(action);
    },  
    
})