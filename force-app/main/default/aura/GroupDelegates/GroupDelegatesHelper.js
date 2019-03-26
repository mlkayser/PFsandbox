({
    getDelegates : function(component,event,helper) {        
       var action = component.get("c.getDelegates");        

        action.setCallback(this,function(response){
            var state= response.getState();
            $A.log(response);
            if (state == "SUCCESS"){
                console.log('DELEGATES');
                console.log(response.getReturnValue());
                var map = response.getReturnValue();
				var delegateList = [];
				var key;
                for (key in map) {
                	delegateList.push(map[key]);
                }
                
                delegateList.sort(function(a, b) {
                  var nameA = a.LastName.toUpperCase(); // ignore upper and lowercase
                  var nameB = b.LastName.toUpperCase(); // ignore upper and lowercase
                  if (nameA < nameB) {
                    return -1;
                  }
                  if (nameA > nameB) {
                    return 1;
                  }
                
                  // names must be equal
                  return 0;
                });                          
                component.set("v.delegates", delegateList);
                console.log(delegateList);                
            }
        });
        $A.enqueueAction(action);
    }, 
    
})