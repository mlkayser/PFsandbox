({
   	getDevRecords : function(component,event,helper) {
       var action = component.get("c.getClubs");        
	   action.setParams({  
            clubStatus : null
        });

       action.setCallback(this,function(response){
            var state= response.getState();
            $A.log(response);
            if(state == "SUCCESS"){
				var recordList = response.getReturnValue();
            	var presaleList = [];    
            	var sitePlanningList = [];    
            	var siteSelectionList = [];    
            	var activeDevelopmentList = [];    

                for(var i = 0; i < recordList.length; i++){
                   	if (recordList[i].clubObj.Status__c == 'Presale'){
                        presaleList.push(recordList[i]);
                    }
                    else if (recordList[i].clubObj.Status__c == 'Site Planning'){
                        sitePlanningList.push(recordList[i]);
                    }    
                    else if (recordList[i].clubObj.Status__c == 'Site Selection'){
                        siteSelectionList.push(recordList[i]);
                    }    
                    else if (recordList[i].clubObj.Status__c == 'Active Development'){
                        activeDevelopmentList.push(recordList[i]);
                    }    
                }

                component.set("v.devClubs", response.getReturnValue());
                component.set("v.presale", presaleList);
                component.set("v.siteSelection", siteSelectionList);
                component.set("v.sitePlanning", sitePlanningList);
                component.set("v.activeDev", activeDevelopmentList);
            }
        });
       $A.enqueueAction(action);
	},  
    
    getPageUrl : function(component) {        
        var pageURL = window.location.pathname;
        var pieces = pageURL.split("/");
        if (pieces[pieces.length-1].length == 0) {
            component.set("v.isHomePage", "true");
        }                
    }
})